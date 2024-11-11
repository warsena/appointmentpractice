import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dual Campus Booking System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle user profile action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME ADMIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'TO THE DUAL CAMPUS BOOKING SYSTEM',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),
              // Menu items for admin
              _buildMenuItem(
                icon: Icons.home,
                title: 'Home',
                onTap: () {
                  // Navigate to Home
                },
              ),
              _buildMenuItem(
                icon: Icons.person,
                title: 'User',
                onTap: () {
                  // Navigate to User Management
                },
              ),
              _buildMenuItem(
                icon: Icons.person,
                title: 'Doctor',
                onTap: () {
                  // Navigate to Doctor Management
                },
              ),
              _buildMenuItem(
                icon: Icons.calendar_today,
                title: 'Appointment',
                onTap: () {
                  // Navigate to Appointment Management
                },
              ),
              _buildMenuItem(
                icon: Icons.health_and_safety,
                title: 'Health Bulletin',
                onTap: () {
                  // Navigate to Health Bulletin Management
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 30),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: onTap,
    );
  }
} 