import 'package:hive_flutter/hive_flutter.dart';
import '../models/tracker_model.dart';

/// Сервіс локального збереження трекерів в Hive
/// Імплементує Repository Pattern для абстракції джерела даних
/// 
/// SOLID принципи:
/// - Single Responsibility: Лише робота з Hive БД
/// - Dependency Inversion: Залежить від інтерфейсів, не конкретних реалізацій
class StorageService {
  static const String _boxName = 'trackers_box';
  static const String _settingsBoxName = 'settings_box';
  
  late Box<TrackerModel> _trackerBox;
  late Box<dynamic> _settingsBox;
  
  bool _isInitialized = false;

  /// Ініціалізація Hive та відкриття боксів
  /// Викликається один раз при запуску додатка
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Реєстрація адаптерів для Hive
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TrackerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TrackerTypeAdapter());
    }

    // Ініціалізація Hive через Hive Flutter, яка підтримує мобільні та веб платформи
    await Hive.initFlutter();

    // Відкриття боксів
    _trackerBox = await Hive.openBox<TrackerModel>(_boxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    
    _isInitialized = true;
  }

  /// Додавання нового трекера до БД
  Future<void> addTracker(TrackerModel tracker) async {
    await _trackerBox.put(tracker.id, tracker);
  }

  /// Отримання всіх трекерів
  List<TrackerModel> getAllTrackers() {
    return _trackerBox.values.toList();
  }

  /// Отримання трекера за ID
  TrackerModel? getTracker(String id) {
    return _trackerBox.get(id);
  }

  /// Оновлення існуючого трекера
  Future<void> updateTracker(TrackerModel tracker) async {
    await _trackerBox.put(tracker.id, tracker);
  }

  /// Видалення трекера за ID
  Future<void> deleteTracker(String id) async {
    await _trackerBox.delete(id);
  }

  /// Отримання кількості трекерів
  int getTrackersCount() {
    return _trackerBox.length;
  }

  /// Видалення всіх трекерів (для тестування)
  Future<void> clearAllTrackers() async {
    await _trackerBox.clear();
  }

  /// Видалення всіх даних (аварійний скид)
  Future<void> clearAll() async {
    await _trackerBox.clear();
    await _settingsBox.clear();
  }

  /// Закриття боксів
  Future<void> close() async {
    await _trackerBox.close();
    await _settingsBox.close();
  }

  /// Отримання всіх трекерів типу "Парні"
  List<TrackerModel> getPairTrackers() {
    return _trackerBox.values
        .where((t) => t.type == TrackerType.pairBond)
        .toList();
  }

  /// Отримання всіх трекерів типу "Одиночні"
  List<TrackerModel> getSingleTrackers() {
    return _trackerBox.values
        .where((t) => t.type == TrackerType.single)
        .toList();
  }

  /// Сортування трекерів за датою (новіші першими)
  List<TrackerModel> getTrackersSortedByDate() {
    final trackers = getAllTrackers();
    trackers.sort((a, b) => b.startDate.compareTo(a.startDate));
    return trackers;
  }

  /// Сортування трекерів за кількістю днів (найбільше днів першими)
  List<TrackerModel> getTrackersSortedByDays() {
    final trackers = getAllTrackers();
    trackers.sort((a, b) => b.daysPassed.compareTo(a.daysPassed));
    return trackers;
  }
}
