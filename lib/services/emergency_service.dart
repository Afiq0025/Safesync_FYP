import 'dart:async';
import 'package:flutter/material.dart';

class EmergencyService {
  final BuildContext context;
  final ValueGetter<bool> isLocationSharingActive;
  final VoidCallback onStartLocationSharing;
  final VoidCallback onInitiateAutoCall;
  final ValueGetter<bool> isEmergencyButtonActive; // To check if the main emergency button is on

  EmergencyService({
    required this.context,
    required this.isLocationSharingActive,
    required this.onStartLocationSharing,
    required this.onInitiateAutoCall,
    required this.isEmergencyButtonActive,
  });

  Future<void> handleEmergencyTrigger() async {
    if (!isEmergencyButtonActive()) {
      debugPrint("EmergencyService: Triggered, but Emergency Mode feature is not active. No dialog shown.");
      return;
    }

    // Check if a dialog is already active to prevent stacking (simple check)
    if (ModalRoute.of(context)?.isCurrent != true) {
      debugPrint("EmergencyService: Another route is current, potentially a dialog. Aborting.");
      return;
    }

    bool? confirmed;
    try {
      if (!Navigator.of(context).mounted) return; // Ensure context is valid

      confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirm Emergency'),
            content: const Text('Are you sure you want to activate emergency mode? Respond within 10 seconds.'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  if (Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop(false);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  if (Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop(true);
                },
              ),
            ],
          );
        },
      ).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      debugPrint("EmergencyService: Confirmation timed out.");
      if (Navigator.of(context).mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss timeout dialog if it was shown
      }
      onInitiateAutoCall();
      return;
    } catch (e) {
      debugPrint("EmergencyService: Error showing dialog: $e");
      return;
    }

    if (confirmed == true) {
      debugPrint("EmergencyService: Emergency sequence ACTIVATED!");
      if (isLocationSharingActive()) {
        onStartLocationSharing();
      } else {
        debugPrint("EmergencyService: Location Sharing feature is not toggled on, so not starting it.");
      }
    } else if (confirmed == false) {
      debugPrint("EmergencyService: Emergency activation CANCELLED by user.");
    }
  }
}
