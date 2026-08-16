import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flync/model/file_metadata.dart';
import 'package:flync/service/sync/synchronization_job.dart';

import 'fake_storage_client.dart';

// Cases marked `skip` specify correct behavior the current engine does not
// implement yet — they are the acceptance criteria for the engine rewrite.
// Unskip them as it lands; never delete or weaken them.
void main() {
  final t1 = DateTime(2026, 1, 1, 10);
  final t2 = DateTime(2026, 1, 2, 10);
  final t3 = DateTime(2026, 1, 3, 10);

  late FakeStorageClient a;
  late FakeStorageClient b;

  setUp(() {
    a = FakeStorageClient();
    b = FakeStorageClient();
  });

  Future<void> sync({Set<FileMetadata> snapshot = const {}}) =>
      SynchronizationJob(a, b, snapshot).synchronize();

  Future<Set<FileMetadata>> seedSynced(String name, String content) async {
    a.put(name, content, t1);
    b.put(name, content, t1);
    return a.getFiles();
  }

  group('reconciliation decision table', () {
    test('not in snapshot, only on A -> creation copied to B', () async {
      a.put('new.txt', 'hello', t1);

      await sync();

      expect(b.contentOf('new.txt'), 'hello');
      expect(b.files['new.txt']!.modified, t1);
    });

    test('not in snapshot, only on B -> creation copied to A', () async {
      b.put('new.txt', 'hello', t1);

      await sync();

      expect(a.contentOf('new.txt'), 'hello');
    });

    test('in snapshot, missing on A -> deletion propagates to B', () async {
      final snapshot = await seedSynced('doomed.txt', 'bye');
      a.files.remove('doomed.txt');

      await sync(snapshot: snapshot);

      expect(a.files, isEmpty);
      expect(b.files, isEmpty);
    });

    test('in snapshot, missing on B -> deletion propagates to A', () async {
      final snapshot = await seedSynced('doomed.txt', 'bye');
      b.files.remove('doomed.txt');

      await sync(snapshot: snapshot);

      expect(a.files, isEmpty);
      expect(b.files, isEmpty);
    });

    test('in snapshot, deleted on both sides -> no action', () async {
      final snapshot = await seedSynced('gone.txt', 'bye');
      a.files.remove('gone.txt');
      b.files.remove('gone.txt');

      await sync(snapshot: snapshot);

      expect(a.files, isEmpty);
      expect(b.files, isEmpty);
    });

    test('unchanged on both sides -> no transfer happens', () async {
      final snapshot = await seedSynced('same.txt', 'stable');

      await sync(snapshot: snapshot);

      expect(a.contentOf('same.txt'), 'stable');
      expect(b.contentOf('same.txt'), 'stable');
      expect(a.files['same.txt']!.modified, t1);
      expect(b.files['same.txt']!.modified, t1);
    });

    test('changed on A only -> new content copied to B', () async {
      final snapshot = await seedSynced('note.txt', 'v1');
      a.put('note.txt', 'v2 with more text', t2);

      await sync(snapshot: snapshot);

      expect(b.contentOf('note.txt'), 'v2 with more text');
      expect(b.files['note.txt']!.modified, t2);
    });

    test('changed on B only -> new content copied to A', () async {
      final snapshot = await seedSynced('note.txt', 'v1');
      b.put('note.txt', 'v2 with more text', t2);

      await sync(snapshot: snapshot);

      expect(a.contentOf('note.txt'), 'v2 with more text');
    });

    test(
      'changed on both sides -> both contents preserved (conflict copy)',
      () async {
        final snapshot = await seedSynced('clash.txt', 'base');
        a.put('clash.txt', 'edit made on A', t2);
        b.put('clash.txt', 'a different edit made on B', t3);

        await sync(snapshot: snapshot);

        final everything = [...a.contents.values, ...b.contents.values];
        expect(everything, contains('edit made on A'));
        expect(everything, contains('a different edit made on B'));
      },
      skip:
          'known engine limitation: newer side silently overwrites the other.'
          ' Unskip with the engine rewrite.',
    );

    test(
      'changed on A with same size -> still copied to B',
      () async {
        final snapshot = await seedSynced('fixed.txt', 'aaaa');
        a.put('fixed.txt', 'bbbb', t2);

        await sync(snapshot: snapshot);

        expect(b.contentOf('fixed.txt'), 'bbbb');
      },
      skip:
          'known engine limitation: same-size edits are invisible to the'
          ' size-based comparison. Unskip with the engine rewrite.',
    );

    test(
      'deleted on A but changed on B -> changed content is preserved',
      () async {
        final snapshot = await seedSynced('precious.txt', 'v1');
        a.files.remove('precious.txt');
        b.put('precious.txt', 'v2, edited after the delete', t2);

        await sync(snapshot: snapshot);

        expect(
          [...a.contents.values, ...b.contents.values],
          contains('v2, edited after the delete'),
        );
      },
      skip:
          'known engine limitation: name-only snapshot cannot distinguish'
          ' stale copy from fresh edit, so the edit is deleted. Unskip with'
          ' the engine rewrite.',
    );
  });

  group('modify-time support degradation', () {
    test('copies still propagate when one side cannot set mtimes', () async {
      b = FakeStorageClient(supportsModifyTime: false, uploadClock: t3);
      final snapshot = await seedSynced('note.txt', 'v1');
      a.put('note.txt', 'v2 with more text', t2);

      await sync(snapshot: snapshot);

      expect(b.contentOf('note.txt'), 'v2 with more text');
      // The engine must not try to stamp the source mtime onto B.
      expect(b.files['note.txt']!.modified, t3);
    });
  });

  group('snapshot creation', () {
    test('createSnapshot prefers the side that supports modify time', () async {
      b = FakeStorageClient(supportsModifyTime: false);
      a.put('one.txt', 'x', t1);
      b.put('two.txt', 'y', t2);

      final snapshot = await SynchronizationJob(a, b, null).createSnapshot();

      expect(snapshot.map((f) => f.name), {'one.txt'});
    });
  });

  group('invariants', () {
    test('random non-overlapping operations converge', () async {
      final random = Random(42);

      for (var round = 0; round < 25; round++) {
        a = FakeStorageClient();
        b = FakeStorageClient();

        for (var i = 0; i < 8; i++) {
          a.put('file$i.txt', 'base content $i', t1);
          b.put('file$i.txt', 'base content $i', t1);
        }
        final snapshot = await a.getFiles();

        // At most one operation per file, on one side only, so the correct
        // outcome is well-defined even before the engine rewrite.
        final expected = <String, String>{};
        for (var i = 0; i < 8; i++) {
          final name = 'file$i.txt';
          switch (random.nextInt(6)) {
            case 0:
              expected[name] = 'base content $i';
            case 1:
              a.put(name, 'edited on A in round $round: $i', t2);
              expected[name] = 'edited on A in round $round: $i';
            case 2:
              b.put(name, 'edited on B in round $round: $i', t2);
              expected[name] = 'edited on B in round $round: $i';
            case 3:
              a.files.remove(name);
            case 4:
              b.files.remove(name);
            case 5:
              a.put('created-a-$round-$i.txt', 'fresh A $i', t2);
              expected[name] = 'base content $i';
              expected['created-a-$round-$i.txt'] = 'fresh A $i';
          }
        }

        await SynchronizationJob(a, b, snapshot).synchronize();

        expect(
          a.contents,
          equals(expected),
          reason: 'side A diverged in round $round',
        );
        expect(
          b.contents,
          equals(expected),
          reason: 'side B diverged in round $round',
        );
      }
    });

    test(
      'fully random operations never lose content',
      () async {
        final random = Random(1337);

        for (var round = 0; round < 25; round++) {
          a = FakeStorageClient();
          b = FakeStorageClient();

          for (var i = 0; i < 8; i++) {
            a.put('file$i.txt', 'base content $i', t1);
            b.put('file$i.txt', 'base content $i', t1);
          }
          final snapshot = await a.getFiles();

          final mustSurvive = <String>{};
          for (final side in [a, b]) {
            for (var i = 0; i < 8; i++) {
              final name = 'file$i.txt';
              final sideName = identical(side, a) ? 'A' : 'B';
              switch (random.nextInt(3)) {
                case 0:
                  break;
                case 1:
                  final content = 'round $round edit on $sideName: $i';
                  side.put(name, content, side == a ? t2 : t3);
                  mustSurvive.add(content);
                case 2:
                  side.files.remove(name);
              }
            }
          }

          await SynchronizationJob(a, b, snapshot).synchronize();

          final everything = {...a.contents.values, ...b.contents.values};
          for (final content in mustSurvive) {
            expect(
              everything,
              contains(content),
              reason: 'content lost in round $round',
            );
          }
        }
      },
      skip:
          'known engine limitations (overwrite-on-conflict, delete-vs-modify)'
          ' make this fail. Unskip with the engine rewrite — this test is the'
          ' rewrite\'s acceptance bar.',
    );
  });
}
