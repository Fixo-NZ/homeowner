import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/features/schedule/models/schedule_model.dart';
import 'package:tradie/features/schedule/viewmodels/schedule_viewmodel.dart';

class EditEventSheet extends ConsumerStatefulWidget {
  final OfferModel event;

  const EditEventSheet({super.key, required this.event});

  @override
  ConsumerState<EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends ConsumerState<EditEventSheet> {
  late TextEditingController _eventController;
  late TextEditingController _noteController;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  // Store original values for comparison
  late DateTime originalStartDate;
  late DateTime originalEndDate;
  late TimeOfDay originalStartTime;
  late TimeOfDay originalEndTime;

  @override
  void initState() {
    super.initState();
    _eventController = TextEditingController(text: widget.event.title);
    _noteController = TextEditingController(text: widget.event.description);
    
    // Initialize current values
    selectedStartDate = widget.event.startDateTime;
    selectedEndDate = widget.event.endDateTime;
    startTime = TimeOfDay.fromDateTime(widget.event.startDateTime);
    endTime = TimeOfDay.fromDateTime(widget.event.endDateTime);
    
    // Store original values
    originalStartDate = widget.event.startDateTime;
    originalEndDate = widget.event.endDateTime;
    originalStartTime = TimeOfDay.fromDateTime(widget.event.startDateTime);
    originalEndTime = TimeOfDay.fromDateTime(widget.event.endDateTime);
  }

  /// Check if any date or time values have changed from original
  bool get hasChanges {
    if (selectedStartDate == null || selectedEndDate == null || startTime == null || endTime == null) {
      return false;
    }

    // Compare dates
    final currentStartDate = DateTime(selectedStartDate!.year, selectedStartDate!.month, selectedStartDate!.day);
    final origStartDate = DateTime(originalStartDate.year, originalStartDate.month, originalStartDate.day);

    final currentEndDate = DateTime(selectedEndDate!.year, selectedEndDate!.month, selectedEndDate!.day);
    final origEndDate = DateTime(originalEndDate.year, originalEndDate.month, originalEndDate.day);
    
    if (!currentStartDate.isAtSameMomentAs(origStartDate)) {
      return true;
    }

    if (!currentEndDate.isAtSameMomentAs(origEndDate)) {
      return true;
    }

    // Compare start time
    if (startTime!.hour != originalStartTime.hour || startTime!.minute != originalStartTime.minute) {
      return true;
    }

    // Compare end time
    if (endTime!.hour != originalEndTime.hour || endTime!.minute != originalEndTime.minute) {
      return true;
    }

    return false;
  }

  void showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Edit Event",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Event Name
            TextField(
              controller: _eventController,
              enabled: false,
              style: const TextStyle(color: Color(0xFF8F9BB3)),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFEDF1F7), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Event note
            TextField(
              controller: _noteController,
              enabled: false,
              style: const TextStyle(color: Color(0xFF8F9BB3)),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFEDF1F7), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 12),
            
            Text(
              'Start Date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                 Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedStartDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEDF1F7)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedStartDate == null
                                  ? "Date"
                                  : "${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}",
                            ),
                            const Icon(Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                    ),
                  ),
              
                  SizedBox(width: 10,),

                  SizedBox(
                    width: 140,
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            startTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEDF1F7)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(startTime == null ? "Start time" : startTime!.format(context)),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            
            const SizedBox(height: 12),

            Text(
              'End Date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                 Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedEndDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedEndDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEDF1F7)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedEndDate == null
                                  ? "Date"
                                  : "${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}",
                            ),
                            const Icon(Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                    ),
                  ),
              
                  SizedBox(width: 10,),

                  SizedBox(
                    width: 140,
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEDF1F7)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(endTime == null ? "End time" : endTime!.format(context)),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Reschedule Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !hasChanges ? null : () async {
                  Navigator.pop(context);

                  // Create DateTime objects without timezone conversion issues
                  final newStart = DateTime(
                    selectedStartDate!.year,
                    selectedStartDate!.month,
                    selectedStartDate!.day,
                    startTime!.hour,
                    startTime!.minute,
                  );

                  final newEnd = DateTime(
                    selectedEndDate!.year,
                    selectedEndDate!.month,
                    selectedEndDate!.day,
                    endTime!.hour,
                    endTime!.minute,
                  );

                  // Debug: Print the dates being sent
                  // print("🔍 Selected Date: ${selectedStartDate!.toIso8601String()}");
                  // print("🔍 New Start: ${newStart.toIso8601String()}");
                  // print("🔍 New End: ${newEnd.toIso8601String()}");

                  final duration = newEnd.difference(newStart).inMinutes;
                  if (duration < 30) {
                    showMessageDialog("Appointment must be at least 30 minutes long.");
                    return;
                  }

                  if (newStart.isBefore(DateTime.now())) {
                    showMessageDialog("Start time must be in the future.");
                    return;
                  }

                  if (newEnd.isBefore(newStart) || newEnd.isAtSameMomentAs(newStart)) {
                    showMessageDialog("End time must be after start time.");
                    return;
                  }

                  final schedules = ref.read(scheduleViewModelProvider).completedOffers
                        .where((e) => e.id != widget.event.id)
                        .toList();

                  final hasConflict = schedules.any((e) {
                      return e.startDateTime.isBefore(newEnd) && e.endDateTime.isAfter(newStart);
                  });

                  if (hasConflict) {
                    showMessageDialog("Conflicting appointment. Please choose another time.");
                    return;
                  }

                  showMessageDialog("Schedule successfully rescheduled");
                
                  await ref.read(scheduleViewModelProvider.notifier).rescheduleEvent(
                    id: widget.event.id,
                    startTime: newStart,
                    endTime: newEnd,
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasChanges ? const Color(0xFF090C9B) : Colors.grey[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  hasChanges ? "Reschedule" : "No Changes Made",
                  style: TextStyle(
                    color: hasChanges ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
