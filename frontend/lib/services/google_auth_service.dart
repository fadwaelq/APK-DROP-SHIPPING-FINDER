import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  // TODO: Fix GoogleSignIn constructor issue. 
  // Currently commented out to allow the app to build.
  /*
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  */

  void initialize({required String clientId, String? serverClientId}) {
    /*
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: clientId,
      serverClientId: serverClientId,
    );
    */
  }

  /// Sign in with Google and get access token
  Future<Map<String, dynamic>> signIn() async {
    return {
      'success': false,
      'message': 'Google Sign-In is temporarily disabled for maintenance.',
    };
    /*
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return {
          'success': false,
          'message': 'Sign in cancelled',
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get the access token
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Failed to get access token',
        };
      }

      return {
        'success': true,
        'access_token': accessToken,
        'id_token': idToken,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
      };
    } catch (error) {
      debugPrint('❌ Google Sign-In Error: $error');
      return {
        'success': false,
        'message': 'Google Sign-In failed: $error',
      };
    }
    */
  }

  /// Sign out from Google
  Future<void> signOut() async {
    /*
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Signed out from Google');
    } catch (error) {
      debugPrint('❌ Error signing out: $error');
    }
    */
  }

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    return false;
    // return await _googleSignIn.isSignedIn();
  }

  /// Get current user
  GoogleSignInAccount? get currentUser => null;
  // GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
