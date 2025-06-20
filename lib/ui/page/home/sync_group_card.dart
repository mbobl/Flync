import 'package:flutter/material.dart';
import 'package:flync/model/sync_group.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/ui/page/home/deletable_card.dart';
import 'package:flync/ui/page/home/home_page_manager.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flync/ui/page/home/sync_group_ui_extension.dart';

class SyncGroupCard extends StatelessWidget {
  final int groupId;
  final SyncGroup group;

  const SyncGroupCard({super.key, required this.groupId, required this.group});

  @override
  Widget build(BuildContext context) {
    return DeletableCard(
      onDeleted: () => getIt<HomePageManager>().onClickDelete(context, groupId),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(
            context,
          ).style.merge(TextStyle(height: 1.5, fontSize: 16)),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (var config in group.uiConfigs)
                          Row(
                            children: [
                              Icon(config.$1, opticalSize: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: EllipsizedText(
                                  config.$2,
                                  type: EllipsisType.start,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton.filled(
                    onPressed:
                        () => getIt<HomePageManager>().onClickSync(groupId),
                    icon: Icon(Icons.sync)
                        .animate(
                          onComplete:
                              (controller) =>
                                  group.inProgress
                                      ? controller.repeat(count: 1)
                                      : controller.value = 0,
                          autoPlay: group.inProgress,
                          key: ValueKey(group.syncCount),
                        )
                        .rotate(
                          duration: 500.milliseconds,
                          begin: 0,
                          end: -0.5,
                        ),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          overflow: TextOverflow.ellipsis,
                          group.contentText,
                        ),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          group.modifiedDateText,
                        ),
                        Text(overflow: TextOverflow.ellipsis, group.statusText),
                      ],
                    ),
                  ),
                  Icon(
                    group.statusIcon,
                    color: Theme.of(context).primaryColor,
                  ).animate(key: ValueKey(group.statusIcon)).fade(),
                  SizedBox(width: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
