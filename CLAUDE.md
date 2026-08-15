# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What Flync is

An open-source Flutter app for **two-way file synchronization** between a device
folder and "dumb" storage endpoints — servers that offer nothing but
list/read/write/delete (currently local + FTP; WebDAV and SFTP are the planned
next backends, cloud storage later).

**Motivation:** the project started after FolderSync fell short on three fronts —
over-engineered UI, aggressive monetization, closed source. Flync's niche is the
combination no open-source app occupies: arbitrary folder pairs × multiple
dumb-endpoint protocols × stateful two-way sync with deletion tracking × a
modern, polished UI. Adjacent tools each miss one axis: Syncthing-Fork is
P2P-only, rsync clients are one-way, Round Sync (rclone) is one-way file
management, EasySync is WebDAV-only with fixed folders.

Primary audience and channel: self-hosters (NAS, Nextcloud, home servers),
distributed F-Droid-first.

## Principles, in priority order

1. **Never lose user data.** Reliability is the entire product; users forgive a
   skipped sync, never a vanished file. The engine must be fail-safe by
   construction, not by foresight: conflict copies instead of silent overwrites,
   skip-and-report instead of guessing on ambiguity, temp-write-then-rename,
   snapshot updated only after verified transfer, idempotent re-runs. The worst
   reachable outcome of any sync must be a duplicate file.

2. **Easy to maintain — this project must not burn out its maintainer.** Every
   comparable project (syncthing-android, RCX, SyncTool) died of maintenance
   fatigue, not competition. In practice:
   - Keep the sync core small and exhaustively tested; a bugfix years from now
     should be a safe 20-minute change.
   - Protocols are thin plugins behind `StorageClientService` — each backend is
     ~100 isolated lines that cannot break the engine. Keep the interface dumb.
   - Scope is a wall: no P2P, no delta transfer, no 30-protocol matrix. Saying 
     no is a feature.
   - Prefer solutions that reduce future work over solutions that impress.

3. **UI follows the newest Material spec.** Google's own apps are the reference
   bar for look and behavior. Dynamic color, current component styles, proper
   motion. When Flutter updates shift Material defaults, adopt the new defaults
   rather than pinning the old look.

4. **Dependencies stay relatively current.** Track recent stable Flutter and
   keep packages up to date rather than accumulating a risky mega-upgrade.
   Prefer maintained libraries; treat unmaintained dependencies as inherited
   maintenance debt to be replaced (watch list: `ftpconnect`,
   `dynamic_system_colors`, `hive` — consider `hive_ce`).

## Architecture

Three layers under `lib/`:

- `model/` — freezed data classes (`SyncGroup`, `StorageConfig`,
  `FileMetadata`) serialized to JSON, persisted in Hive.
- `service/` — logic, DI via `get_it` (`service_locator.dart`):
  - `client/` — one `StorageClientService` implementation per backend.
  - `sync/` — `SynchronizationJob` computes and executes sync actions using a
    snapshot of the previous sync state for deletion tracking.
  - `persistence_service.dart` — Hive-backed storage of sync groups.
- `ui/` — pages with the minimalist manager pattern (one manager class per
  page holding `ValueNotifier`s; no bloc/riverpod — don't introduce them).

**Adding a protocol backend:** implement `StorageClientService`, add a variant
to the `StorageSource` enum (`model/storage_source.dart`) and to
`StorageSourceUi` (`ui/page/storage_form/config/storage_source_ui.dart`) with a
config form widget. Nothing else should need to change.

## Commands

```sh
dart run build_runner build  # codegen (freezed/json); generated files are not committed
flutter analyze
flutter test
flutter run
```

## Testing

The sync engine is trust-critical code — test it like it deletes files, because
it does. Testing here is not a chore appended to features; it is how principle
1 (never lose data) and principle 2 (safe to maintain years later) are enforced.

- **Test the engine against fake in-memory `StorageClientService`s**, never real
  servers or the filesystem. Fakes keep tests fast, deterministic, and able to
  simulate failures (timeouts, mid-transfer crashes, lying timestamps) that real
  backends can't produce on demand.
- **Cover the reconciliation decision table exhaustively.** Every combination of
  (in snapshot? / changed on side A? / changed on side B?) is a named test case
  with a defined expected action. If a state isn't in the table, the correct
  behavior is skip-and-report — test that too.
- **Property-based tests guard the invariants.** Generate random operation
  sequences on both sides (create/modify/delete, random interleavings, random
  crash points), run sync, and assert: both sides converge, and no content that
  existed on either side is lost — it's either present or in a conflict copy.
- **Grow an edge-case catalog.** Classic sync killers to keep covered:
  delete-on-A vs modify-on-B, both-sides-changed, same-size same-mtime content
  changes, timestamp skew/granularity (FTP reports minutes, FAT rounds to 2s),
  crash between transfer and snapshot write, re-run after partial failure, name
  collisions differing only by case. When a real-world bug is found, its
  reproduction joins the catalog before the fix lands.
- **A change to sync logic without an accompanying test is incomplete.** UI and
  glue code may be tested more lightly; the engine may not.
