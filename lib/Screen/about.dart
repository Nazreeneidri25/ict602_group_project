import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  final String gitHubLink = "https://github.com/Nazreeneidri25/ict602_group_project";

  Widget profileCard(BuildContext context) {
    final devs = [
      {
        'name': 'Muhammad Nazreen Eidri Muda',
        'studID': '202988385'
      },
      {
        'name': 'Luqman Hakim bin Mohd Ali',
        'studID': '2024938691'
      },
      {
        'name': 'Muhammad Aiman bin Fauzi',
        'studID': '2024794251'
      },
      {
        'name': 'Syahril Rumizam bin Abd Razak',
        'studID': '2024568363'
      }
    ];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Developers",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            ...devs.map((item) => ListTile(
              title: Text(
                item['name']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Student ID: ${item['studID']}'),
            )),
            const Divider(height: 32),
            InkWell(
              onTap: () => launchUrlString(gitHubLink, mode: LaunchMode.externalApplication),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    "View on GitHub",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'lib/Assets/Icons/food_truck.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Food Truck Finder',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover and share the best food trucks around you. '
                      'Add your favorite spots, explore new tastes, and enjoy a vibrant food truck community!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                profileCard(context),
                const SizedBox(height: 8),
                Text(
                  '© 2025 All rights reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}