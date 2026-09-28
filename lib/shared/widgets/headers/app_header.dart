import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? avatarUrl;

  const AppHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Halo, $name',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2022),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2022),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7A869A),
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            avatarUrl ?? 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
          ),
        ),
      ],
    );
  }
}