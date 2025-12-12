import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearMonthPickerScreen extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onMonthSelected;

  const YearMonthPickerScreen({
    super.key,
    required this.initialDate,
    required this.onMonthSelected,
  });

  @override
  State<YearMonthPickerScreen> createState() => _YearMonthPickerScreenState();
}

class _YearMonthPickerScreenState extends State<YearMonthPickerScreen> {
  late int selectedYear;
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Month"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          children: [
            // Year header with navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32, 
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_left, size: 22),
                    onPressed: () {
                      setState(() {
                        selectedYear--;
                        selectedMonth = DateTime(selectedYear, selectedMonth.month, 1);
                      });
                    },
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(child: 
                Text(
                  '$selectedYear',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  )
                ),

                const SizedBox(width: 20),

                Container(
                  width: 32, 
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_right, size: 22),
                    onPressed: () {
                      setState(() {
                        selectedYear++;
                        selectedMonth = DateTime(selectedYear, selectedMonth.month, 1);
                      });
                    },
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // Grid of 12 months
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final monthDate = DateTime(selectedYear, month, 1);
                  final isSelected = selectedMonth.year == selectedYear &&
                      selectedMonth.month == month;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMonth = monthDate;
                      });
                      widget.onMonthSelected(monthDate);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected 
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          // Month name header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              DateFormat.MMMM().format(monthDate).toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.blue.shade700 : Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Mini calendar
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: _buildMiniCalendar(monthDate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(DateTime monthDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Calculate the first day of the week (Monday = 1, Sunday = 7)
    final firstWeekday = firstDayOfMonth.weekday;
    final startOffset = firstWeekday - 1; // Convert to 0-based (Monday = 0)
    
    // Calculate previous month days to show
    final previousMonth = DateTime(monthDate.year, monthDate.month - 1, 0);
    
    List<Widget> calendarRows = [];
    
    // Add day headers
    calendarRows.add(
      Row(
        children: [
          // Day headers
          ...['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((day) => 
            Expanded(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 8,
                  color: day == 'Su' ? Colors.red.shade300 : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
    
    // Build calendar weeks
    List<DateTime> allDays = [];
    
    // Add previous month's trailing days
    for (int i = startOffset - 1; i >= 0; i--) {
      allDays.add(DateTime(previousMonth.year, previousMonth.month, previousMonth.day - i));
    }
    
    // Add current month days
    for (int day = 1; day <= daysInMonth; day++) {
      allDays.add(DateTime(monthDate.year, monthDate.month, day));
    }
    
    // Add next month's leading days to complete the grid
    final nextMonth = DateTime(monthDate.year, monthDate.month + 1, 1);
    int nextMonthDay = 1;
    while (allDays.length % 7 != 0) {
      allDays.add(DateTime(nextMonth.year, nextMonth.month, nextMonthDay));
      nextMonthDay++;
    }
    
    // Create rows of 7 days each
    for (int i = 0; i < allDays.length; i += 7) {
      final weekDays = allDays.sublist(i, i + 7);
      _getWeekNumber(weekDays[0]);
      
      calendarRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              
              // Days
              ...weekDays.map((day) {
                final isCurrentMonth = day.month == monthDate.month;
                final isToday = _isToday(day);
                final isSunday = day.weekday == DateTime.sunday;
                
                return Expanded(
                  child: Container(
                    height: 16,
                    alignment: Alignment.center,
                    decoration: isToday
                        ? BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 8,
                        color: isToday
                            ? Colors.white
                            : !isCurrentMonth
                                ? Colors.grey.shade300
                                : isSunday
                                    ? Colors.red.shade400
                                    : Colors.black,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: calendarRows,
    );
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
    
    if (date.isBefore(firstMonday)) {
      // This date belongs to the last week of the previous year
      return _getWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    
    final daysDifference = date.difference(firstMonday).inDays;
    return (daysDifference / 7).floor() + 1;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }
}
