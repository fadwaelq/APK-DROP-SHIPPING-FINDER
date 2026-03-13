import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final VoidCallback onPressed;
  final Color? color;

  const SocialLoginButton({
    super.key,
    this.icon,
    this.assetPath,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: assetPath != null
            ? Image.asset(
                assetPath!,
                fit: BoxFit.contain,
              )
            : Icon(
                icon,
                color: color ?? Colors.black87,
                size: 24,
              ),
      ),
    );
  }
}
