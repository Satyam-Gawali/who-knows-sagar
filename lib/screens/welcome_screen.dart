import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../providers/player_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 0.0,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();

        final playerProv = Provider.of<PlayerProvider>(context, listen: false);
        if (playerProv.playerName != null) {
          _nameController.text = playerProv.playerName!;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 👑 🛡️ गुप्त सुरक्षा रक्षक: ॲडमिन पॅनल उघडण्यापूर्वी पासवर्ड तपासणी डायलॉग
  void _checkAdminPassword(BuildContext context) {
    final TextEditingController passwordDialogController = TextEditingController();
    final adminFormKey = GlobalKey<FormState>();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_person_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('ॲडमिन लॉगिन / Admin Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: adminFormKey,
                child: TextFormField(
                  controller: passwordDialogController,
                  obscureText: !isPasswordVisible,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter Admin Password',
                    prefixIcon: const Icon(Icons.password_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setDialogState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    // 🔒 पासवर्डची मुख्य कडक कंडिशन मॅच करणे
                    if (value == null || value != 'Satyam@Gawali#123') {
                      return '❌ चुकीचा पासवर्ड! / Incorrect Password';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                FilledButton(
                  onPressed: () {
                    if (adminFormKey.currentState!.validate()) {
                      Navigator.pop(dialogContext); // डायलॉग बंद करा
                      debugPrint('Navigating to Admin Panel after correct verification...');
                      context.push('/admin'); // ॲडमिन पॅनलवर प्रवेश
                    }
                  },
                  child: const Text('Verify 🔓'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleStartGame(PlayerProvider playerProvider) async {
    if (_formKey.currentState!.validate()) {
      final playerName = _nameController.text.trim();

      try {
        await playerProvider.joinGame(playerName);

        if (mounted) {
          debugPrint('Player synchronized successfully: $playerName');
          context.go('${AppRouter.lobby}?name=$playerName');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Connection error! Unable to reach registration server.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: CircleAvatar(
              radius: 160,
              backgroundColor: AppColors.tertiaryContainer.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: CircleAvatar(
              radius: 140,
              backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: IconButton(
              icon: const Icon(
                Icons.info_outline_rounded,
                size: 26,
              ),
              onPressed: () {
                // 👑 बदल: थेट नॅव्हिगेट न करता आधी पासवर्ड विचारणे
                _checkAdminPassword(context);
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const AnimatedEmojiDecoration(),
                            const SizedBox(height: 20),
                            AppText(
                              'Who Knows Sagar?',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: AppText(
                                'Haldi Special 💛 हळदी उत्सव',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 44),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(28.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AppText(
                                      "चला पाहूया, सागरला सर्वात जवळून कोण ओळखतं! 🤔",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 28),
                                    TextFormField(
                                      controller: _nameController,
                                      enabled: !playerProvider.isLoading,
                                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                      textCapitalization: TextCapitalization.words,
                                      maxLength: 20,
                                      decoration: InputDecoration(
                                        hintText: 'तुमचे नाव लिहा / Enter your name',
                                        counterText: "",
                                        prefixIcon: const Icon(Icons.celebration_rounded, color: AppColors.primary),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(color: AppColors.error, width: 2),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'कृपया गेम खेळण्यासाठी तुमचे नाव टाका';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (_) => _handleStartGame(playerProvider),
                                    ),
                                    const SizedBox(height: 28),
                                    FilledButton(
                                      onPressed: playerProvider.isLoading
                                          ? null
                                          : () => _handleStartGame(playerProvider),
                                      child: playerProvider.isLoading
                                          ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                          : const AppText(
                                        'गेम सुरू करा 🎯',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedEmojiDecoration extends StatefulWidget {
  const AnimatedEmojiDecoration({super.key});

  @override
  State<AnimatedEmojiDecoration> createState() => _AnimatedEmojiDecorationState();
}

class _AnimatedEmojiDecorationState extends State<AnimatedEmojiDecoration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _yAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _yAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnimation.value),
          child: const Text(
            '👑',
            style: TextStyle(fontSize: 64),
          ),
        );
      },
    );
  }
}