// lib/app/modules/home/views/widgets/home_floating_action_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

class HomeFloatingActionButton extends StatelessWidget {
  final HomeController controller;

  const HomeFloatingActionButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "quick_post",
          onPressed: () {
            Get.back();
            // Show templates dialog or navigate to templates
            Get.toNamed(Routes.POST_LOAD);  ();
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 6,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
