import 'package:flutter/material.dart';

class QuizAnswerItem extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final bool isCorrect;
  final VoidCallback onSelectCorrect;

  const QuizAnswerItem({
    super.key,
    required this.index,
    required this.controller,
    required this.isCorrect,
    required this.onSelectCorrect,
  });

  static const List<Color> _colors = [
    Color(0xFFE5254A),
    Color(0xFF1368CE),
    Color(0xFFD89E00),
    Color(0xFF26890C),
  ];

  static const List<IconData> _icons = [
    Icons.change_history,
    Icons.diamond_outlined,
    Icons.circle,
    Icons.square,
  ];

  static const List<String> _placeholders = [
    'Tambahkan jawaban 1',
    'Tambahkan jawaban 2',
    'Tambahkan jawaban 3 (opsional)',
    'Tambahkan jawaban 4 (opsional)',
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final icon = _icons[index % _icons.length];
    final placeholder = _placeholders[index % _placeholders.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 5, 7, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          const SizedBox(width: 5),

          InkWell(
            onTap: onSelectCorrect,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCorrect ? const Color(0xFF059669) : Colors.white,
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFF059669)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isCorrect
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
