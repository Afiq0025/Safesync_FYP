import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyService {
  static Future<void> makeEmergencyCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '999');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return await Geolocator.getCurrentPosition();
    }
    return null;
  }

  static Future<void> sendEmergencyAlert(List<String> emergencyContacts) async {
    Position? position = await getCurrentLocation();
    String locationText = position != null
        ? "Location: ${position.latitude}, ${position.longitude}"
        : "Location unavailable";

    String message = "EMERGENCY ALERT: I need help! $locationText";

    for (String contact in emergencyContacts) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: contact,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }
}