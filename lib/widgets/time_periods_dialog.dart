import 'package:flutter/material.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/theme.dart';

class TimePeriodsDialog extends StatefulWidget {
  final DataManager dataManager;

  const TimePeriodsDialog({Key? key, required this.dataManager}) : super(key: key);

  @override
  State<TimePeriodsDialog> createState() => _TimePeriodsDialogState();
}

class _TimePeriodsDialogState extends State<TimePeriodsDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  late int _morningStart;
  late int _morningEnd;
  late int _eveningStart;
  late int _eveningEnd;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Initialize with current values
    _morningStart = widget.dataManager.morningStartHour;
    _morningEnd = widget.dataManager.morningEndHour;
    _eveningStart = widget.dataManager.eveningStartHour;
    _eveningEnd = widget.dataManager.eveningEndHour;
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _saveTimePeriods() {
    // Validation
    if (_morningStart >= _morningEnd) {
      _showErrorSnackBar('Morning start time must be before end time');
      return;
    }
    
    if (_eveningStart >= _eveningEnd) {
      _showErrorSnackBar('Evening start time must be before end time');
      return;
    }
    
    widget.dataManager.updateTimePeriods(
      morningStart: _morningStart,
      morningEnd: _morningEnd,
      eveningStart: _eveningStart,
      eveningEnd: _eveningEnd,
    );
    
    Navigator.of(context).pop();
    _showSuccessSnackBar('Time periods updated successfully');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpaceColors.nebulaPinkDark,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpaceColors.galaxyGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: SpaceColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SpaceColors.spacePurple.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: SpaceColors.spacePurple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimePeriodSection('Morning', _morningStart, _morningEnd, 
                        (start) => setState(() => _morningStart = start),
                        (end) => setState(() => _morningEnd = end),
                        Icons.wb_sunny,
                        SpaceColors.starYellow,
                      ),
                      const SizedBox(height: 20),
                      _buildTimePeriodSection('Evening', _eveningStart, _eveningEnd,
                        (start) => setState(() => _eveningStart = start),
                        (end) => setState(() => _eveningEnd = end),
                        Icons.nightlight_round,
                        SpaceColors.nebulaPink,
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SpaceColors.spacePurple.withOpacity(0.8),
            SpaceColors.cosmicBlue.withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 32,
            color: SpaceColors.starWhite,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure Time Periods',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: SpaceColors.starWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set your morning and evening hours',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SpaceColors.starWhiteSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSection(
    String title,
    int startHour,
    int endHour,
    Function(int) onStartChanged,
    Function(int) onEndChanged,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpaceColors.spaceBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SpaceColors.starWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHourSelector(
                  'Start',
                  startHour,
                  onStartChanged,
                  accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHourSelector(
                  'End',
                  endHour,
                  onEndChanged,
                  accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourSelector(
    String label,
    int value,
    Function(int) onChanged,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: SpaceColors.starWhiteSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: accentColor.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: SpaceColors.darkMatter,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SpaceColors.starWhite,
              ),
              items: List.generate(24, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${index.toString().padLeft(2, '0')}:00'),
                  ),
                );
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: SpaceColors.starWhiteSecondary),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: SpaceColors.starWhiteSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveTimePeriods,
            style: ElevatedButton.styleFrom(
              backgroundColor: SpaceColors.nebulaPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Save',
              style: TextStyle(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}