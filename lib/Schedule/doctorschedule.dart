import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSchedule extends StatefulWidget {
  final String campus;
  final String service;

  const DoctorSchedule({
    super.key,
    required this.campus,
    required this.service,
  });

  @override
  State<DoctorSchedule> createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, String>> doctorMapping = {};
  Map<DateTime, List<String>> availableSlots = {};
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  List<DateTime> currentMonthDays = [];
  String? currentDoctorId;

  @override
  void initState() {
    super.initState();
    fetchDoctorMapping().then((_) => fetchDoctorSchedule());
    _generateCurrentMonthDays();
  }

  void _generateCurrentMonthDays() {
    DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    
    currentMonthDays = List.generate(daysInMonth, 
      (index) => DateTime(selectedDate.year, selectedDate.month, index + 1)
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = selectedDate.year;
        int selectedMonth = selectedDate.month;
        
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF48b0fe),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Select Date',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Year Selection
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                selectedYear--;
                              });
                            },
                            color: const Color(0xFF48b0fe),
                          ),
                          Text(
                            selectedYear.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                selectedYear++;
                              });
                            },
                            color: const Color(0xFF48b0fe),
                          ),
                        ],
                      ),
                    ),
                    // Month Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == selectedMonth;
                          
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedMonth = month;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF48b0fe) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF48b0fe) : Colors.grey[300]!,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _getMonthName(month),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Buttons
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedDate = DateTime(selectedYear, selectedMonth);
                                _generateCurrentMonthDays();
                                fetchDoctorSchedule();
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF48b0fe),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> fetchDoctorMapping() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('User')
          .where('User_Type', isEqualTo: 'Doctor')
          .get();

      Map<String, Map<String, String>> tempMapping = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final campus = data['Campus'] as String? ?? 'Unknown Campus';
        final service = data['Selected_Service'] as String? ?? 'Unknown Service';
        final name = data['User_Name'] as String? ?? 'Unknown Doctor';

        if (!tempMapping.containsKey(campus)) {
          tempMapping[campus] = {};
        }
        tempMapping[campus]![service] = name;

        if (campus == widget.campus && service == widget.service) {
          currentDoctorId = doc.id;
        }
      }

      setState(() {
        doctorMapping = tempMapping;
      });
    } catch (e) {
      print('Error fetching doctor mapping: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDoctorSchedule() async {
    if (currentDoctorId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot scheduleSnapshot = await _firestore
          .collection('DoctorSchedule')
          .where('doctorId', isEqualTo: currentDoctorId)
          .where('month', isEqualTo: selectedDate.month)
          .where('year', isEqualTo: selectedDate.year)
          .get();

      Map<DateTime, List<String>> tempSlots = {};

      for (var doc in scheduleSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final day = data['day'] as int;
        final slots = List<String>.from(data['timeSlots'] ?? []);
        
        final dateKey = DateTime(selectedDate.year, selectedDate.month, day);
        tempSlots[dateKey] = slots;
      }

      setState(() {
        availableSlots = tempSlots;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching doctor schedule: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildCalendarHeader() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: weekDays.map((day) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF48b0fe),
          ),
          child: Text(
            day,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: currentMonthDays.length,
      itemBuilder: (context, index) {
        final day = currentMonthDays[index];
        final hasSlots = availableSlots.containsKey(day);
        
        return GestureDetector(
          onTap: () {
            if (hasSlots) {
              setState(() {
                selectedDate = day;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              color: hasSlots ? const Color(0xFFE3F2FD) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontWeight: hasSlots ? FontWeight.bold : FontWeight.normal,
                    color: hasSlots ? const Color(0xFF48b0fe) : Colors.black,
                  ),
                ),
                if (hasSlots)
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFF48b0fe),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlots() {
    final slots = availableSlots[selectedDate] ?? [];
    if (slots.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Slots for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...slots.map((slot) => Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF48b0fe)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    slot,
                    style: const TextStyle(
                      color: Color(0xFF48b0fe),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF48b0fe),
                    size: 20,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = doctorMapping[widget.campus]?[widget.service] ?? 'Unknown Doctor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Schedule'),
        backgroundColor: const Color(0xFF48b0fe),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doctor: $doctorName',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Service: ${widget.service}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Campus: ${widget.campus}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showMonthYearPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF48b0fe)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.calendar_today, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCalendarHeader(),
                          _buildCalendarGrid(),
                        ],
                      ),
                    ),
                  ),
                  _buildTimeSlots(),
                ],
              ),
            ),
    );
  }
}