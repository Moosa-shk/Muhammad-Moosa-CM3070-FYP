import 'package:get/get.dart';

/// BottomNavController manages the state of the bottom navigation bar.
/// It uses GetX reactive state management to update the UI whenever
/// the selected tab changes.
class BottomNavController extends GetxController {

  /// Reactive integer that stores the currently selected tab index.
  /// Using RxInt allows the UI to automatically update when the value changes.
  final RxInt index = 0.obs;

  /// This function is called whenever the user taps a navigation item.
  /// It updates the active tab index.
  void change(int i) {

    /// Prevent unnecessary updates if the selected tab is already active.
    if (index.value == i) return;

    /// Update the current tab index.
    /// All widgets observing this value will automatically rebuild.
    index.value = i;
  }
}