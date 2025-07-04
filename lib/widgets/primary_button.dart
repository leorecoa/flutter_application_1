import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;

  const PrimaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isOutlined
            ? null
            : isSecondary
                ? AppColors.accentGradient
                : AppColors.primaryGradient,
        border: isOutlined
            ? Border.all(
                color: isSecondary ? AppColors.secondary : AppColors.primary,
                width: 2,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: !isOutlined && onPressed != null
            ? [
                BoxShadow(
                  color: (isSecondary ? AppColors.secondary : AppColors.primary)
                      // ignore: deprecated_member_use
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOutlined
                            ? (isSecondary
                                ? AppColors.secondary
                                : AppColors.primary)
                            : AppColors.white,
                      ),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isOutlined
                          ? (isSecondary
                              ? AppColors.secondary
                              : AppColors.primary)
                          : AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: isOutlined
                          ? (isSecondary
                              ? AppColors.secondary
                              : AppColors.primary)
                          : AppColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
