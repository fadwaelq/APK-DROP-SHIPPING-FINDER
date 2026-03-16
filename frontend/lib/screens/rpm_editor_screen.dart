import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RPMEditorScreen extends StatefulWidget {
  const RPMEditorScreen({super.key});

  @override
  State<RPMEditorScreen> createState() => _RPMEditorScreenState();
}

class _RPMEditorScreenState extends State<RPMEditorScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Ready Player Me sub-domain (using a generic demo one for now)
    const String rpmUrl = 'https://demo.readyplayer.me/avatar?frameApi';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _controller.runJavaScript('''
              window.addEventListener('message', function(event) {
                const message = event.data;
                if (message) {
                  // Forward everything to Dart for filtering
                  AvatarSelected.postMessage(JSON.stringify(message));
                }
              });
            ''');
          },
        ),
      )
      ..addJavaScriptChannel(
        'AvatarSelected',
        onMessageReceived: (JavaScriptMessage message) {
          _handleRPMEvent(message.message);
        },
      )
      ..loadRequest(Uri.parse(rpmUrl));
  }

  void _handleRPMEvent(String input) {
    try {
      // 1. Handle raw URL string (if received unquoted)
      if (input.startsWith('http') && input.contains('.glb')) {
        debugPrint('SUCCESS: Raw Avatar URL captured: $input');
        if (mounted) Navigator.pop(context, input);
        return;
      }

      final dynamic decoded = jsonDecode(input);
      
      // 2. Handle JSON string representing a URL
      if (decoded is String && decoded.startsWith('http') && decoded.contains('.glb')) {
        debugPrint('SUCCESS: JSON String Avatar URL captured: $decoded');
        if (mounted) Navigator.pop(context, decoded);
        return;
      }

      // 3. Handle JSON object
      if (decoded is Map) {
        final Map<String, dynamic> event = Map<String, dynamic>.from(decoded);
        final String? type = event['eventName'] ?? event['type'];
        final String? avatarUrl = event['data']?['url'] ?? event['url'];
        
        debugPrint('RPM Event type: $type');

        if (avatarUrl != null && avatarUrl.contains('.glb')) {
          debugPrint('SUCCESS: Avatar URL from object: $avatarUrl');
          if (mounted) Navigator.pop(context, avatarUrl);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error or non-JSON RPM event: $e');
      // If it's not JSON but contains a GLB link anyway
      if (input.contains('http') && input.contains('.glb')) {
        final match = RegExp(r'https?://[^\s"]+\.glb').firstMatch(input);
        if (match != null) {
          final url = match.group(0);
          debugPrint('SUCCESS: Extracted URL from messy string: $url');
          if (mounted) Navigator.pop(context, url);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Better integration with RPM dark theme
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            // Floating Close button
            Positioned(
              top: 10,
              left: 10,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF9E)),
              ),
          ],
        ),
      ),
    );
  }
}
