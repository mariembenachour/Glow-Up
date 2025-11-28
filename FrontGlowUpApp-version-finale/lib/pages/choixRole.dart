import 'package:flutter/material.dart';

class ChoixRolePage extends StatelessWidget {
  const ChoixRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> roles = [
      {'label': 'Client', 'route': '/registerClient', 'icon': Icons.person},
      {'label': 'Styliste', 'route': '/registerStyliste', 'icon': Icons.brush},
      {'label': 'Coach', 'route': '/registerCoach', 'icon': Icons.fitness_center},
      {'label': 'Dermato', 'route': '/registerDermato', 'icon': Icons.medical_information},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez votre rôle'),
        backgroundColor: const Color(0xFFFF4E50),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6F91), Color(0xFFFF4E50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: roles.map((role) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.pinkAccent,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  icon: Icon(role['icon']),
                  label: Text(
                    role['label'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, role['route']);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
