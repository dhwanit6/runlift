import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/haptic_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PremiumButton extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool isFullWidth;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;

  const PremiumButton({
    required this.label,
    required this.onPressed,
    this.color,
    this.isFullWidth = true,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haptics = ref.read(hapticServiceProvider);

    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSecondary ? null : [
          BoxShadow(
            color: (color ?? AppTheme.primary).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () {
            haptics.heavy();
            onPressed();
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: isSecondary ? null : AppTheme.primaryGradient,
              color: isSecondary ? Colors.white.withAlpha(20) : (color ?? Colors.transparent),
              borderRadius: BorderRadius.circular(20),
              border: isSecondary ? Border.all(color: Colors.white24, width: 1) : null,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: isSecondary ? Colors.white : Colors.black, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: isSecondary ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
