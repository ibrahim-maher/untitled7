// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/language_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../controllers/home_controller.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/search_section.dart';
import 'widgets/quick_stats_section.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/active_shipments_section.dart';
import 'widgets/recent_loads_section.dart';
import 'widgets/emergency_support_card.dart';
import 'widgets/home_bottom_navigation.dart';
import 'widgets/home_floating_action_button.dart';
import '../../../generated/l10n/app_localizations.dart';


// Update your HomeView
class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: LoadingWidget(message: 'Loading dashboard...'))
            : RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              HomeAppBar(
                controller: controller,
                l10n: l10n,
                languageController: languageController,
              ),
              SearchSection(controller: controller, l10n: l10n),
              QuickStatsSection(controller: controller, l10n: l10n),
              QuickActionsSection(controller: controller, l10n: l10n),
              ActiveShipmentsSection(controller: controller, l10n: l10n),
              RecentLoadsSection(controller: controller, l10n: l10n),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      // Remove bottomNavigationBar from here
      floatingActionButton: HomeFloatingActionButton(controller: controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}