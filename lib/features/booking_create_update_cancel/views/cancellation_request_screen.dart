import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../models/cancellation_request.dart';

class CancellationRequestScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const CancellationRequestScreen({super.key, required this.bookingId});

  @override
  ConsumerState<CancellationRequestScreen> createState() =>
      _CancellationRequestScreenState();
}

class _CancellationRequestScreenState
    extends ConsumerState<CancellationRequestScreen> {
  final Map<String, bool> _reasons = {
    'Schedule conflict': false,
    'Found an alternative service': false,
    'Budget constraints': false,
    'Service no longer needed': false,
    'Concerns about the tradie': false,
    'Other reason': false,
  };

  final TextEditingController _additionalDetailsController =
      TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _additionalDetailsController.dispose();
    super.dispose();
  }

  String? get _selectedReason {
    final selected = _reasons.entries.where((e) => e.value);
    return selected.isEmpty ? null : selected.first.key;
  }

  bool get _canSubmit {
    return _selectedReason != null &&
        (_selectedReason != 'Other reason' ||
            _additionalDetailsController.text.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
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
          'Request Cancellation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please let us know why you\'d like to cancel this booking. This helps us improve our service.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reason for cancellation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ..._reasons.keys.map((reason) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        // Uncheck all others
                        _reasons.updateAll((key, value) => false);
                        // Check this one
                        _reasons[reason] = true;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _reasons[reason]!
                              ? const Color(0xFF1E1E99)
                              : Colors.grey[300]!,
                          width: _reasons[reason]! ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _reasons[reason]!
                                    ? const Color(0xFF1E1E99)
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                              color: _reasons[reason]!
                                  ? const Color(0xFF1E1E99)
                                  : Colors.transparent,
                            ),
                            child: _reasons[reason]!
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            reason,
                            style: TextStyle(
                              fontSize: 15,
                              color: _reasons[reason]!
                                  ? Colors.black
                                  : Colors.black87,
                              fontWeight: _reasons[reason]!
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (_selectedReason == 'Other reason') ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _additionalDetailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Please provide any additional information...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E1E99),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber[900],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note:',
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cancellation requests are reviewed within 24 hours. You may be subject to cancellation fees depending on the timing.',
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit && !_isSubmitting
                      ? _submitCancellation
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E99),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit Cancellation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCancellation() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    final request = CancellationRequest(
      bookingId: widget.bookingId,
      reason: _selectedReason!,
      additionalDetails: _selectedReason == 'Other reason'
          ? _additionalDetailsController.text.trim()
          : null,
    );

    // Option 1: Use the cancellation request endpoint
    final referenceNumber = await ref
        .read(bookingViewModelProvider.notifier)
        .submitCancellationRequest(request);

    setState(() => _isSubmitting = false);

    if (referenceNumber != null) {
      // Navigate to success screen
      if (mounted) {
        context.goNamed(
          'cancel-success',
          pathParameters: {'id': widget.bookingId.toString()},
          queryParameters: {'ref': referenceNumber},
        );
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(bookingViewModelProvider).error ??
                  'Failed to submit cancellation request',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
