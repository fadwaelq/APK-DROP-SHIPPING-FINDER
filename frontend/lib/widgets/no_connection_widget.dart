import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';

class NoConnectionWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final Widget? child;

  const NoConnectionWidget({
    super.key,
    this.onRetry,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        if (connectivity.isOnline) {
          return child ?? const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Icon(
                      Icons.wifi_off,
                      size: 64,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pas de connexion',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vérifiez votre connexion internet et réessayez.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Statut: ${connectivity.connectionStatusText}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: connectivity.isChecking 
                        ? null 
                        : () async {
                            await connectivity.checkConnectivity();
                            if (connectivity.isOnline && onRetry != null) {
                              onRetry!();
                            }
                          },
                      icon: connectivity.isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                      label: Text(connectivity.isChecking ? 'Vérification...' : 'Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: connectivity.isChecking ? null : () {
                      connectivity.checkConnectivity();
                    },
                    child: const Text('Actualiser le statut'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConnectivityAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ConnectivityAwareWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        if (connectivity.isOnline) {
          return child;
        }
        
        return fallback ?? const NoConnectionWidget();
      },
    );
  }
}
