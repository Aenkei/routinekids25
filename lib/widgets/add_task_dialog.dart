import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/widgets/day_selector_widget.dart';
import 'package:dreamflow/widgets/time_period_selector_widget.dart';
import 'package:dreamflow/widgets/premium_pricing_dialog.dart';
import 'package:dreamflow/image_upload.dart';
import 'package:dreamflow/theme.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskDialog({Key? key, this.taskToEdit}) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String _selectedCategory = 'General';
  IconData _selectedIcon = Icons.task_alt;
  Color _selectedIconColor = SpaceColors.nebulaPink;
  List<DayOfWeek> _selectedDays = [];
  String? _assignedUserId;
  int _estimatedMinutes = 15;
  TimePeriod _selectedTimePeriod = TimePeriod.both;
  Uint8List? _customImage;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize with edit data if available
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedCategory = task.category;
      _selectedIcon = task.icon;
      _selectedIconColor = task.iconColor;
      _selectedDays = List.from(task.assignedDays);
      _assignedUserId = task.assignedTo;
      _estimatedMinutes = task.estimatedMinutes;
      _selectedTimePeriod = task.timePeriod;
      _customImage = task.customImage;
    } else {
      // For new tasks, set reasonable defaults with current day selected
      _selectedDays = [Task.today]; // Start with current day selected
      _selectedCategory = 'General';
      _selectedIcon = Icons.task_alt;
      _selectedIconColor = SpaceColors.nebulaPink;
      _selectedTimePeriod = TimePeriod.both;
      _estimatedMinutes = 15;
    }

    // Start animation after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedDays.isEmpty) {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizationService.selectAtLeastOneDay),
          backgroundColor: SpaceColors.nebulaPink,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final dataManager = Provider.of<DataManager>(context, listen: false);
    final premiumManager = Provider.of<PremiumManager>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    // Vérifier les limitations premium pour les nouvelles tâches
    if (widget.taskToEdit == null && !premiumManager.canAddTask(dataManager.tasks.length)) {
      _showPremiumDialog();
      return;
    }

    try {
      final task = Task(
        id: widget.taskToEdit?.id ?? _uuid.v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        iconColor: _selectedIconColor,
        assignedDays: _selectedDays,
        assignedTo: _assignedUserId,
        category: _selectedCategory,
        estimatedMinutes: _estimatedMinutes,
        timePeriod: _selectedTimePeriod,
        customImage: _customImage,
      );

      if (widget.taskToEdit != null) {
        dataManager.updateTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizationService.taskUpdated),
            backgroundColor: SpaceColors.galaxyGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        dataManager.addTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizationService.taskCreated),
            backgroundColor: SpaceColors.galaxyGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      _closeDialog();
    } catch (e) {
      if (e is PremiumLimitationException) {
        _showPremiumDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _closeDialog() {
    if (mounted) {
      _slideController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isLoadingImage = true);
    try {
      final imageBytes = await ImageUploadHelper.pickImageFromGallery();
      if (imageBytes != null) {
        setState(() => _customImage = imageBytes);
      }
    } catch (e) {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizationService.error}: $e'),
          backgroundColor: SpaceColors.nebulaPinkDark,
        ),
      );
    } finally {
      setState(() => _isLoadingImage = false);
    }
  }

  Future<void> _captureImage() async {
    setState(() => _isLoadingImage = true);
    try {
      final imageBytes = await ImageUploadHelper.captureImage();
      if (imageBytes != null) {
        setState(() => _customImage = imageBytes);
      }
    } catch (e) {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizationService.error}: $e'),
          backgroundColor: SpaceColors.nebulaPinkDark,
        ),
      );
    } finally {
      setState(() => _isLoadingImage = false);
    }
  }

  void _removeCustomImage() {
    setState(() => _customImage = null);
  }

  void _showImageOptions() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: SpaceColors.cardGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SpaceColors.starWhiteTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              localizationService.chooseImage,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildImageOption(
              icon: Icons.photo_library,
              title: localizationService.gallery,
              subtitle: localizationService.chooseFromGalleryDescription,
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            _buildImageOption(
              icon: Icons.camera_alt,
              title: localizationService.camera,
              subtitle: localizationService.takePhotoDescription,
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            if (_customImage != null)
              _buildImageOption(
                icon: Icons.delete,
                title: localizationService.removeImage,
                subtitle: localizationService.removeCustomImage,
                onTap: () {
                  Navigator.pop(context);
                  _removeCustomImage();
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: SpaceColors.nebulaGradient,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          icon,
          color: SpaceColors.starWhite,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: SpaceColors.spaceGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildTaskBasics(),
                          const SizedBox(height: 24),
                          _buildCategorySelection(),
                          const SizedBox(height: 24),
                          _buildImageSelection(),
                          const SizedBox(height: 24),
                          _buildIconSelection(),
                          const SizedBox(height: 24),
                          _buildDaySelection(),
                          const SizedBox(height: 24),
                          _buildTimePeriodSelection(),
                          const SizedBox(height: 24),
                          _buildUserAssignment(),
                          const SizedBox(height: 40),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: _closeDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SpaceColors.darkMatter.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: SpaceColors.starWhite,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.taskToEdit != null ? localizationService.editTask : localizationService.newTask,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskBasics() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            TextFormField(
              controller: _titleController,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SpaceColors.starWhite,
              ),
              decoration: InputDecoration(
                labelText: '${localizationService.taskTitle} *',
                hintText: localizationService.isFrench ? 'Entrer le nom de la tâche...' : 'Enter task name...',
                prefixIcon: Icon(
                  Icons.edit,
                  color: SpaceColors.nebulaPink,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizationService.pleaseEnterTitle;
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SpaceColors.starWhite,
              ),
              decoration: InputDecoration(
                labelText: '${localizationService.taskDescription} (${localizationService.isFrench ? 'Optionnel' : 'Optional'})',
                hintText: localizationService.isFrench ? 'Ajouter plus de détails...' : 'Add more details...',
                prefixIcon: Icon(
                  Icons.description,
                  color: SpaceColors.cosmicBlue,
                ),
              ),
              maxLines: 3,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelection() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.category,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.categories.map((category) {
                final isSelected = _selectedCategory == category.englishName;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.englishName;
                      _selectedIcon = category.icon;
                      _selectedIconColor = category.color;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? category.color.withOpacity(0.3) : SpaceColors.darkMatter,
                      border: Border.all(
                        color: isSelected ? category.color : SpaceColors.spacePurple.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          color: category.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizationService.getCategoryName(category.englishName),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SpaceColors.starWhite,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageSelection() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.customImage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpaceColors.darkMatter,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpaceColors.spacePurple.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  if (_customImage != null) ...[
                    // Image preview
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: MemoryImage(_customImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Edit/Remove buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showImageOptions,
                            icon: const Icon(Icons.edit, color: SpaceColors.starWhite),
                            label: Text(
                              localizationService.edit,
                              style: TextStyle(color: SpaceColors.starWhite),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: SpaceColors.nebulaPink),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeCustomImage,
                            icon: const Icon(Icons.delete, color: SpaceColors.nebulaPinkDark),
                            label: Text(
                              localizationService.delete,
                              style: TextStyle(color: SpaceColors.nebulaPinkDark),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: SpaceColors.nebulaPinkDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Add image button
                    GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: SpaceColors.spaceBlackLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: SpaceColors.nebulaPink.withOpacity(0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoadingImage) ...[
                              const CircularProgressIndicator(
                                color: SpaceColors.nebulaPink,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                localizationService.loading,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SpaceColors.starWhiteSecondary,
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.add_a_photo,
                                color: SpaceColors.nebulaPink,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizationService.addImage,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SpaceColors.starWhiteSecondary,
                                ),
                              ),
                              Text(
                                localizationService.tapToChoose,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: SpaceColors.starWhiteTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconSelection() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.chooseIcon,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpaceColors.darkMatter,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpaceColors.spacePurple.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  // Current selection
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedIconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedIconColor),
                    ),
                    child: Icon(
                      _selectedIcon,
                      color: _selectedIconColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildIconCategories(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaySelection() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.selectDays,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DaySelectorWidget(
              selectedDays: _selectedDays,
              onSelectionChanged: (days) {
                setState(() {
                  _selectedDays = days;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimePeriodSelection() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.timePeriod,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TimePeriodSelectorWidget(
              selectedPeriod: _selectedTimePeriod,
              onSelectionChanged: (period) {
                setState(() {
                  _selectedTimePeriod = period;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserAssignment() {
    return Consumer2<LocalizationService, DataManager>(
      builder: (context, localizationService, dataManager, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign to User (Optional)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpaceColors.darkMatter,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpaceColors.spacePurple.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  // None option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _assignedUserId = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _assignedUserId == null ? SpaceColors.nebulaPink.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _assignedUserId == null ? SpaceColors.nebulaPink : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_off,
                            color: SpaceColors.starWhite,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'No assignment',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SpaceColors.starWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // User options
                  ...dataManager.users.map((user) {
                    final isSelected = _assignedUserId == user.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _assignedUserId = user.id;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? SpaceColors.nebulaPink.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? SpaceColors.nebulaPink : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: SpaceColors.cosmicBlue,
                                backgroundImage: user.profilePicture != null
                                    ? MemoryImage(user.profilePicture!)
                                    : null,
                                child: user.profilePicture == null
                                    ? Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          color: SpaceColors.starWhite,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                user.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SpaceColors.starWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeEstimate() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.estimatedDuration,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _estimatedMinutes > 5 ? () {
                    setState(() {
                      _estimatedMinutes -= 5;
                    });
                  } : null,
                  icon: const Icon(Icons.remove, color: SpaceColors.starWhite),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: SpaceColors.darkMatter,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      localizationService.getMinutes(_estimatedMinutes),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _estimatedMinutes < 120 ? () {
                    setState(() {
                      _estimatedMinutes += 5;
                    });
                  } : null,
                  icon: const Icon(Icons.add, color: SpaceColors.starWhite),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeDialog,
                child: Text(localizationService.cancel, style: const TextStyle(color: SpaceColors.starWhite)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveTask,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.taskToEdit != null ? Icons.update : Icons.add,
                      color: SpaceColors.starWhite,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.taskToEdit != null ? localizationService.update : localizationService.create,
                      style: const TextStyle(color: SpaceColors.starWhite),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconCategories() {
    final personalIcons = [Icons.person, Icons.face, Icons.wc, Icons.brush, Icons.shower];
    final schoolIcons = [Icons.school, Icons.book, Icons.edit, Icons.calculate, Icons.science];
    final choreIcons = [Icons.cleaning_services, Icons.kitchen, Icons.bed, Icons.local_laundry_service, Icons.yard];
    final healthIcons = [Icons.fitness_center, Icons.directions_run, Icons.local_drink, Icons.medication, Icons.spa];
    final creativeIcons = [Icons.palette, Icons.music_note, Icons.camera_alt, Icons.draw, Icons.theater_comedy];
    final generalIcons = [Icons.task_alt, Icons.check_circle, Icons.star, Icons.favorite, Icons.emoji_events];

    final colors = [
      SpaceColors.nebulaPink,
      SpaceColors.cosmicBlue,
      SpaceColors.starYellow,
      SpaceColors.galaxyGreen,
      SpaceColors.spacePurple,
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildIconSection('Personal', personalIcons, colors),
          const SizedBox(height: 12),
          _buildIconSection('School', schoolIcons, colors),
          const SizedBox(height: 12),
          _buildIconSection('Chores', choreIcons, colors),
          const SizedBox(height: 12),
          _buildIconSection('Health', healthIcons, colors),
          const SizedBox(height: 12),
          _buildIconSection('Creative', creativeIcons, colors),
          const SizedBox(height: 12),
          _buildIconSection('General', generalIcons, colors),
        ],
      ),
    );
  }

  Widget _buildIconSection(String title, List<IconData> icons, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: SpaceColors.starWhiteSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((icon) {
            // Use the category's typical color
            final color = colors[icons.indexOf(icon) % colors.length];
            final isSelected = _selectedIcon == icon && _selectedIconColor == color;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = icon;
                  _selectedIconColor = color;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? color : SpaceColors.spacePurple.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  void _showPremiumDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumPricingDialog(
        limitationType: PremiumLimitationType.tasks,
        onUpgrade: () {
          // Après l'upgrade, permettre la sauvegarde
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _saveTask();
          });
        },
      ),
    );
  }
}
