import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPropertiesList extends ConsumerStatefulWidget {
  const CalendarPropertiesList({super.key});

  @override
  ConsumerState<CalendarPropertiesList> createState() =>
      _CalendarPropertiesListState();
}

class _CalendarPropertiesListState
    extends ConsumerState<CalendarPropertiesList> {
  DateTime? fromDate;
  DateTime? toDate;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  bool? isFromSelected = true;

  List<String> get months {
    return List.generate(12, (index) {
      return DateFormat.MMMM().format(DateTime(0, index + 1));
    });
  }

  List<int> get years {
    return List.generate(101, (index) => 2000 + index);
  }

  void _updateMonth(int increment) {
    setState(() {
      selectedMonth += increment;
      if (selectedMonth > 12) {
        selectedMonth = 1;
        selectedYear++;
      } else if (selectedMonth < 1) {
        selectedMonth = 12;
        selectedYear--;
      }
      // _focusedDay = DateTime(selectedYear, selectedMonth, 1);
      _updateFromToDates();
    });
  }

  void _updateYear(int increment) {
    setState(() {
      selectedYear += increment;
      // _focusedDay = DateTime(selectedYear, selectedMonth, 1);
      _updateFromToDates();
    });
  }

  void _updateFromToDates() {
    setState(() {
      _focusedDay = DateTime(selectedYear, selectedMonth, 1);
      fromDate = DateTime(selectedYear, selectedMonth, 1);
      toDate = DateTime(selectedYear, selectedMonth,
          DateTime(selectedYear, selectedMonth + 1, 0).day);
    });
    //  _focusedDay = DateTime(selectedYear, selectedMonth, 1);
    // fromDate ??= DateTime(selectedYear, selectedMonth, 1);
    // toDate ??= DateTime(selectedYear, selectedMonth,
    //     DateTime(selectedYear, selectedMonth + 1, 0).day);
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isFromDate ? (fromDate ?? _focusedDay) : (toDate ?? _focusedDay),
      // firstDate: DateTime(selectedYear, selectedMonth, 1),
      // lastDate: DateTime(selectedYear, selectedMonth,
      //     DateTime(selectedYear, selectedMonth + 1, 0).day),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          selectedYear = picked.year;
          selectedMonth = picked.month;
        } else {
          toDate = picked;
          selectedYear = picked.year;
          selectedMonth = picked.month;
        }
        _focusedDay = DateTime(selectedYear, selectedMonth, 1);
      });
    }

    // if (picked != null) {
    //   setState(() {
    //     if (isFromDate) {
    //       fromDate = picked;
    //     } else {
    //       toDate = picked;
    //     }
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 40,
            color: Color.fromARGB(255, 67, 3, 128),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Manage Calendar",
          style: TextStyle(
              color: Color.fromARGB(255, 67, 3, 128),
              fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Swagat Grand Banquet Hall',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bachupally, Hyderabad',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: () => _updateYear(-1),
                            ),
                            SizedBox(
                              width: 80,
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedYear,
                                items: years
                                    .map((year) => DropdownMenuItem(
                                          value: year,
                                          child: Text('$year'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedYear = value!;
                                    _updateFromToDates();
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: () => _updateYear(1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: () => _updateMonth(-1),
                            ),
                            SizedBox(
                              width: 100,
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedMonth,
                                items: List.generate(
                                  months.length,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text(months[index]),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    selectedMonth = value!;
                                    _updateFromToDates();
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: () => _updateMonth(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isFromSelected,
                          onChanged: (value) {
                            setState(() {
                              isFromSelected == true ? null : true;
                            });
                          },
                        ),
                        const Text("From: "),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: fromDate != null
                                      ? "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}"
                                      : "---",
                                ),
                                style: const TextStyle(color: Colors.purple),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text("To: "),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: toDate != null
                                      ? "${toDate!.day}/${toDate!.month}/${toDate!.year}"
                                      : "---",
                                ),
                                style: const TextStyle(color: Colors.purple),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    TableCalendar(
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                          selectedYear = focusedDay.year;
                          selectedMonth = focusedDay.month;
                          _updateFromToDates();
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      headerVisible: false,
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, _) {
                          if (date.day == 25) {
                            return _buildCalendarCell(date, Colors.blue,
                                Colors.white); // Selected day
                          } else if ([1, 2, 10, 11, 19, 20, 31]
                              .contains(date.day)) {
                            return _buildCalendarCell(
                                date, Colors.red, Colors.white); // Full day
                          } else if ([9, 23].contains(date.day)) {
                            return _buildCalendarCell(date, Colors.green,
                                Colors.white); // Available day
                          } else {
                            return _buildCalendarCell(
                                date, Colors.grey, Colors.black); // Blocked day
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegend(Colors.grey, "Blocked"),
                        _buildLegend(Colors.green, "Available"),
                        _buildLegend(Colors.red, "Full"),
                        _buildLegend(Colors.blue, "Selected"),
                      ],
                    ),
                    Divider(),
                    const Text(
                      'Events',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    ListTile(
                      title: const Text('Feb 11, 2024'),
                      subtitle: const Text('Swagat Grand Hotel'),
                      trailing: ElevatedButton(
                        // \nSuresh & Swetha\'s wedding
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.purple,
                              width: 2), // Border color and width
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          backgroundColor:
                              Colors.white, // Button background color
                          elevation: 0, // Remove elevation
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the button adjusts to content
                          children: [
                            Text(
                              'View More',
                              style:
                                  TextStyle(color: Colors.purple, fontSize: 12),
                            ),
                            SizedBox(
                                width: 5), // Adds spacing between text and icon
                            Icon(
                              Icons
                                  .arrow_forward, // Replace with the desired icon
                              color: Colors.purple,
                              size: 14, // Adjust icon size
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCell(DateTime date, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        date.day.toString(),
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
