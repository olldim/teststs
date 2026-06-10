import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tracker_model.g.dart';

/// Тип трекера
/// [pairBond] - Парні трекери (відносини, дружба)
/// [single] - Одиночні трекери (залежності, звички)
enum TrackerType {
  pairBond,
  single,
}

/// Модель даних для трекера - основна сутність додатка
/// Зберігає інформацію про подію, відносини або залежність
/// 
/// Вимоги SOLID:
/// - Single Responsibility: Лише представляє дані трекера
/// - Інший код обробляє зберігання та обчислення часу
@HiveType(typeId: 0)
@JsonSerializable()
class TrackerModel extends HiveObject {
  /// Унікальний ідентифікатор трекера
  @HiveField(0)
  late String id;

  /// Тип трекера (парний або одиночний)
  @HiveField(1)
  late TrackerType type;

  /// Назва трекера (видима користувачеві)
  @HiveField(2)
  late String title;

  /// Дата початку/відліку
  @HiveField(3)
  late DateTime startDate;

  /// Опис (опціонально)
  @HiveField(4)
  late String? description;

  /// Колір трекера в форматі HEX (наприклад, #FF6B9D)
  @HiveField(5)
  late String color;

  /// ===== ПОЛЯ ДЛЯ ПАРНОГО ТРЕКЕРА =====

  /// Ім'я першої людини (для пар)
  @HiveField(6)
  late String? person1Name;

  /// Ім'я другої людини (для пар)
  @HiveField(7)
  late String? person2Name;

  /// Шлях до аватарки першої людини (в App Group контейнері)
  @HiveField(8)
  late String? person1AvatarPath;

  /// Шлях до аватарки другої людини (в App Group контейнері)
  @HiveField(9)
  late String? person2AvatarPath;

  /// ===== ПОЛЯ ДЛЯ ОДИНОЧНОГО ТРЕКЕРА =====

  /// Назва залежності/звички
  @HiveField(10)
  late String? singleTrackerName;

  /// Шлях до іконки/аватарки (в App Group контейнері)
  @HiveField(11)
  late String? singleTrackerIconPath;

  /// Дата створення в базі даних
  @HiveField(12)
  late DateTime createdAt;

  /// Дата останнього оновлення
  @HiveField(13)
  late DateTime updatedAt;

  // Конструктор за замовчуванням
  TrackerModel({
    required this.id,
    required this.type,
    required this.title,
    required this.startDate,
    this.description,
    required this.color,
    this.person1Name,
    this.person2Name,
    this.person1AvatarPath,
    this.person2AvatarPath,
    this.singleTrackerName,
    this.singleTrackerIconPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Конструктор для парного трекера (Відносини/Дружба)
  factory TrackerModel.createPairTracker({
    required String id,
    required String person1Name,
    required String person2Name,
    required DateTime startDate,
    required String color,
    String? person1AvatarPath,
    String? person2AvatarPath,
    String? description,
  }) {
    return TrackerModel(
      id: id,
      type: TrackerType.pairBond,
      title: '$person1Name & $person2Name',
      startDate: startDate,
      color: color,
      person1Name: person1Name,
      person2Name: person2Name,
      person1AvatarPath: person1AvatarPath,
      person2AvatarPath: person2AvatarPath,
      description: description,
    );
  }

  /// Конструктор для одиночного трекера (Залежність/Звичка)
  factory TrackerModel.createSingleTracker({
    required String id,
    required String name,
    required DateTime startDate,
    required String color,
    String? iconPath,
    String? description,
  }) {
    return TrackerModel(
      id: id,
      type: TrackerType.single,
      title: name,
      startDate: startDate,
      color: color,
      singleTrackerName: name,
      singleTrackerIconPath: iconPath,
      description: description,
    );
  }

  /// Обчислює кількість днів, що минули з моменту startDate
  /// Критично важливо для парних трекерів - саме "Дні разом"
  int get daysPassed {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    return difference.inDays;
  }

  /// Форматоване представлення часу у форматі "X років, Y місяців, Z днів"
  /// Використовується для відображення в UI
  String get formattedTimeSpan {
    final now = DateTime.now();
    
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;

    // Коригування днів та місяців при від'ємних значеннях
    if (days < 0) {
      months--;
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return '$years років, $months місяців, $days днів';
  }

  /// Перевірка, чи є це парний трекер
  bool get isPairTracker => type == TrackerType.pairBond;

  /// Перевірка, чи є це одиночний трекер
  bool get isSingleTracker => type == TrackerType.single;

  /// Копіювання об'єкта з змінами (для оновлення)
  TrackerModel copyWith({
    String? id,
    TrackerType? type,
    String? title,
    DateTime? startDate,
    String? description,
    String? color,
    String? person1Name,
    String? person2Name,
    String? person1AvatarPath,
    String? person2AvatarPath,
    String? singleTrackerName,
    String? singleTrackerIconPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrackerModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      description: description ?? this.description,
      color: color ?? this.color,
      person1Name: person1Name ?? this.person1Name,
      person2Name: person2Name ?? this.person2Name,
      person1AvatarPath: person1AvatarPath ?? this.person1AvatarPath,
      person2AvatarPath: person2AvatarPath ?? this.person2AvatarPath,
      singleTrackerName: singleTrackerName ?? this.singleTrackerName,
      singleTrackerIconPath: singleTrackerIconPath ?? this.singleTrackerIconPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Перетворення на JSON для передачі в WidgetKit
  Map<String, dynamic> toJson() => _$TrackerModelToJson(this);

  /// Створення з JSON
  factory TrackerModel.fromJson(Map<String, dynamic> json) =>
      _$TrackerModelFromJson(json);

  @override
  String toString() => 'TrackerModel('
      'id: $id, '
      'type: $type, '
      'title: $title, '
      'daysPassed: $daysPassed, '
      'formattedTimeSpan: $formattedTimeSpan'
      ')';
}

/// Адаптер для збереження enum в Hive
class TrackerTypeAdapter extends TypeAdapter<TrackerType> {
  @override
  final typeId = 1;

  @override
  TrackerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrackerType.pairBond;
      case 1:
        return TrackerType.single;
      default:
        return TrackerType.single;
    }
  }

  @override
  void write(BinaryWriter writer, TrackerType obj) {
    switch (obj) {
      case TrackerType.pairBond:
        writer.writeByte(0);
        break;
      case TrackerType.single:
        writer.writeByte(1);
        break;
    }
  }
}
