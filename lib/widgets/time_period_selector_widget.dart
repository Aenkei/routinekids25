import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class TimePeriodSelectorWidget extends StatefulWidget {
  final TimePeriod selectedPeriod;
  final Function(TimePeriod) onSelectionChanged;
  final bool isCompact;

  const TimePeriodSelectorWidget({
    Key? key,
    required this.selectedPeriod,
    required this.onSelectionChanged,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<TimePeriodSelectorWidget> createState() => _TimePeriodSelectorWidgetState();
}

class _TimePeriodSelectorWidgetState extends State<TimePeriodSelectorWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Color?>> _colorAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    ));
    
    _scaleAnimations = _controllers.map((controller) => 
      Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ))
    ).toList();
    
    _colorAnimations = _controllers.map((controller) => 
      ColorTween(
        begin: SpaceColors.darkMatter,
        end: SpaceColors.nebulaPink.withOpacity(0.2),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ))
    ).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimations();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateAnimations() {
    for (int i = 0; i < TimePeriod.values.length; i++) {
      if (TimePeriod.values[i] == widget.selectedPeriod) {
        _controllers[i].forward();
      } else {
        _controllers[i].reverse();
      }
    }
  }

  void _selectPeriod(TimePeriod period) {
    widget.onSelectionChanged(period);
    setState(() {
      _updateAnimations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: SpaceColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: SpaceColors.nebulaGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: SpaceColors.starWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                localizationService.selectTimePeriod,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SpaceColors.starWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.isCompact) 
            _buildCompactSelector(localizationService)
          else
            _buildFullSelector(localizationService),
        ],
      ),
    );
  }

  Widget _buildCompactSelector(LocalizationService localizationService) {
    return Wrap(
      spacing: 8,
      children: TimePeriod.values.asMap().entries.map((entry) {
        final index = entry.key;
        final period = entry.value;
        return AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: _buildPeriodChip(period, index, localizationService, true),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFullSelector(LocalizationService localizationService) {
    return Column(
      children: TimePeriod.values.asMap().entries.map((entry) {
        final index = entry.key;
        final period = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AnimatedBuilder(
            animation: _scaleAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: _buildPeriodCard(period, index, localizationService),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodChip(TimePeriod period, int index, LocalizationService localizationService, bool isCompact) {
    final isSelected = widget.selectedPeriod == period;
    
    return GestureDetector(
      onTap: () => _selectPeriod(period),
      child: AnimatedBuilder(
        animation: _colorAnimations[index],
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16,
              vertical: isCompact ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? SpaceColors.nebulaPink : _colorAnimations[index].value,
              borderRadius: BorderRadius.circular(isCompact ? 16 : 12),
              border: Border.all(
                color: isSelected ? SpaceColors.nebulaPink : SpaceColors.spacePurple.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: SpaceColors.nebulaPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getPeriodIcon(period),
                  color: isSelected ? SpaceColors.starWhite : SpaceColors.starWhiteSecondary,
                  size: isCompact ? 16 : 20,
                ),
                const SizedBox(width: 6),
                Text(
                  _getPeriodName(period, localizationService),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? SpaceColors.starWhite : SpaceColors.starWhiteSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodCard(TimePeriod period, int index, LocalizationService localizationService) {
    final isSelected = widget.selectedPeriod == period;
    
    return GestureDetector(
      onTap: () => _selectPeriod(period),
      child: AnimatedBuilder(
        animation: _colorAnimations[index],
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? SpaceColors.nebulaPink.withOpacity(0.2) : _colorAnimations[index].value,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? SpaceColors.nebulaPink : SpaceColors.spacePurple.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: SpaceColors.nebulaPink.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? SpaceColors.nebulaPink : SpaceColors.spacePurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPeriodIcon(period),
                    color: SpaceColors.starWhite,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPeriodName(period, localizationService),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPeriodDescription(period, localizationService),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SpaceColors.starWhiteSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: SpaceColors.galaxyGreen,
                    size: 24,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getPeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.morning:
        return Icons.wb_sunny;
      case TimePeriod.evening:
        return Icons.nights_stay;
      case TimePeriod.both:
        return Icons.all_inclusive;
    }
  }

  String _getPeriodName(TimePeriod period, LocalizationService localizationService) {
    switch (period) {
      case TimePeriod.morning:
        return localizationService.morning;
      case TimePeriod.evening:
        return localizationService.evening;
      case TimePeriod.both:
        return localizationService.both;
    }
  }

  String _getPeriodDescription(TimePeriod period, LocalizationService localizationService) {
    switch (period) {
      case TimePeriod.morning:
        return localizationService.isFrench ? 'Tâches du matin' : 'Morning tasks';
      case TimePeriod.evening:
        return localizationService.isFrench ? 'Tâches du soir' : 'Evening tasks';
      case TimePeriod.both:
        return localizationService.isFrench ? 'Disponible toute la journée' : 'Available all day';
    }
  }
}