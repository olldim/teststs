# 🏗️ АРХІТЕКТУРА ПРОЄКТУ BONDDAYS

## 📁 СТРУКТУРА ПАПОК (FEATURE-FIRST CLEAN ARCHITECTURE)

```
bondtracker/
│
├── lib/
│   ├── core/                          # Ядро додатка (shared, constants, utils)
│   │   ├── constants/                 # Константи
│   │   ├── extensions/                # Розширення для типів (String, DateTime, etc)
│   │   ├── theme/                     # Глобальна тема (Dark Mode, Glassmorphism)
│   │   │   └── app_theme.dart         # AppColors, AppSpacing, createAppTheme()
│   │   └── utils/                     # Утиліти (validators, helpers)
│   │
│   ├── data/                          # Data Layer (моделі, сервіси, репозиторії)
│   │   ├── models/                    # Сутності даних
│   │   │   └── tracker_model.dart     # Основна модель трекера з JSON serialization
│   │   └── services/                  # Бізнес-логіка роботи з даними
│   │       ├── storage_service.dart   # Локальне сховище (Hive)
│   │       └── widget_kit_service.dart # Інтеграція з iOS WidgetKit (App Groups)
│   │
│   ├── domain/                        # Domain Layer (бізнес-логіка, абстракції)
│   │   └── repositories/              # Інтерфейси репозиторіїв (якщо потрібно)
│   │
│   ├── presentation/                  # Presentation Layer (UI, providers, screens)
│   │   ├── providers/                 # State Management (Provider пакет)
│   │   │   └── tracker_provider.dart  # Керування станом трекерів
│   │   ├── screens/                   # Екрани додатка
│   │   │   └── home_screen.dart       # Головний екран з списком трекерів
│   │   └── widgets/                   # Переносні UI компоненти
│   │       ├── glassmorphic_widgets.dart  # GlassmorphicCard, GlassmorphicButton
│   │       └── create_tracker_sheet.dart  # Bottom Sheet для створення трекера
│   │
│   └── main.dart                      # Точка входу додатка
│
├── ios/                               # iOS-специфічні файли
│   ├── Runner/                        # Основний Flutter app
│   │   ├── Runner.entitlements        # ⚙️ App Groups capability
│   │   ├── GeneralSettings.xcconfig
│   │   └── Info.plist
│   │
│   └── BondDaysWidget/                # ⭐ WidgetKit Extension (НОВИЙ TARGET)
│       ├── BondDaysWidget.swift       # Основний код WidgetKit
│       ├── Info.plist                 # ⚙️ WidgetKit конфіг
│       ├── BondDaysWidget.entitlements # ⚙️ App Groups capability
│       └── Assets.xcassets/           # Іконки для Widget
│
├── android/                           # Android-специфічні файли
│
├── web/                               # Web-специфічні файли
│
├── pubspec.yaml                       # ✅ Залежності Flutter
├── analysis_options.yaml              # Лінтинг правила
│
└── ДОКУМЕНТАЦІЯ:
    ├── XCODE_SETUP_INSTRUCTIONS.md    # 📱 Повна інструкція для XCode
    ├── WIDGETKIT_IMPLEMENTATION.md    # 💻 Деталі реалізації WidgetKit
    ├── ios_BondDaysWidget_Swift_Code.swift  # 📄 Готовий Swift код
    └── PROJECT_ARCHITECTURE.md        # 📐 Цей файл
```

---

## 🎯 ОСНОВНІ ШАРИ (CLEAN ARCHITECTURE)

### 1️⃣ DATA LAYER (`lib/data/`)

**Відповідальність:** Робота з даними (БД, API, локальне сховище)

**Файли:**
- **`models/tracker_model.dart`**
  - Основна сутність `TrackerModel`
  - Поля для парних та одиночних трекерів
  - Обчислення: `daysPassed`, `formattedTimeSpan`
  - JSON serialization для передачі даних
  - Фабрики для створення: `createPairTracker()`, `createSingleTracker()`

- **`services/storage_service.dart`**
  - Інтеграція з Hive (локальна БД)
  - CRUD операції: `addTracker()`, `updateTracker()`, `deleteTracker()`
  - Фільтрування: `getPairTrackers()`, `getSingleTrackers()`
  - Сортування: `getTrackersSortedByDays()`

- **`services/widget_kit_service.dart`**
  - Передача даних через `home_widget` пакет
  - Запис в `NSUserDefaults` (AppGroup)
  - Копіювання зображень в App Group контейнер
  - Оновлення WidgetKit за потребою

### 2️⃣ DOMAIN LAYER (`lib/domain/`)

**Відповідальність:** Бізнес-логіка та абстракції

**Поточна структура:** Майже порожня (репозиторії як інтерфейси - опціонально)

**Можна розширити:**
```dart
abstract class TrackerRepository {
  Future<void> addTracker(TrackerModel tracker);
  Future<TrackerModel?> getTrackerById(String id);
  // ...
}
```

### 3️⃣ PRESENTATION LAYER (`lib/presentation/`)

**Відповідальність:** UI, стан, взаємодія користувача

**Файли:**

- **`providers/tracker_provider.dart`**
  - State Management з `Provider` пакетом
  - Зв'язок з `StorageService` та `WidgetKitService`
  - Методи:
    - `initialize()` - завантаження даних
    - `addTracker()` - додавання трекера
    - `updateTracker()` - оновлення
    - `deleteTracker()` - видалення
    - `syncAllWidgets()` - синхронізація

- **`screens/home_screen.dart`**
  - Головний екран додатка
  - Вкладки: "Всі", "Пари", "Залежності"
  - Список трекерів (`GlassmorphicTrackerCard`)
  - Кнопка додавання (FAB)

- **`widgets/glassmorphic_widgets.dart`**
  - `GlassmorphicTrackerCard` - карта трекера з glassmorphism ефектом
  - `GlassmorphicButton` - кнопка з анімацією
  - Структура:
    - BackdropFilter (blur)
    - LinearGradient (матові кольори)
    - Border з напівпрозорістю
    - ScaleTransition анімація

- **`widgets/create_tracker_sheet.dart`**
  - Bottom Sheet для створення трекера
  - Вибір типу: "Пара" або "Залежність"
  - Введення даних, вибір дати, вибір кольору
  - Завантаження зображень (`image_picker`)

### 4️⃣ CORE LAYER (`lib/core/`)

**Відповідальність:** Спільні ресурси для всього додатка

- **`theme/app_theme.dart`**
  - `AppColors` - палітра (Dark Mode + Neon)
  - `AppSpacing` - інтервали (xs, sm, md, lg, xl, xxl)
  - `AppBorderRadius` - скруглення
  - `AppShadow` - тіні
  - `createAppTheme()` - Material 3 тема

---

## 🔄 ЦЕ ТОЧ ВИСОКА-РІВНЕВОГО ДАТА ФЛОУ

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER INTERACTION                           │
│  (Натиснув на "+", обрав дані, завантажив фото)               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  CreateTrackerSheet (Widget)                    │
│  Зберігає: person1Name, person2Name, date, color, imagePaths  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│            TrackerModel.createPairTracker(...)                  │
│  Створює об'єкт трекера з initial data                         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│         TrackerProvider.addTracker(trackerModel)                │
│  1. StorageService.addTracker() → зберігає в Hive             │
│  2. WidgetKitService.updatePairTrackerWidget() →               │
│     - Копіює аватарки в App Group контейнер                   │
│     - Записує дані в NSUserDefaults                           │
│     - Оновлює iOS Widget                                       │
│  3. notifyListeners() → UI перебудовується                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              HomeScreen UI (Consumer)                           │
│  Отримує оновлені дані від TrackerProvider                     │
│  Перебудовує список трекерів                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│           GlassmorphicTrackerCard (для кожного)                │
│  Відображає: Імена, Серце, Дні, Аватарки                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎨 UI/UX ДИЗАЙН КОНЦЕПЦІЯ

### Тема
- **Основна палітра:** Глибокі темні тони (#0B0C10, #1F2833)
- **Неонові акценти:** Блакитний (#00D4FF), Рожевий (#FF006E), Фіолетовий (#8E44AD)
- **Специальні кольори:** Темно-червоне серце (#8B0000)

### Стиль
- **Glassmorphism:**
  - BackdropFilter (blur σ=10)
  - LinearGradient (напівпрозорість)
  - Border з white.opacity(0.2)
  
### Анімації
- ScaleTransition при клику (1.0 → 0.95)
- Плавні переходи между екранами
- Мікроанімації у віджетах

---

## 📦 ЗАЛЕЖНОСТІ ТА ЇХ ФУНКЦІЇ

| Пакет | Версія | Функція |
|-------|--------|---------|
| `provider` | ^6.0.0 | State Management |
| `hive` | ^2.2.3 | Локальна база даних |
| `hive_flutter` | ^1.1.0 | Flutter адаптер для Hive |
| `home_widget` | ^0.5.0 | Інтеграція з iOS WidgetKit |
| `image_picker` | ^1.1.2 | Вибір зображень з галереї |
| `path_provider` | ^2.1.4 | Шляхи до системних директорій |
| `intl` | ^0.19.0 | Локалізація (дати, часи) |
| `uuid` | ^4.0.0 | Генерація унікальних ID |
| `json_annotation` | ^4.8.1 | JSON serialization декоратори |
| `json_serializable` | ^6.7.1 | JSON code generation (dev) |
| `hive_generator` | ^2.0.0 | Hive code generation (dev) |
| `build_runner` | ^2.4.6 | Запуск code generators |

---

## 🔐 SOLID ПРИНЦИПИ

### Single Responsibility Principle (SRP)
- `StorageService` - лише робота з Hive
- `WidgetKitService` - лише WidgetKit інтеграція
- `TrackerModel` - лише представлення даних
- `TrackerProvider` - лише state management

### Open/Closed Principle (OCP)
- Класи відкриті для розширення (новых методів)
- Закриті для модифікації (існуючих методів)
- Приклад: `TrackerModel` має `copyWith()` замість setter'ів

### Liskov Substitution Principle (LSP)
- Усі моделі можуть замінити одна одну без проблем
- `ChangeNotifier` провайдер слідує контракту

### Interface Segregation Principle (ISP)
- Окремі сервіси для окремих задач
- Клієнти залежать від конкретних інтерфейсів

### Dependency Inversion Principle (DIP)
- `TrackerProvider` залежить від абстракцій сервісів
- Сервіси передаються через конструктор (DI)

---

## 🚀 КРОК-ЗА-КРОКОМ: ЯК ДОДАТИ НОВУ ФІЧУ

### Приклад: Додати редагування трекера

1. **Додати метод в `StorageService`:**
   ```dart
   Future<void> updateTracker(TrackerModel tracker) async {
     await _trackerBox.put(tracker.id, tracker);
   }
   ```

2. **Додати метод в `TrackerProvider`:**
   ```dart
   Future<void> updateTracker(TrackerModel tracker) async {
     // Оновити в сховищі
     await _storageService.updateTracker(tracker);
     // Оновити UI
     final index = _trackers.indexWhere((t) => t.id == tracker.id);
     if (index >= 0) _trackers[index] = tracker;
     // Оновити Widget
     await _widgetKitService.updatePairTrackerWidget(...);
     notifyListeners();
   }
   ```

3. **Створити UI в `home_screen.dart`:**
   ```dart
   onTap: () => _showEditTrackerSheet(tracker)
   ```

4. **Додати `edit_tracker_sheet.dart`:**
   - Майже як `create_tracker_sheet.dart`
   - Але з префіл-заповненими полями

---

## 📱 WIDGETKIT ІНТЕГРАЦІЯ (ДЕТАЛІ)

### Оновлення Widget Цикл

1. **Flutter:** `TrackerProvider.addTracker()`
2. **Flutter → Swift:** `WidgetKitService.updatePairTrackerWidget()`
   - Копіює зображення в App Group
   - Записує дані в `NSUserDefaults(suiteName: "group.com.bondtracker.app")`
3. **Swift (WidgetKit):** `BondDaysProvider.getTimeline()`
   - Читає `NSUserDefaults`
   - Парсить JSON
   - Завантажує зображення
4. **Swift UI:** `PairTrackerWidgetView` / `SingleTrackerWidgetView`
   - Відображає на Home Screen

### App Groups Container

- **Шлях (iOS):** `/var/mobile/Containers/Shared/AppGroup/group.com.bondtracker.app/`
- **Зображення:** Поддиректорія `/images/`
- **UserDefaults:** Ключ `active_widget_tracker` (JSON)

---

## ⚡ ПОДАЛЬШІ ПОКРАЩЕННЯ

### Можливо Додати:
- ✅ Синхронізація з хмаро сервісом (Firebase)
- ✅ Сповіщення в певні дні
- ✅ Експорт/Імпорт даних
- ✅ Темне/Світле перемикання (вже підтримується)
- ✅ Multi-language підтримка
- ✅ Темати з вибором кольорів
- ✅ Статистика та графіки
- ✅ Спільне користування трекерами
- ✅ Інтеграція з Apple Watch
- ✅ Siri Shortcuts

---

## 📚 ПОСИЛАННЯ НА ВИХІДНИЙ КОД

- [TrackerModel](../lib/data/models/tracker_model.dart) - Модель даних
- [StorageService](../lib/data/services/storage_service.dart) - Зберігання
- [WidgetKitService](../lib/data/services/widget_kit_service.dart) - Widget інтеграція
- [AppTheme](../lib/core/theme/app_theme.dart) - Дизайн система
- [TrackerProvider](../lib/presentation/providers/tracker_provider.dart) - State
- [HomeScreen](../lib/presentation/screens/home_screen.dart) - UI
- [GlassmorphicWidgets](../lib/presentation/widgets/glassmorphic_widgets.dart) - Компоненти

---

## ✅ КОНТРОЛИСТ РОЗРОБКИ

- [x] Flutter Data Model
- [x] Local Storage (Hive)
- [x] WidgetKit Integration
- [x] UI (Glassmorphism)
- [x] State Management (Provider)
- [x] iOS App Groups
- [x] Swift WidgetKit Code
- [ ] Android Widget Support
- [ ] Firebase Sync
- [ ] Unit Tests
- [ ] Integration Tests

---

**Версія:** 1.0  
**Оновлено:** 2026-06-10  
**Автор:** Senior Flutter Developer & iOS Architect
