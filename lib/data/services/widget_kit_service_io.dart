import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tracker_model.dart';

/// iOS/macOS implementation of WidgetKitService.
///
/// This implementation uses platform-specific file access and HomeWidget.
class WidgetKitService {
  static const String _appGroupId = 'group.com.bondtracker.app';
  static const String _widgetTrackerKeyPrefix = 'widget_tracker_';

  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (e) {
      print('⚠️ HomeWidget initialization error: $e');
    }
  }

  Future<void> updatePairTrackerWidget({
    required TrackerModel tracker,
    required String person1ImagePath,
    required String person2ImagePath,
  }) async {
    if (tracker.type != TrackerType.pairBond) {
      throw ArgumentError('Tracker must be of type pairBond');
    }

    try {
      final person1AppGroupPath = await _copyImageToAppGroup(
        person1ImagePath,
        'avatar_${tracker.id}_person1.jpg',
      );
      final person2AppGroupPath = await _copyImageToAppGroup(
        person2ImagePath,
        'avatar_${tracker.id}_person2.jpg',
      );

      final widgetData = {
        'type': 'pair',
        'trackerId': tracker.id,
        'title': tracker.title,
        'person1Name': tracker.person1Name ?? 'Людина 1',
        'person2Name': tracker.person2Name ?? 'Людина 2',
        'daysTogether': tracker.daysPassed.toString(),
        'formattedTime': tracker.formattedTimeSpan,
        'color': tracker.color,
        'person1ImagePath': person1AppGroupPath,
        'person2ImagePath': person2AppGroupPath,
        'startDate': tracker.startDate.toIso8601String(),
      };

      await HomeWidget.saveWidgetData(
        _widgetTrackerKeyPrefix + tracker.id,
        widgetData,
      );

      await HomeWidget.updateWidget(
        name: 'BondDaysWidgetIntentProvider',
        iOSName: 'BondDaysWidget',
      );

      print('✅ Pair tracker widget updated: ${tracker.title}');
    } catch (e) {
      print('❌ Error updating pair tracker widget: $e');
      rethrow;
    }
  }

  Future<void> updateSingleTrackerWidget({
    required TrackerModel tracker,
    required String iconPath,
  }) async {
    if (tracker.type != TrackerType.single) {
      throw ArgumentError('Tracker must be of type single');
    }

    try {
      final appGroupIconPath = await _copyImageToAppGroup(
        iconPath,
        'icon_${tracker.id}.jpg',
      );

      final widgetData = {
        'type': 'single',
        'trackerId': tracker.id,
        'title': tracker.singleTrackerName ?? tracker.title,
        'daysPassed': tracker.daysPassed.toString(),
        'formattedTime': tracker.formattedTimeSpan,
        'color': tracker.color,
        'iconPath': appGroupIconPath,
        'startDate': tracker.startDate.toIso8601String(),
      };

      await HomeWidget.saveWidgetData(
        _widgetTrackerKeyPrefix + tracker.id,
        widgetData,
      );

      await HomeWidget.updateWidget(
        name: 'BondDaysWidgetIntentProvider',
        iOSName: 'BondDaysWidget',
      );

      print('✅ Single tracker widget updated: ${tracker.title}');
    } catch (e) {
      print('❌ Error updating single tracker widget: $e');
      rethrow;
    }
  }

  Future<void> removeTrackerWidget(String trackerId) async {
    try {
      await HomeWidget.saveWidgetData(
        _widgetTrackerKeyPrefix + trackerId,
        null,
      );

      await HomeWidget.updateWidget(
        name: 'BondDaysWidgetIntentProvider',
        iOSName: 'BondDaysWidget',
      );

      print('✅ Widget removed for tracker: $trackerId');
    } catch (e) {
      print('❌ Error removing widget: $e');
    }
  }

  Future<List<String>> getActiveWidgetTrackerIds() async {
    try {
      return <String>[];
    } catch (e) {
      print('❌ Error getting active widget trackers: $e');
      return [];
    }
  }

  Future<String> _copyImageToAppGroup(
    String sourcePath,
    String fileName,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) {
        throw FileSystemException('Source file not found: $sourcePath');
      }

      final appGroupDir = await _getAppGroupDirectory();
      final imagesDir = Directory('${appGroupDir.path}/images');

      if (!imagesDir.existsSync()) {
        imagesDir.createSync(recursive: true);
      }

      final targetFile = File('${imagesDir.path}/$fileName');
      await sourceFile.copy(targetFile.path);

      print('✅ Image copied to App Group: ${targetFile.path}');
      return targetFile.path;
    } catch (e) {
      print('❌ Error copying image to App Group: $e');
      rethrow;
    }
  }

  Future<Directory> _getAppGroupDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<void> syncAllWidgets(List<TrackerModel> trackers) async {
    try {
      for (final tracker in trackers) {
        if (tracker.isPairTracker) {
          if (tracker.person1AvatarPath != null &&
              tracker.person2AvatarPath != null) {
            await updatePairTrackerWidget(
              tracker: tracker,
              person1ImagePath: tracker.person1AvatarPath!,
              person2ImagePath: tracker.person2AvatarPath!,
            );
          }
        } else if (tracker.isSingleTracker) {
          if (tracker.singleTrackerIconPath != null) {
            await updateSingleTrackerWidget(
              tracker: tracker,
              iconPath: tracker.singleTrackerIconPath!,
            );
          }
        }
      }
      print('✅ All widgets synced successfully');
    } catch (e) {
      print('❌ Error syncing widgets: $e');
    }
  }
}
