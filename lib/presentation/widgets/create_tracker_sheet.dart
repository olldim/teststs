import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

///底部меню для створення нового трекера
/// Дозволяє вибрати тип трекера та заповнити дані
class CreateTrackerSheet extends StatefulWidget {
  final Function(String, String, DateTime, String, String, String)
      onCreatePairTracker;
  final Function(String, DateTime, String, String) onCreateSingleTracker;

  const CreateTrackerSheet({
    Key? key,
    required this.onCreatePairTracker,
    required this.onCreateSingleTracker,
  }) : super(key: key);

  @override
  State<CreateTrackerSheet> createState() => _CreateTrackerSheetState();
}

class _CreateTrackerSheetState extends State<CreateTrackerSheet> {
  int _selectedType = 0; // 0: парний, 1: одиночний
  
  // Парний трекер
  final _person1Controller = TextEditingController();
  final _person2Controller = TextEditingController();
  DateTime _pairStartDate = DateTime.now();
  String _pairColor = '#FF006E';
  String? _person1ImagePath;
  String? _person2ImagePath;

  // Одиночний трекер
  final _singleNameController = TextEditingController();
  DateTime _singleStartDate = DateTime.now();
  String _singleColor = '#00D4FF';
  String? _singleImagePath;

  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _person1Controller.dispose();
    _person2Controller.dispose();
    _singleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.xl),
          topRight: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Новий трекер',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Вибір типу трекера
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Пара / Дружба',
                      icon: Icons.favorite,
                      isSelected: _selectedType == 0,
                      onPressed: () =>
                          setState(() => _selectedType = 0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Залежність',
                      icon: Icons.trending_down,
                      isSelected: _selectedType == 1,
                      onPressed: () =>
                          setState(() => _selectedType = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Форма для парного трекера
              if (_selectedType == 0) ...[
                _buildInputField(
                  controller: _person1Controller,
                  hint: "Ім'я першої людини",
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInputField(
                  controller: _person2Controller,
                  hint: "Ім'я другої людини",
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDatePicker(
                  label: 'Дата початку:',
                  selectedDate: _pairStartDate,
                  onDateChanged: (date) =>
                      setState(() => _pairStartDate = date),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildColorPicker(
                  label: 'Колір трекера:',
                  selectedColor: _pairColor,
                  onColorChanged: (color) =>
                      setState(() => _pairColor = color),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildImagePickerButton(
                        label: 'Аватарка 1',
                        imagePath: _person1ImagePath,
                        onPick: () => _pickImage(isPerson1: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildImagePickerButton(
                        label: 'Аватарка 2',
                        imagePath: _person2ImagePath,
                        onPick: () => _pickImage(isPerson1: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildCreateButton(
                  label: 'Створити пару',
                  onPressed: _createPairTracker,
                ),
              ],

              // Форма для одиночного трекера
              if (_selectedType == 1) ...[
                _buildInputField(
                  controller: _singleNameController,
                  hint: 'Назва залежності',
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDatePicker(
                  label: 'Дата начала:',
                  selectedDate: _singleStartDate,
                  onDateChanged: (date) =>
                      setState(() => _singleStartDate = date),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildColorPicker(
                  label: 'Колір трекера:',
                  selectedColor: _singleColor,
                  onColorChanged: (color) =>
                      setState(() => _singleColor = color),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildImagePickerButton(
                  label: 'Іконка',
                  imagePath: _singleImagePath,
                  onPick: _pickSingleImage,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildCreateButton(
                  label: 'Створити трекер',
                  onPressed: _createSingleTracker,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonBlue.withOpacity(0.2)
              : AppColors.darkBg,
          border: Border.all(
            color: isSelected
                ? AppColors.neonBlue
                : AppColors.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.neonBlue
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.neonBlue
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.darkBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: const BorderSide(
            color: AppColors.textSecondary,
            width: 0.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onDateChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.neonBlue,
                  surface: AppColors.darkBg2,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          onDateChanged(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkBg,
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                color: AppColors.neonBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required String selectedColor,
    required Function(String) onColorChanged,
  }) {
    final colors = [
      '#FF006E', // Рожевий
      '#00D4FF', // Блакитний
      '#8E44AD', // Фіолетовий
      '#00D084', // Зелений
      '#FFA500', // Оранжевий
      '#FF6B6B', // Червоний
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: colors.map((color) {
            final isSelected = selectedColor == color;
            return Expanded(
              child: GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Color(int.parse('0xFF${color.replaceFirst("#", "")}')),
                    borderRadius:
                        BorderRadius.circular(AppBorderRadius.md),
                    border: isSelected
                        ? Border.all(
                            color: Colors.white,
                            width: 2,
                          )
                        : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagePickerButton({
    required String label,
    required String? imagePath,
    required VoidCallback onPick,
  }) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkBg,
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Column(
          children: [
            Icon(
              Icons.image,
              color: imagePath != null
                  ? AppColors.neonBlue
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: imagePath != null
                    ? AppColors.neonBlue
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.neonBlue,
              AppColors.neonPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isPerson1}) async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isPerson1) {
            _person1ImagePath = image.path;
          } else {
            _person2ImagePath = image.path;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при виборі зображення: $e')),
      );
    }
  }

  Future<void> _pickSingleImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _singleImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при виборі зображення: $e')),
      );
    }
  }

  void _createPairTracker() {
    if (_person1Controller.text.isEmpty ||
        _person2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заповніть імена обох людей'),
        ),
      );
      return;
    }

    if (_person1ImagePath == null || _person2ImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Завантажте обидві аватарки'),
        ),
      );
      return;
    }

    widget.onCreatePairTracker(
      _person1Controller.text,
      _person2Controller.text,
      _pairStartDate,
      _pairColor,
      _person1ImagePath!,
      _person2ImagePath!,
    );

    Navigator.pop(context);
  }

  void _createSingleTracker() {
    if (_singleNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введіть назву залежності'),
        ),
      );
      return;
    }

    if (_singleImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Завантажте іконку'),
        ),
      );
      return;
    }

    widget.onCreateSingleTracker(
      _singleNameController.text,
      _singleStartDate,
      _singleColor,
      _singleImagePath!,
    );

    Navigator.pop(context);
  }
}
