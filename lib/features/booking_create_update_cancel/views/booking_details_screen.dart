// booking_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../models/booking_model.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final int bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue[100]!;
      case 'active':
        return Colors.orange[100]!;
      case 'completed':
        return Colors.green[100]!;
      case 'canceled':
      case 'cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue[700]!;
      case 'active':
        return Colors.orange[700]!;
      case 'completed':
        return Colors.green[700]!;
      case 'canceled':
      case 'cancelled':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking =
    ref.watch(bookingViewModelProvider.notifier).getBookingById(bookingId);

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Booking not found')),
      );
    }

    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');
    final lowerStatus = booking.status.toLowerCase();
    final isCompleted = lowerStatus == 'completed' || lowerStatus == 'complete';
    final isPending = lowerStatus == 'pending';
    final isActive = lowerStatus == 'active';
    final isCancelled = lowerStatus == 'canceled' || lowerStatus == 'cancelled';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _buildActionButton(context, ref, booking,
              isCompleted: isCompleted,
              isPending: isPending,
              isActive: isActive,
              isCancelled: isCancelled),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner (completed)
            if (isCompleted)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Completed',
                            style: TextStyle(
                              color: Colors.green[900],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This booking has been completed successfully.',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      booking.bookingNumber,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.status.substring(0, 1).toUpperCase() +
                            booking.status.substring(1),
                        style: TextStyle(
                          color: _getStatusTextColor(booking.status),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Tradie Details Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tradie Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                        booking.tradie?.profileImage != null
                            ? NetworkImage(booking.tradie!.profileImage!)
                            : null,
                        child: booking.tradie?.profileImage == null
                            ? Text(
                          booking.tradie?.name
                              .substring(0, 1)
                              .toUpperCase() ??
                              'T',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.tradie?.name ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.tradie?.profession ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            if (booking.tradie?.availableToday == true) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Available today',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (booking.tradie?.rating != null &&
                          booking.tradie!.rating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking.tradie!.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (booking.tradie?.hourlyRate != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        Text(
                          booking.tradie!.hourlyRate,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.tradie?.location ?? 'Location not specified',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (booking.tradie?.distance != null &&
                          booking.tradie!.distance > 0)
                        Text(
                          '${booking.tradie!.distance.toStringAsFixed(1)} km away',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Open chat functionality if implemented
                      // context.go('/chat/${booking.tradie?.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Chat'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Booking Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    Icons.home_repair_service,
                    'Service Requested',
                    booking.service?.name ?? 'N/A',
                  ),
                  if (booking.service?.description != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Text(
                        booking.service!.description,
                        style:
                        TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    Icons.calendar_today,
                    'Preferred Schedule',
                    dateFormat.format(booking.bookingStart),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    Icons.access_time,
                    '',
                    '${timeFormat.format(booking.bookingStart)} - ${timeFormat.format(booking.bookingEnd)}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 90), // leave space for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty) ...[
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      WidgetRef ref,
      Booking booking, {
        required bool isCompleted,
        required bool isPending,
        required bool isActive,
        required bool isCancelled,
      }) {
    final vm = ref.read(bookingViewModelProvider.notifier);
    final isLoading = ref.watch(bookingViewModelProvider).isLoading;

    // Completed -> Book Again
    if (isCompleted) {
      return ElevatedButton(
        onPressed: () {
          // Navigate to create booking flow (adjust route if needed)
          context.go('/urgent-booking/create');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E99),
          minimumSize: const Size(double.infinity, 54),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: const Text(
          'Book Again',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    // Cancelled -> disabled info button
    if (isCancelled) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, 54),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: const Text('Booking Cancelled'),
      );
    }

    // Pending -> Request Cancellation
    if (isPending) {
      return ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
          final confirmed = await _showConfirmDialog(
            context,
            title: 'Cancel Booking?',
            message:
            'Are you sure you want to cancel this booking request?',
            confirmLabel: 'Yes, Cancel',
          );
          if (!confirmed) return;

          final success = await vm.cancelBooking(booking.id);
          if (success) {
            // refresh bookings
            await vm.loadBookings();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
              context.pop(); // go back to list/detail caller
            }
          } else {
            final err = ref.read(bookingViewModelProvider).error;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(err ?? 'Failed to cancel')),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 54),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Text('Request Cancellation'),
      );
    }

    // Active -> Mark Complete (homeowner may confirm completion)
    if (isActive) {
      return ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
          final confirmed = await _showConfirmDialog(
            context,
            title: 'Mark job as complete?',
            message:
            'Are you sure this job is finished and you want to mark it as completed? This action may notify the tradie and update job status.',
            confirmLabel: 'Yes, Mark Complete',
          );
          if (!confirmed) return;

          // IMPORTANT:
          // Your backend currently does NOT expose an endpoint to mark booking as "completed".
          // You must add an endpoint (for example: POST /bookings/{id}/complete or accept status field in PUT /bookings/{id})
          // and implement a ViewModel method (e.g. vm.markComplete(booking.id)) that calls it.
          //
          // For now we will show a helpful message and refresh bookings (no server-side change).
          // Uncomment and adapt the code below once the backend endpoint and ViewModel method exist.
          //
          // final success = await vm.markComplete(booking.id);
          // if (success) { await vm.loadBookings(); ... }

          // Temporary UI-only behavior:
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Mark Complete requires backend support (POST /bookings/{id}/complete).'
                        ' Please implement server endpoint or contact backend dev.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[800],
          minimumSize: const Size(double.infinity, 54),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: const Text(
          'Mark Complete',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    // Default fallback
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
      ),
      child: const Text('No action available'),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context,
      {required String title,
        required String message,
        String confirmLabel = 'Confirm'}) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}
