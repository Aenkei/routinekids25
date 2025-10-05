import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/widgets/premium_pricing_dialog.dart';
import 'package:dreamflow/image_upload.dart';
import 'package:dreamflow/theme.dart';

class AddUserDialog extends StatefulWidget {
  final User? userToEdit;

  const AddUserDialog({Key? key, this.userToEdit}) : super(key: key);

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = const Uuid();

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  Uint8List? _profilePicture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    if (widget.userToEdit != null) {
      _nameController.text = widget.userToEdit!.name;
      _profilePicture = widget.userToEdit!.profilePicture;
    }

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true);
      final imageBytes = await ImageUploadHelper.pickImageFromGallery();
      if (imageBytes != null) {
        print('Image picked from gallery: ${imageBytes.length} bytes');
        setState(() {
          _profilePicture = imageBytes;
        });
      } else {
        print('No image picked from gallery');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: \$e'),
            backgroundColor: SpaceColors.nebulaPink,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _captureImage() async {
    try {
      setState(() => _isLoading = true);
      final imageBytes = await ImageUploadHelper.captureImage();
      if (imageBytes != null) {
        print('Image captured: ${imageBytes.length} bytes');
        setState(() {
          _profilePicture = imageBytes;
        });
      } else {
        print('No image captured');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: \$e'),
            backgroundColor: SpaceColors.nebulaPink,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _saveUser() {
    if (!_formKey.currentState!.validate()) return;

    final dataManager = Provider.of<DataManager>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final premiumManager = Provider.of<PremiumManager>(context, listen: false);

    // Check premium limitations for new users
    if (widget.userToEdit == null && !premiumManager.canAddUser(dataManager.users.length)) {
      _showPremiumDialog();
      return;
    }

    setState(() => _isLoading = true);

    print('Creating user with profile picture: ${_profilePicture != null ? 'Yes (${_profilePicture!.length} bytes)' : 'No'}');

    final user = User(
      id: widget.userToEdit?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      profilePicture: _profilePicture,
      createdAt: widget.userToEdit?.createdAt,
      currentStreak: widget.userToEdit?.currentStreak ?? 0,
      longestStreak: widget.userToEdit?.longestStreak ?? 0,
      weeklyProgress: widget.userToEdit?.weeklyProgress ?? {},
      totalTasksCompleted: widget.userToEdit?.totalTasksCompleted ?? 0,
      favoriteCategory: widget.userToEdit?.favoriteCategory ?? 'General',
      achievements: widget.userToEdit?.achievements ?? [],
    );

    if (widget.userToEdit == null) {
      dataManager.addUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizationService.userCreated),
          backgroundColor: SpaceColors.galaxyGreen,
        ),
      );
      
      // If this was the first user created from onboarding, navigate to main app
      if (dataManager.users.length == 1) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        return;
      }
    } else {
      dataManager.updateUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizationService.userUpdated),
          backgroundColor: SpaceColors.galaxyGreen,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400), // Réduit de 400x500 à 320x400
          decoration: BoxDecoration(
            gradient: SpaceColors.cardGradient,
            borderRadius: BorderRadius.circular(20), // Réduit de 24 à 20
            border: Border.all(
              color: SpaceColors.spacePurple.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: SpaceColors.nebulaPink.withOpacity(0.3),
                blurRadius: 16, // Réduit de 20 à 16
                offset: const Offset(0, 8), // Réduit de 10 à 8
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16), // Réduit de 24 à 16
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildProfilePictureSection(),
                        const SizedBox(height: 16), // Réduit de 24 à 16
                        _buildNameField(),
                        const SizedBox(height: 20), // Réduit de 32 à 20
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16), // Réduit de 24 à 16
      decoration: const BoxDecoration(
        gradient: SpaceColors.nebulaGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), // Réduit de 24 à 20
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Réduit de 8 à 6
            decoration: BoxDecoration(
              color: SpaceColors.starWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8), // Réduit de 12 à 8
            ),
            child: const Icon(
              Icons.person_add,
              color: SpaceColors.starWhite,
              size: 20, // Réduit de 24 à 20
            ),
          ),
          const SizedBox(width: 12), // Réduit de 16 à 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userToEdit != null ? 'Edit Crew Member' : 'Add New Crew Member',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Réduit de 22 à 18
                  ),
                ),
                const SizedBox(height: 2), // Réduit de 4 à 2
                Text(
                  widget.userToEdit != null 
                      ? 'Update member details'
                      : 'Create a new space explorer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceColors.starWhite.withOpacity(0.8),
                    fontSize: 12, // Réduit de 14 à 12
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageOptions,
          child: Container(
            width: 80, // Réduit de 120 à 80
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _profilePicture == null 
                  ? SpaceColors.spaceGradient
                  : null,
              border: Border.all(
                color: SpaceColors.nebulaPink,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: SpaceColors.nebulaPink.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: SpaceColors.starWhite,
                      strokeWidth: 2,
                    ),
                  )
                : _profilePicture != null && _profilePicture!.isNotEmpty
                    ? ClipOval(
                        child: Image.memory(
                          _profilePicture!,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error displaying profile picture preview: $error');
                            return const Icon(
                              Icons.person_add,
                              size: 32,
                              color: SpaceColors.starWhite,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person_add,
                        size: 32, // Réduit de 48 à 32
                        color: SpaceColors.starWhite,
                      ),
          ),
        ),
        const SizedBox(height: 12), // Réduit de 16 à 12
        Text(
          _profilePicture == null 
              ? 'Tap to add photo'
              : 'Tap to change photo',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: SpaceColors.starWhiteSecondary,
            fontSize: 11, // Réduit de 12 à 11
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: SpaceColors.starWhite,
      ),
      decoration: InputDecoration(
        labelText: 'Name',
        prefixIcon: const Icon(
          Icons.person,
          color: SpaceColors.nebulaPink,
          size: 20, // Réduit de 24 à 20
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Réduit le padding
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12), // Réduit de 16 à 12
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: SpaceColors.starWhite,
                fontSize: 14, // Réduit de 16 à 14
              ),
            ),
          ),
        ),
        const SizedBox(width: 12), // Réduit de 16 à 12
        Expanded(
          child: ElevatedButton(
            onPressed: _saveUser,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12), // Réduit de 16 à 12
            ),
            child: Text(
              widget.userToEdit != null ? 'Update' : 'Add',
              style: TextStyle(
                color: SpaceColors.starWhite,
                fontSize: 14, // Réduit de 16 à 14
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: SpaceColors.cardGradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16), // Réduit de 24 à 16
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SpaceColors.starWhiteTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16), // Réduit de 20 à 16
            Text(
              'Choose Photo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Réduit de 20 à 16
            _buildImageOption(
              icon: Icons.camera_alt,
              title: 'Camera',
              subtitle: 'Take a new photo',
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            const SizedBox(height: 12), // Réduit de 16 à 12
            _buildImageOption(
              icon: Icons.photo_library,
              title: 'Gallery',
              subtitle: 'Choose from gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            const SizedBox(height: 16), // Réduit de 20 à 16
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), // Réduit de 16 à 12
        decoration: BoxDecoration(
          color: SpaceColors.darkMatter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SpaceColors.spacePurple.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Réduit de 12 à 8
              decoration: BoxDecoration(
                gradient: SpaceColors.nebulaGradient,
                borderRadius: BorderRadius.circular(8), // Réduit de 12 à 8
              ),
              child: Icon(
                icon,
                color: SpaceColors.starWhite,
                size: 20, // Réduit de 24 à 20
              ),
            ),
            const SizedBox(width: 12), // Réduit de 16 à 12
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: SpaceColors.starWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SpaceColors.starWhiteSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPremiumDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumPricingDialog(
        limitationType: PremiumLimitationType.users,
        onUpgrade: () {
          // Après l'upgrade, permettre la création de l'utilisateur
          _saveUser();
        },
      ),
    );
  }
}