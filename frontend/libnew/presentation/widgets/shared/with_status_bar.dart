import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithStatusBar extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Brightness? brightness;

  const WithStatusBar({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.brightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: backgroundColor ?? Colors.transparent,
          statusBarBrightness: brightness ?? Brightness.light,
          statusBarIconBrightness: brightness ?? Brightness.dark,
        ),
        child: child,
      ),
    );
  }
}