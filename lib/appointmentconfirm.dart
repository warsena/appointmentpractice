import 'package:flutter/material.dart';


class Appointmentconfirm extends StatelessWidget {
  final String selectedService;
  final String selectedTimeslot;
  final DateTime selectedDate;

  const Appointmentconfirm({
    Key? key,
    required this.selectedService,
    required this.selectedTimeslot,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

