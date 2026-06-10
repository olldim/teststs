import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/tracker_model.dart';
import '../../presentation/providers/tracker_provider.dart';
import '../../presentation/widgets/glassmorphic_widgets.dart';
import '../widgets/create_tracker_sheet.dart';

/// Головний екран додатка BondDays
/// Відображає список всіх трекерів та надає можливість їх керування
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо провайдер при запуску
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text(
          '❤️ BondDays',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<TrackerProvider>(
        builder: (context, trackerProvider, _) {
          if (trackerProvider.isLoading && trackerProvider.trackers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.neonBlue,
                ),
              ),
            );
          }

          if (trackerProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      trackerProvider.errorMessage ?? 'Невідома помилка',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassmorphicButton(
                    label: 'Спробувати ще раз',
                    onPressed: () {
                      trackerProvider.clearError();
                      trackerProvider.initialize();
                    },
                  ),
                ],
              ),
            );
          }

          final allTrackers = trackerProvider.getTrackersSortedByDays();
          final pairTrackers =
              trackerProvider.getPairTrackers().toList()
                ..sort((a, b) => b.daysPassed.compareTo(a.daysPassed));
          final singleTrackers =
              trackerProvider.getSingleTrackers().toList()
                ..sort((a, b) => b.daysPassed.compareTo(a.daysPassed));

          return Column(
            children: [
              // Вкладки
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      label: 'Всі (${allTrackers.length})',
                      isSelected: _selectedTabIndex == 0,
                      onPressed: () =>
                          setState(() => _selectedTabIndex = 0),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTabButton(
                      label: 'Пари (${pairTrackers.length})',
                      isSelected: _selectedTabIndex == 1,
                      onPressed: () =>
                          setState(() => _selectedTabIndex = 1),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTabButton(
                      label: 'Залежності (${singleTrackers.length})',
                      isSelected: _selectedTabIndex == 2,
                      onPressed: () =>
                          setState(() => _selectedTabIndex = 2),
                    ),
                  ],
                ),
              ),
              // Список трекерів
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildTrackerList(allTrackers, trackerProvider)
                    : _selectedTabIndex == 1
                        ? _buildTrackerList(pairTrackers, trackerProvider)
                        : _buildTrackerList(
                            singleTrackers, trackerProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          _showCreateTrackerSheet(context);
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            gradient: const LinearGradient(
              colors: [
                AppColors.neonBlue,
                AppColors.neonPurple,
              ],
            ),
            boxShadow: AppShadow.glassDark,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// Побудова кнопки вкладки
  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonBlue.withOpacity(0.2)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? AppColors.neonBlue
                    : AppColors.textSecondary.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppColors.neonBlue
                  : AppColors.textSecondary,
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// Побудова списку трекерів
  Widget _buildTrackerList(
    List<TrackerModel> trackers,
    TrackerProvider provider,
  ) {
    if (trackers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Немає трекерів',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Натисніть кнопку + щоб створити перший трекер',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xxl,
      ),
      itemCount: trackers.length,
      itemBuilder: (context, index) {
        final tracker = trackers[index];
        return GlassmorphicTrackerCard(
          tracker: tracker,
          onTap: () {
            // Можна додати екран деталей трекера
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Обрано: ${tracker.title}'),
                backgroundColor: AppColors.neonBlue,
              ),
            );
          },
          onDelete: () {
            // Підтвердження видалення
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.darkBg2,
                title: const Text(
                  'Видалити трекер?',
                  style:
                      TextStyle(color: AppColors.textPrimary),
                ),
                content: Text(
                  'Трекер "${tracker.title}" буде видалено назавжди.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Скасувати'),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.deleteTracker(tracker.id);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Видалити',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Показ меню створення трекера
  void _showCreateTrackerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CreateTrackerSheet(
        onCreatePairTracker:
            (person1Name, person2Name, startDate, color, p1Image, p2Image) {
          final tracker = TrackerModel.createPairTracker(
            id: const Uuid().v4(),
            person1Name: person1Name,
            person2Name: person2Name,
            startDate: startDate,
            color: color,
            person1AvatarPath: p1Image,
            person2AvatarPath: p2Image,
          );
          context.read<TrackerProvider>().addTracker(tracker);
        },
        onCreateSingleTracker: (name, startDate, color, iconPath) {
          final tracker = TrackerModel.createSingleTracker(
            id: const Uuid().v4(),
            name: name,
            startDate: startDate,
            color: color,
            iconPath: iconPath,
          );
          context.read<TrackerProvider>().addTracker(tracker);
        },
      ),
    );
  }
}
