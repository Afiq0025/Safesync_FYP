import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import 'package:safesync/screens/fake_call_no_response_page.dart';
import '../screens/fake_call_page.dart'; // Import for FakeCallPage
import 'location_service.dart'; // Import LocationService

class EmergencyService {
  final BuildContext context;
  final LocationService locationService; // Add LocationService field
  final ValueGetter<bool> isLocationSharingActive;
  final VoidCallback onStartLocationSharing;
  final VoidCallback onInitiateAutoCall;
  final ValueGetter<bool> isEmergencyButtonActive;
  final ValueGetter<bool> isAutoCallActive; // New parameter

  EmergencyService({
    required this.context,
    required this.locationService, // Require it in the constructor
    required this.isLocationSharingActive,
    required this.onStartLocationSharing,
    required this.onInitiateAutoCall,
    required this.isEmergencyButtonActive,
    required this.isAutoCallActive, // Require it in the constructor
  });

  Future<void> handleEmergencyTrigger({bool force = false}) async {
    if (!isEmergencyButtonActive() && !force) {
      debugPrint(
          "EmergencyService: Triggered, but Emergency Mode feature is not active. No dialog shown.");
      return;
    }

    if (ModalRoute.of(context)?.isCurrent != true) {
      debugPrint(
          "EmergencyService: Another route is current, potentially a dialog. Aborting.");
      return;
    }

    final String stationName = await locationService.findNearestPoliceStation();
    debugPrint("EmergencyService: Found nearest station: '$stationName'");

    bool? confirmed;
    try {
      if (!Navigator.of(context).mounted) return;

      HapticFeedback.heavyImpact();
      confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirm Emergency'),
            content: const Text(
                'Are you sure you want to activate emergency mode? Respond within 10 seconds.'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop(false);
                  }
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
              ),
            ],
          );
        },
      ).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      debugPrint("EmergencyService: Confirmation timed out.");
      if (isAutoCallActive()) {
        debugPrint("EmergencyService: Auto Call is ON. Initiating fake call with operator voice.");
        if (Navigator.of(context).mounted &&
            Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (Navigator.of(context).mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FakeCallNoResponsePage(stationName: stationName)));
        }
        onInitiateAutoCall();
      } else {
        debugPrint("EmergencyService: Auto Call is OFF. Doing nothing.");
        if (Navigator.of(context).mounted &&
            Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
      return;
    } catch (e) {
      debugPrint("EmergencyService: Error showing dialog: $e");
      return;
    }

    if (confirmed == true) {
      debugPrint("EmergencyService: Emergency sequence ACTIVATED by user!");
      if (Navigator.of(context).mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FakeCallPage(stationName: stationName)));
      }
      onInitiateAutoCall();

      if (isLocationSharingActive()) {
        onStartLocationSharing();
      } else {
        debugPrint(
            "EmergencyService: Location Sharing feature is not toggled on, so not starting it.");
      }
    } else if (confirmed == false) {
      debugPrint("EmergencyService: Emergency activation CANCELLED by user.");
    }
  }
}
