import 'package:bondtracker/data/models/tracker_model.dart';
import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/widget_kit_service.dart';

/// Provider для керування станом додатка
/// Імплементує Business Logic Layer (BLL) та зв'язок з сервісами
/// 
/// SOLID принципи:
/// - Single Responsibility: Лише керування станом трекерів
/// - Open/Closed: Легко розширити новими методами без змін існуючого коду
class TrackerProvider extends ChangeNotifier {
  final StorageService _storageService;
  final WidgetKitService _widgetKitService;

  List<TrackerModel> _trackers = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedTrackerId;

  TrackerProvider({
    required StorageService storageService,
    required WidgetKitService widgetKitService,
  })  : _storageService = storageService,
        _widgetKitService = widgetKitService;

  // Геттери
  List<TrackerModel> get trackers => _trackers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedTrackerId => _selectedTrackerId;

  /// Ініціалізація провайдера
  /// Завантажує всі трекери з сховища
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Завантажуємо трекери з Hive
      await _storageService.initialize();
      _trackers = _storageService.getAllTrackers();
      
      // Ініціалізуємо WidgetKit сервіс
      await _widgetKitService.initialize();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Помилка при завантаженні: $e';
      notifyListeners();
    }
  }

  /// Додавання нового трекера
  Future<void> addTracker(TrackerModel tracker) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _storageService.addTracker(tracker);
      _trackers.add(tracker);

      // Оновлюємо віджет
      if (tracker.isPairTracker &&
          tracker.person1AvatarPath != null &&
          tracker.person2AvatarPath != null) {
        await _widgetKitService.updatePairTrackerWidget(
          tracker: tracker,
          person1ImagePath: tracker.person1AvatarPath!,
          person2ImagePath: tracker.person2AvatarPath!,
        );
      } else if (tracker.isSingleTracker &&
          tracker.singleTrackerIconPath != null) {
        await _widgetKitService.updateSingleTrackerWidget(
          tracker: tracker,
          iconPath: tracker.singleTrackerIconPath!,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Помилка при додаванні трекера: $e';
      notifyListeners();
    }
  }

  /// Оновлення існуючого трекера
  Future<void> updateTracker(TrackerModel tracker) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _storageService.updateTracker(tracker);
      
      // Оновлюємо список
      final index = _trackers.indexWhere((t) => t.id == tracker.id);
      if (index >= 0) {
        _trackers[index] = tracker;
      }

      // Оновлюємо віджет
      if (tracker.isPairTracker &&
          tracker.person1AvatarPath != null &&
          tracker.person2AvatarPath != null) {
        await _widgetKitService.updatePairTrackerWidget(
          tracker: tracker,
          person1ImagePath: tracker.person1AvatarPath!,
          person2ImagePath: tracker.person2AvatarPath!,
        );
      } else if (tracker.isSingleTracker &&
          tracker.singleTrackerIconPath != null) {
        await _widgetKitService.updateSingleTrackerWidget(
          tracker: tracker,
          iconPath: tracker.singleTrackerIconPath!,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Помилка при оновленні трекера: $e';
      notifyListeners();
    }
  }

  /// Видалення трекера
  Future<void> deleteTracker(String trackerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _storageService.deleteTracker(trackerId);
      _trackers.removeWhere((t) => t.id == trackerId);
      
      // Видаляємо віджет
      await _widgetKitService.removeTrackerWidget(trackerId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Помилка при видаленні трекера: $e';
      notifyListeners();
    }
  }

  /// Отримання трекера за ID
  TrackerModel? getTrackerById(String id) {
    try {
      return _trackers.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Сортування трекерів за кількістю днів (найбільше першими)
  List<TrackerModel> getTrackersSortedByDays() {
    final sorted = [..._trackers];
    sorted.sort((a, b) => b.daysPassed.compareTo(a.daysPassed));
    return sorted;
  }

  /// Отримання лише парних трекерів
  List<TrackerModel> getPairTrackers() {
    return _trackers.where((t) => t.isPairTracker).toList();
  }

  /// Отримання лише одиночних трекерів
  List<TrackerModel> getSingleTrackers() {
    return _trackers.where((t) => t.isSingleTracker).toList();
  }

  /// Синхронізація всіх віджетів
  /// Викликається при запуску додатка або при явному запиті
  Future<void> syncAllWidgets() async {
    try {
      await _widgetKitService.syncAllWidgets(_trackers);
    } catch (e) {
      print('❌ Error syncing widgets: $e');
    }
  }

  /// Видалення помилки
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Вибір трекера для деталізованого перегляду
  void selectTracker(String trackerId) {
    _selectedTrackerId = int.tryParse(trackerId);
    notifyListeners();
  }

  /// Очищення вибору
  void clearSelection() {
    _selectedTrackerId = null;
    notifyListeners();
  }
}
