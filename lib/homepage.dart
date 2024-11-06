import 'package:flutter/material.dart';
import 'appointmentgambang.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  // List of widgets for each page
  final List<Widget> _pages = const [
    Center(child: Text('Home Page')),
    Center(
        child:
            Text('Calendar Page')), // This will be replaced by Campus Selection
    Center(child: Text('Notifications Page')),
    Center(child: Text('Settings Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: const Text(
            'Dual Campus',
            style: TextStyle(
              fontSize: 20.0, // Adjust font size as needed
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
        ),
        backgroundColor:
            const Color(0xFF009FA0), // Turquoise color for the AppBar
        toolbarHeight: 60.0, // Adjust the height if needed
      ),
      body:
          _selectedIndex == 1 ? buildCampusSelection() : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => _onItemTapped(0),
              child: const SizedBox(
                width: 24.0,
                height: 24.0,
                child: Icon(Icons.home),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => _onItemTapped(1),
              child: const SizedBox(
                width: 24.0,
                height: 24.0,
                child: Icon(Icons.calendar_today),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: const SizedBox(
                width: 24.0,
                height: 24.0,
                child: Icon(Icons.notifications),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => _onItemTapped(3),
              child: const SizedBox(
                width: 24.0,
                height: 24.0,
                child: Icon(Icons.settings),
              ),
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF009FA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  Widget buildCampusSelection() {
    return Column(
      children: [
        const SizedBox(
            height: 16.0), // Space between Dual Campus and Select Campus title
        const Text(
          'Select Campus',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0), // Space between title and buttons
        buildCampusButton('UMPSA Gambang'),
        const SizedBox(height: 10.0),
        buildCampusButton('UMPSA Pekan'),
      ],
    );
  }

  Widget buildCampusButton(String campusName) {
    return InkWell(
      onTap: () {
        if (campusName == 'UMPSA Gambang') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppointmentGambangPage()),
          );
        } else if (campusName == 'UMPSA Pekan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppointmentPekanPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.teal, // Background color of the button
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: Text(
          campusName,
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }
}
