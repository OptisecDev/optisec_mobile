import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/pin_setup_controller.dart';

class PinSetupView extends GetView<PinSetupController> {
  const PinSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Set PIN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Obx(() => Text(
                  controller.step.value == PinSetupStep.enter
                      ? 'Choose a 4-digit PIN'
                      : 'Confirm your PIN',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                )),
            const SizedBox(height: 8),
            SizedBox(
              height: 18,
              child: Obx(() => Text(
                    controller.errorMessage.value ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  )),
            ),
            const SizedBox(height: 24),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(PinSetupController.pinLength, (i) {
                    final filled = i < controller.enteredDigits.length;
                    return Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: filled
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                    );
                  }),
                )),
            const Spacer(),
            Obx(() => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox.shrink()),
            _PinPad(controller: controller),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  final PinSetupController controller;

  const _PinPad({required this.controller});

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'back'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows
          .map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  if (key.isEmpty) {
                    return const SizedBox(width: 72, height: 72);
                  }
                  if (key == 'back') {
                    return _PinKey(
                      icon: Icons.backspace_outlined,
                      onTap: controller.backspace,
                    );
                  }
                  return _PinKey(
                    label: key,
                    onTap: () => controller.appendDigit(key),
                  );
                }).toList(),
              ))
          .toList(),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _PinKey({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Center(
              child: label != null
                  ? Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : Icon(icon, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
