// lib/app/modules/home/views/widgets/recent_loads_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/home_controller.dart';
import 'empty_state_widget.dart';
import 'load_card.dart';

class RecentLoadsSection extends StatelessWidget {
  final HomeController controller;
  final AppLocalizations l10n;

  const RecentLoadsSection({
    Key? key,
    required this.controller,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final loads = controller.recentLoads;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Load Postings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  if (loads.isNotEmpty)
                    TextButton.icon(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        'View All',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onPressed: () => Get.toNamed('/loads'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (loads.isEmpty)
                EmptyStateWidget(
                  title: 'No Recent Loads',
                  subtitle: 'Start by posting your first load',
                  icon: Icons.add_box_outlined,
                  actionText: 'Post Load',
                  onAction: controller.navigateToPostLoad,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: loads.length > 3 ? 3 : loads.length,
                  itemBuilder: (context, index) {
                    final load = loads[index];
                    return LoadCard(
                      load: load,
                      onTap: () => controller.onLoadCardTapped(load),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}