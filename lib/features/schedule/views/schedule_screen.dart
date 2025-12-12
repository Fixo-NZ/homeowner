import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tradie/core/theme/app_text_styles.dart';
import 'package:tradie/features/schedule/views/year_month_picker_screen.dart';
import '../models/schedule_model.dart';
import '../viewmodels/schedule_viewmodel.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    // Load offers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎬 ScheduleScreen: Initializing and fetching offers');
      ref.read(scheduleViewModelProvider.notifier).fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleViewModelProvider);
    
    print('🎨 ScheduleScreen build - Loading: ${scheduleState.isLoading}, Offers: ${scheduleState.offers.length}, Error: ${scheduleState.error}');

    // Show loading screen while data is being fetched
    if (scheduleState.isLoading && scheduleState.offers.isEmpty) {
      print('📱 Showing loading screen');
      return _buildLoadingScreen();
    }

    // Show error screen if there's an error and no data
    if (scheduleState.error != null && scheduleState.offers.isEmpty) {
      print('📱 Showing error screen: ${scheduleState.error}');
      return _buildErrorScreen(scheduleState.error!);
    }

    // Group offers by date
    Map<DateTime, List<OfferModel>> events = {};
    for (var offer in scheduleState.offers) {
      final date = DateTime(
        offer.startDateTime.year,
        offer.startDateTime.month,
        offer.startDateTime.day,
      );
      events[date] = (events[date] ?? [])..add(offer);
    }

    // Events for selected day
    final selectedEvents = events[_selectedDay] ?? [];

    return _buildScheduleScreen(scheduleState, events, selectedEvents);
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calendar icon with loading animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFCEDBF1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.calendar_month,
                size: 40,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3066BE)),
            ),
            const SizedBox(height: 16),
            
            // Loading text
            Text(
              'Loading your schedules...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch your schedules',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Retry button
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(scheduleViewModelProvider.notifier).fetchOffers();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3066BE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Back button
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Go Back',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleScreen(ScheduleState scheduleState, Map<DateTime, List<OfferModel>> events, List<OfferModel> selectedEvents) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedules', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          children: [
            // Show subtle loading indicator for refresh operations
            if (scheduleState.isLoading && scheduleState.offers.isNotEmpty) 
              const LinearProgressIndicator(),

            /// Calendar
            SizedBox(
              height: 400,
              child: TableCalendar<OfferModel>(
                firstDay: DateTime(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                eventLoader: (day) =>
                    events[DateTime(day.year, day.month, day.day)] ?? [],
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    );
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                  rightChevronIcon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Color(0xFFB3B3B3)),
                  weekendStyle: TextStyle(color: Color(0xFFB3B3B3)),
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                ),
                calendarBuilders: CalendarBuilders(
                  headerTitleBuilder: (context, date) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => YearMonthPickerScreen(
                              initialDate: date,
                              onMonthSelected: (selectedDate) {
                                setState(() {
                                  _focusedDay = selectedDate;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${DateFormat.MMMM().format(date)}\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            TextSpan(
                              text: '${date.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF8F9BB3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  dowBuilder: (context, day) {
                    if (day.weekday == DateTime.sunday) {
                      return Center(
                        child: Text(
                          'Sun',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    return null; // Use default style for other days
                  },
                  todayBuilder: (context, day, focused) {
                    return Center(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(124, 48, 102, 190),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final isSunday = day.weekday == DateTime.sunday;

                    return Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSunday
                              ? const Color(0xFFFF0000)
                              : const Color(0xFFB3B3B3),
                        ),
                      ),
                    );
                  },   
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox();

                    // Always show a single dot if there's at least one event
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 252, 189, 52), // Your marker color
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: selectedEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'No events for this day',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index];
                        // Use a default color since the new model doesn't have a color field
                        final color = const Color(0xFF3066BE);

                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  DateFormat('hh:mm a').format(event.startDateTime),
                                  style: TextStyle(color: Color(0xFF757575)),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Color.fromARGB(255, 161, 161, 161),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color, // dynamic color here
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Card(
                                    color: color,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        event.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(event.description),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tradie: ${event.tradie.fullName}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Status: ${event.status.toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getStatusColor(event.status),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: event.rescheduledAt != null
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[800],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Rescheduled',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : null,
                                      onTap: () {
                                        // Navigate to job details with offer data
                                        context.push(
                                          '/job-details',
                                          extra: event,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }