import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/features/schedule/viewmodels/schedule_viewmodel.dart';

void showCancelConfirmation(
  BuildContext context,
  WidgetRef ref,
  int eventId,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(
                Icons.warning_rounded, 
                color: Colors.white, 
                size: 40
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Are you sure you want to cancel?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(scheduleViewModelProvider.notifier).cancelEvent(eventId);
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      ),
                    ),
                    child: const Text('Yes'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      ),
                    ),
                    child: const Text('No'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}