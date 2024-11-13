import 'package:flutter/material.dart';

class BulletinList extends StatefulWidget {
  const BulletinList({super.key});

  @override
  State<BulletinList> createState() => _BulletinListState();
}

class _BulletinListState extends State<BulletinList> {
  String selectedFilter = 'Day';

  final List<Map<String, String>> bulletinData = [
    {
      'title': 'Calm Mind',
      'dateStart': '12/05/2024',
      'dateEnd': '20/05/2024',
      'fileName': 'stress.pdf',
    },
    {
      'title': 'Healthy Diet',
      'dateStart': '20/05/2024',
      'dateEnd': '23/05/2024',
      'fileName': 'healthy.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletin List'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: selectedFilter,
                  items: <String>['Day', 'Month', 'Year'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: screenWidth * 0.04)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                  underline: Container(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Colors.grey),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        'Title',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        'Date Start',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        'Date End',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        'File Name',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        'Action',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ],
                ),
                ...bulletinData.map((data) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Text(
                          data['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Text(
                          data['dateStart']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Text(
                          data['dateEnd']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Text(
                          data['fileName']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 20),
                              onPressed: () {
                                // Handle view action
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                // Handle edit action
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () {
                                // Handle delete action //belum link ke update form sbb bulletin list interfCE PROBLEM
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
