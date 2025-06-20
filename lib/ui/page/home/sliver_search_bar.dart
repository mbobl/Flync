import 'package:flutter/material.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/ui/page/home/home_page_manager.dart';

class SliverSearchBar extends StatelessWidget {
  const SliverSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: getIt<HomePageManager>().syncGroupsCountNotifier,
      builder: (context, count, child) {
        return SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBar(
              onChanged:
                  (value) => getIt<HomePageManager>().setSearchQuery(value),
              padding: const WidgetStatePropertyAll(EdgeInsets.only(left: 12)),
              constraints: const BoxConstraints(maxHeight: 48),
              elevation: const WidgetStatePropertyAll(0),
              hintText: 'Search $count items...',
              leading: Icon(Icons.search),
              trailing: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
