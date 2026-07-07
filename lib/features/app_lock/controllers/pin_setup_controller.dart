import 'package:get/get.dart';

import '../../../core/services/app_lock_service.dart';

enum PinSetupStep { enter, confirm }

/// Two-step "enter PIN, then confirm it" flow for creating the App Lock
/// PIN. The confirm step is checked against the in-memory [_firstPin] only
/// — nothing is persisted until both entries match, at which point the
/// native side hashes and stores it (see [AppLockStore.setPin]).
class PinSetupController extends GetxController {
  static const pinLength = 4;

  final step = PinSetupStep.enter.obs;
  final enteredDigits = <String>[].obs;
  final errorMessage = Rxn<String>();
  final isSaving = false.obs;

  String? _firstPin;

  void appendDigit(String digit) {
    if (isSaving.value || enteredDigits.length >= pinLength) return;
    errorMessage.value = null;
    enteredDigits.add(digit);
    if (enteredDigits.length == pinLength) {
      _onPinComplete();
    }
  }

  void backspace() {
    if (isSaving.value || enteredDigits.isEmpty) return;
    enteredDigits.removeLast();
  }

  Future<void> _onPinComplete() async {
    final pin = enteredDigits.join();

    if (step.value == PinSetupStep.enter) {
      _firstPin = pin;
      step.value = PinSetupStep.confirm;
      enteredDigits.clear();
      return;
    }

    if (pin != _firstPin) {
      errorMessage.value = 'PINs don\'t match. Try again.';
      enteredDigits.clear();
      return;
    }

    isSaving.value = true;
    final success = await AppLockService.instance.setPin(pin);
    isSaving.value = false;

    if (success) {
      Get.back(result: true);
    } else {
      errorMessage.value = 'Couldn\'t save PIN. Try again.';
      restart();
    }
  }

  void restart() {
    step.value = PinSetupStep.enter;
    enteredDigits.clear();
    errorMessage.value = null;
    _firstPin = null;
  }
}
