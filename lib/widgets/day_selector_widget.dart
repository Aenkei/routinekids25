import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class DaySelectorWidget extends StatefulWidget {
  final List<DayOfWeek> selectedDays;
  final Function(List<DayOfWeek>) onSelectionChanged;
  final bool allowMultipleSelection;
  final bool isCompact;

  const DaySelectorWidget({
    Key? key,
    required this.selectedDays,
    required this.onSelectionChanged,
    this.allowMultipleSelection = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<DaySelectorWidget> createState() => _DaySelectorWidgetState();
}

class _DaySelectorWidgetState extends State<DaySelectorWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Color?>> _colorAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      DayOfWeek.values.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    _scaleAnimations = _controllers.map((controller) =>
      Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    ).toList();
    
    _colorAnimations = _controllers.map((controller) =>
      ColorTween(
        begin: SpaceColors.darkMatter,
        end: SpaceColors.nebulaPink,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
    ).toList();

    // Initialize animations for selected days
    for (int i = 0; i < DayOfWeek.values.length; i++) {
      if (widget.selectedDays.contains(DayOfWeek.values[i])) {
        _controllers[i].value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleDay(DayOfWeek day) {
    final dayIndex = day.index;
    final isSelected = widget.selectedDays.contains(day);
    
    List<DayOfWeek> newSelection;
    
    if (widget.allowMultipleSelection) {
      newSelection = List.from(widget.selectedDays);
      if (isSelected) {
        newSelection.remove(day);
        _controllers[dayIndex].reverse();
      } else {
        newSelection.add(day);
        _controllers[dayIndex].forward();
      }
    } else {
      // Single selection mode
      for (int i = 0; i < _controllers.length; i++) {
        if (i != dayIndex) {
          _controllers[i].reverse();
        }
      }
      
      if (isSelected) {
        newSelection = [];
        _controllers[dayIndex].reverse();
      } else {
        newSelection = [day];
        _controllers[dayIndex].forward();
      }
    }
    
    widget.onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isCompact) ...[
              Text(
                widget.allowMultipleSelection 
                    ? localizationService.selectDays
                    : (localizationService.isFrench ? 'Sélectionner un jour' : 'Select Day'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SpaceColors.starWhite,
                ),
              ),
              const SizedBox(height: 16),
            ],
        
        // Days grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DayOfWeek.values.map((day) {
            final dayIndex = day.index;
            final isSelected = widget.selectedDays.contains(day);
            final isToday = day == Task.today;
            
            return AnimatedBuilder(
              animation: _controllers[dayIndex],
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimations[dayIndex].value,
                  child: GestureDetector(
                    onTap: () => _toggleDay(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: widget.isCompact ? 45 : 60,
                      height: widget.isCompact ? 45 : 60,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? SpaceColors.nebulaGradient
                            : LinearGradient(
                                colors: [
                                  SpaceColors.darkMatter,
                                  SpaceColors.darkMatterLight,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isToday
                              ? SpaceColors.starYellow
                              : isSelected
                                  ? SpaceColors.nebulaPink.withOpacity(0.6)
                                  : SpaceColors.spacePurple.withOpacity(0.3),
                          width: isToday ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: SpaceColors.nebulaPink.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          if (isToday && !isSelected)
                            BoxShadow(
                              color: SpaceColors.starYellow.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.getShortName(localizationService.isFrench),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isSelected 
                                  ? SpaceColors.starWhite
                                  : isToday
                                      ? SpaceColors.starYellow
                                      : SpaceColors.starWhiteSecondary,
                              fontWeight: isSelected || isToday 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                              fontSize: widget.isCompact ? 12 : 14,
                            ),
                          ),
                          
                          if (!widget.isCompact) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? SpaceColors.starWhite
                                    : isToday
                                        ? SpaceColors.starYellow
                                        : Colors.transparent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        
        if (!widget.isCompact && widget.selectedDays.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpaceColors.darkMatterLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: SpaceColors.spacePurple.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizationService.isFrench ? 'Jours sélectionnés :' : 'Selected Days:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceColors.starWhiteSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: widget.selectedDays.map((day) => 
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: SpaceColors.nebulaGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        day.getShortName(localizationService.isFrench),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ],
        
        // Quick selection buttons
        if (widget.allowMultipleSelection && !widget.isCompact) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              _QuickSelectButton(
                label: localizationService.weekdays,
                onPressed: () => _selectWeekdays(),
                isSelected: _isWeekdaysSelected(),
              ),
              const SizedBox(width: 8),
              _QuickSelectButton(
                label: localizationService.weekend,
                onPressed: () => _selectWeekend(),
                isSelected: _isWeekendSelected(),
              ),
              const SizedBox(width: 8),
              _QuickSelectButton(
                label: localizationService.allDays,
                onPressed: () => _selectAllDays(),
                isSelected: _isAllDaysSelected(),
              ),
            ],
          ),
        ],
      ],
    );
      },
    );
  }

  void _selectWeekdays() {
    final weekdays = [
      DayOfWeek.monday,
      DayOfWeek.tuesday,
      DayOfWeek.wednesday,
      DayOfWeek.thursday,
      DayOfWeek.friday,
    ];
    
    _updateAnimations(weekdays);
    widget.onSelectionChanged(weekdays);
  }

  void _selectWeekend() {
    final weekend = [DayOfWeek.saturday, DayOfWeek.sunday];
    _updateAnimations(weekend);
    widget.onSelectionChanged(weekend);
  }

  void _selectAllDays() {
    final allDays = DayOfWeek.values;
    _updateAnimations(allDays);
    widget.onSelectionChanged(allDays);
  }

  void _updateAnimations(List<DayOfWeek> selectedDays) {
    for (int i = 0; i < DayOfWeek.values.length; i++) {
      if (selectedDays.contains(DayOfWeek.values[i])) {
        _controllers[i].forward();
      } else {
        _controllers[i].reverse();
      }
    }
  }

  bool _isWeekdaysSelected() {
    final weekdays = [
      DayOfWeek.monday,
      DayOfWeek.tuesday,
      DayOfWeek.wednesday,
      DayOfWeek.thursday,
      DayOfWeek.friday,
    ];
    return weekdays.every((day) => widget.selectedDays.contains(day)) &&
           widget.selectedDays.length == weekdays.length;
  }

  bool _isWeekendSelected() {
    final weekend = [DayOfWeek.saturday, DayOfWeek.sunday];
    return weekend.every((day) => widget.selectedDays.contains(day)) &&
           widget.selectedDays.length == weekend.length;
  }

  bool _isAllDaysSelected() {
    return widget.selectedDays.length == DayOfWeek.values.length;
  }
}

class _QuickSelectButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const _QuickSelectButton({
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? SpaceColors.nebulaGradient 
              : null,
          color: isSelected 
              ? null 
              : SpaceColors.darkMatterLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? SpaceColors.nebulaPink.withOpacity(0.6)
                : SpaceColors.spacePurple.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected 
                ? SpaceColors.starWhite 
                : SpaceColors.starWhiteSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}