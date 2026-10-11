import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

void showDeliveryAnimation(BuildContext context, {required String orderId}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  bool closed = false;
  Timer? autoClose;

  void close() {
    if (closed) return;
    closed = true;
    autoClose?.cancel();
    if (navigator.mounted && navigator.canPop()) navigator.pop();
  }

  autoClose = Timer(const Duration(milliseconds: 4800), close);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'DeliveryAnim',
    barrierColor: Colors.black.withValues(alpha: 0.85),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim, secAnim) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: close,
        child: _DeliveryAnimationDialogContent(orderId: orderId),
      );
    },
  ).then((_) {
    closed = true;
    autoClose?.cancel();
  });
}

class _DeliveryAnimationDialogContent extends StatefulWidget {
  final String orderId;
  const _DeliveryAnimationDialogContent({required this.orderId});

  @override
  State<_DeliveryAnimationDialogContent> createState() =>
      _DeliveryAnimationDialogContentState();
}

class _DeliveryAnimationDialogContentState
    extends State<_DeliveryAnimationDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _packageSlide;
  late Animation<double> _doorOpen;
  late Animation<double> _lightOpacity;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _packageSlide =
        Tween<Offset>(
          begin: const Offset(-2.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animCtrl,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
          ),
        );

    _doorOpen = Tween<double>(begin: 0.0, end: -0.65).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.40, 0.70, curve: Curves.easeInOutCubic),
      ),
    );

    _lightOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.45, 0.75, curve: Curves.easeIn),
      ),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.75, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 180,
                width: 240,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedBuilder(
                      animation: _lightOpacity,
                      builder: (ctx, child) {
                        return Positioned(
                          bottom: 20,
                          child: Opacity(
                            opacity: _lightOpacity.value,
                            child: Container(
                              width: 80,
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFE082)
                                        .withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: 90,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1A17),
                          border: Border.all(color: AppColors.border, width: 2),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _doorOpen,
                      builder: (ctx, child) {
                        return Positioned(
                          bottom: 20,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateY(_doorOpen.value),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 88,
                              height: 138,
                              decoration: BoxDecoration(
                                color: const Color(0xFF332B25),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                                border: Border.all(
                                  color: AppColors.accentBeige.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentBeige,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SlideTransition(
                      position: _packageSlide,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentBeige,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 32,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ScaleTransition(
                scale: _checkScale,
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.accentBeige,
                  size: 36,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'PAKETİN KAPINDA!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.orderId} teslim edildi.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kapatmak için dokunun',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
