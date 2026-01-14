import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  final Widget Function(BuildContext context, bool isAuthenticated) builder;

  const AuthWrapper({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Builder(
          builder: (context) {
            return builder(context, authProvider.isAuthenticated);
          },
        );
      },
    );
  }
}