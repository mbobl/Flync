import 'package:flutter/material.dart';
import 'package:flync/model/sync_group.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/ui/page/home/home_page_manager.dart';
import 'package:flync/ui/page/home/sliver_search_bar.dart';
import 'package:flync/ui/page/home/sync_group_card.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverSearchBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: ValueListenableBuilder<Map<int, SyncGroup>>(
                valueListenable: getIt<HomePageManager>().syncGroupsNotifier,
                builder: (context, idToGroup, child) {
                  final entries = idToGroup.entries.toList();
                  return SliverList.separated(
                    itemBuilder:
                        (context, index) => SyncGroupCard(
                          groupId: entries[index].key,
                          group: entries[index].value,
                        ),
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                    itemCount: entries.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.sync)),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.update_disabled),
                  ),
                ],
              ),
            ),
            FloatingActionButton(
              onPressed: () => context.push('/storage-form'),
              elevation: 0,
              child: Icon(Icons.add),
            ),
          ],
        ),
        // ),
      ),
    );
  }
}
