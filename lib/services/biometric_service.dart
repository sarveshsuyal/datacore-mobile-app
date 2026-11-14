import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAuthResult {
  success,
  failed,
  canceled,
  notAvailable,
  notEnrolled,
}

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports platform biometric authentication or screen lock
  Future<bool> canCheckBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (_) {
      return false;
    }
  }

  /// Check if user has enrolled biometrics on device
  Future<bool> isBiometricsEnrolled() async {
    try {
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Prompt native platform biometric or device screen lock (PIN/Pattern/Password/Fingerprint/Face)
  Future<BiometricAuthResult> authenticate({
    String reason = 'Unlock DataCore Pay with Fingerprint, Face or Screen Lock',
    bool biometricOnly = false,
  }) async {
    try {
      final isSupported = await _auth.isDeviceSupported() || await _auth.canCheckBiometrics;
      if (!isSupported) {
        return BiometricAuthResult.notAvailable;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return authenticated ? BiometricAuthResult.success : BiometricAuthResult.canceled;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' || e.code == 'PasscodeNotSet') {
        return BiometricAuthResult.notAvailable;
      } else if (e.code == 'NotEnrolled') {
        return BiometricAuthResult.notEnrolled;
      } else if (e.code == 'UserCanceled' || e.code == 'SystemCanceled') {
        return BiometricAuthResult.canceled;
      }
      return BiometricAuthResult.failed;
    } catch (_) {
      return BiometricAuthResult.failed;
    }
  }
}
