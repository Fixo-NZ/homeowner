import 'package:flutter/material.dart';
import '../models/payment_transaction.dart';

class TransactionCard extends StatelessWidget {
  final PaymentTransaction transaction;
  final VoidCallback? onMakePayment;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onMakePayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = transaction.status == 'completed';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: isCompleted
                      ? Text(
                          transaction.customerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2196F3),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Color(0xFFB8B8B8),
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and type/status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (!isCompleted)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              transaction.serviceType,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFFF9800),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        transaction.serviceType,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              ),
              // Status badge for completed transactions
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Service description
          Row(
            children: [
              Icon(
                isCompleted ? Icons.person_outline : Icons.build_outlined,
                size: 16,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  transaction.serviceDescription,
                  style: TextStyle(
                    fontSize: isCompleted ? 14 : 13,
                    fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w400,
                    color: isCompleted ? const Color(0xFF374151) : const Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                transaction.date,
                style: TextStyle(
                  fontSize: isCompleted ? 14 : 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                transaction.location,
                style: TextStyle(
                  fontSize: isCompleted ? 14 : 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider (only for completed)
          if (isCompleted) ...[
            Container(
              height: 1,
              color: const Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 12),
          ],
          // Amount and button/arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCompleted ? 'Full Payment' : 'Total Payment',
                    style: TextStyle(
                      fontSize: isCompleted ? 13 : 11,
                      fontWeight: FontWeight.w400,
                      color: isCompleted ? const Color(0xFF6B7280) : const Color(0xFF999999),
                    ),
                  ),
                  SizedBox(height: isCompleted ? 2 : 4),
                  Text(
                    '\$${transaction.totalPayment.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? const Color(0xFF1F2937) : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              if (isCompleted)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                )
              else
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onMakePayment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFB300)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Make Payment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}