import '../models/tracker_model.dart';

/// Web implementation of WidgetKitService.
///
/// Home screen widgets and App Group file access are not supported on web,
/// so this implementation is a no-op to allow the app to run in browser.
class WidgetKitService {
  Future<void> initialize() async {}

  Future<void> updatePairTrackerWidget({
    required TrackerModel tracker,
    required String person1ImagePath,
    required String person2ImagePath,
  }) async {}

  Future<void> updateSingleTrackerWidget({
    required TrackerModel tracker,
    required String iconPath,
  }) async {}

  Future<void> removeTrackerWidget(String trackerId) async {}

  Future<List<String>> getActiveWidgetTrackerIds() async => [];

  Future<void> syncAllWidgets(List<TrackerModel> trackers) async {}
}
