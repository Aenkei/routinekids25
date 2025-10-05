import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class ParentalControlDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const ParentalControlDialog({
    Key? key,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<ParentalControlDialog> createState() => _ParentalControlDialogState();
}

class _ParentalControlDialogState extends State<ParentalControlDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successAnimation;

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocus = FocusNode();

  int _firstNumber = 0;
  int _secondNumber = 0;
  int _correctAnswer = 0;
  int _attempts = 0;
  bool _isCorrect = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _generateNewProblem();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _answerController.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  void _generateNewProblem() {
    final random = math.Random();
    
    // Générer des nombres pour une addition simple (5-15 + 3-12)
    _firstNumber = 5 + random.nextInt(11); // 5 à 15
    _secondNumber = 3 + random.nextInt(10); // 3 à 12
    _correctAnswer = _firstNumber + _secondNumber;
    
    setState(() {
      _showError = false;
    });
  }

  void _checkAnswer() {
    final userAnswer = int.tryParse(_answerController.text);
    
    if (userAnswer == null) {
      _showError = true;
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }

    if (userAnswer == _correctAnswer) {
      setState(() {
        _isCorrect = true;
        _showError = false;
      });
      
      _successController.forward();
      
      // Vibration de succès
      HapticFeedback.lightImpact();
      
      // Attendre l'animation puis fermer et naviguer
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pop();
          // Attendre que le dialog soit fermé avant de naviguer
          Future.delayed(const Duration(milliseconds: 100), () {
            widget.onSuccess();
          });
        }
      });
    } else {
      setState(() {
        _attempts++;
        _showError = true;
      });
      
      // Vibration d'erreur
      HapticFeedback.heavyImpact();
      
      _shakeController.forward().then((_) => _shakeController.reset());
      
      // Générer un nouveau problème après 3 tentatives échouées
      if (_attempts >= 3) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _generateNewProblem();
            _answerController.clear();
            setState(() {
              _attempts = 0;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxHeight = mediaQuery.size.height * (isLandscape ? 0.85 : 0.7);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isLandscape ? 500 : 400,
              maxHeight: maxHeight,
            ),
            margin: EdgeInsets.all(isLandscape ? 16 : 24),
            decoration: BoxDecoration(
              gradient: SpaceColors.cardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: SpaceColors.spacePurple.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: SpaceColors.spacePurple.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: _isCorrect 
                ? _buildSuccessContent(localizationService, isLandscape) 
                : _buildQuestionContent(localizationService, isLandscape),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(LocalizationService localizationService, bool isLandscape) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = math.sin(_shakeAnimation.value * 3 * math.pi) * 8;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Padding(
            padding: EdgeInsets.all(isLandscape ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(localizationService, isLandscape),
                SizedBox(height: isLandscape ? 16 : 32),
                _buildMathProblem(localizationService, isLandscape),
                SizedBox(height: isLandscape ? 12 : 24),
                _buildAnswerInput(localizationService, isLandscape),
                if (_showError) ...[
                  SizedBox(height: isLandscape ? 8 : 16),
                  _buildErrorMessage(localizationService, isLandscape),
                ],
                SizedBox(height: isLandscape ? 16 : 32),
                _buildActionButtons(localizationService, isLandscape),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessContent(LocalizationService localizationService, bool isLandscape) {
    return ScaleTransition(
      scale: _successAnimation,
      child: Padding(
        padding: EdgeInsets.all(isLandscape ? 20 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isLandscape ? 60 : 80,
              height: isLandscape ? 60 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SpaceColors.nebulaGradient,
                boxShadow: [
                  BoxShadow(
                    color: SpaceColors.starYellow.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: isLandscape ? 36 : 48,
                color: SpaceColors.starWhite,
              ),
            ),
            SizedBox(height: isLandscape ? 16 : 24),
            Text(
              localizationService.accessGranted,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: SpaceColors.starYellow,
                fontWeight: FontWeight.bold,
                fontSize: isLandscape ? 20 : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isLandscape ? 4 : 8),
            Text(
              localizationService.redirectingToSettings,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SpaceColors.starWhiteSecondary,
                fontSize: isLandscape ? 12 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LocalizationService localizationService, bool isLandscape) {
    return Column(
      children: [
        Container(
          width: isLandscape ? 48 : 64,
          height: isLandscape ? 48 : 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SpaceColors.spaceGradient,
            border: Border.all(
              color: SpaceColors.spacePurple.withOpacity(0.8),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.security_rounded,
            size: isLandscape ? 24 : 32,
            color: SpaceColors.starWhite,
          ),
        ),
        SizedBox(height: isLandscape ? 12 : 16),
        Text(
          localizationService.parentalControl,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: SpaceColors.starWhite,
            fontWeight: FontWeight.bold,
            fontSize: isLandscape ? 20 : null,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isLandscape ? 4 : 8),
        Text(
          localizationService.solveMathProblem,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: SpaceColors.starWhiteSecondary,
            fontSize: isLandscape ? 12 : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMathProblem(LocalizationService localizationService, bool isLandscape) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SpaceColors.spacePurple.withOpacity(0.6),
            SpaceColors.cosmicBlue.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.nebulaPink.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_firstNumber',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: SpaceColors.starYellow,
              fontWeight: FontWeight.bold,
              fontSize: isLandscape ? 32 : null,
            ),
          ),
          SizedBox(width: isLandscape ? 16 : 24),
          Container(
            width: isLandscape ? 32 : 40,
            height: isLandscape ? 32 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SpaceColors.nebulaPink,
            ),
            child: Icon(
              Icons.add_rounded,
              size: isLandscape ? 18 : 24,
              color: SpaceColors.starWhite,
            ),
          ),
          SizedBox(width: isLandscape ? 16 : 24),
          Text(
            '$_secondNumber',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: SpaceColors.starYellow,
              fontWeight: FontWeight.bold,
              fontSize: isLandscape ? 32 : null,
            ),
          ),
          SizedBox(width: isLandscape ? 16 : 24),
          Text(
            '=',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: SpaceColors.starWhite,
              fontWeight: FontWeight.bold,
              fontSize: isLandscape ? 32 : null,
            ),
          ),
          SizedBox(width: isLandscape ? 16 : 24),
          Text(
            '?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: SpaceColors.galaxyGreen,
              fontWeight: FontWeight.bold,
              fontSize: isLandscape ? 32 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(LocalizationService localizationService, bool isLandscape) {
    return Container(
      width: isLandscape ? 100 : 120,
      child: TextField(
        controller: _answerController,
        focusNode: _answerFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: SpaceColors.starWhite,
          fontWeight: FontWeight.bold,
          fontSize: isLandscape ? 24 : null,
        ),
        decoration: InputDecoration(
          hintText: '?',
          hintStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: SpaceColors.starWhiteTertiary,
            fontSize: isLandscape ? 24 : null,
          ),
          fillColor: SpaceColors.darkMatterLight,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _showError ? Colors.red : SpaceColors.nebulaPink,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _showError ? Colors.red.withOpacity(0.6) : SpaceColors.spacePurple.withOpacity(0.6),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _showError ? Colors.red : SpaceColors.nebulaPink,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
        ),
        onSubmitted: (_) => _checkAnswer(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(LocalizationService localizationService, bool isLandscape) {
    String message;
    if (_attempts >= 3) {
      message = localizationService.newProblemGenerated;
    } else {
      message = localizationService.incorrectAnswer;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 12 : 16, 
        vertical: isLandscape ? 6 : 8
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: isLandscape ? 16 : 20,
            color: Colors.red[300],
          ),
          SizedBox(width: isLandscape ? 6 : 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red[300],
              fontSize: isLandscape ? 11 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LocalizationService localizationService, bool isLandscape) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: SpaceColors.starWhiteTertiary),
              padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              localizationService.cancel,
              style: TextStyle(
                color: SpaceColors.starWhiteTertiary,
                fontSize: isLandscape ? 14 : null,
              ),
            ),
          ),
        ),
        SizedBox(width: isLandscape ? 12 : 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: SpaceColors.nebulaPink,
              foregroundColor: SpaceColors.starWhite,
              padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, 
                     size: isLandscape ? 16 : 20, 
                     color: SpaceColors.starWhite),
                SizedBox(width: isLandscape ? 6 : 8),
                Text(
                  localizationService.verify,
                  style: TextStyle(
                    color: SpaceColors.starWhite,
                    fontSize: isLandscape ? 14 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}