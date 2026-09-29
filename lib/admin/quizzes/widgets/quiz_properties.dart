import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/quiz_question.dart';

class QuizProperties extends StatelessWidget {
  final QuizQuestion question;
  final ValueChanged<String> onChangedLevel;
  final ValueChanged<String> onChangedDifficulty;
  final ValueChanged<int> onChangedTimeLimit;
  final ValueChanged<int> onChangedPoints;
  final ValueChanged<bool> onChangedNeverExpire;

  const QuizProperties({
    super.key,
    required this.question,
    required this.onChangedLevel,
    required this.onChangedDifficulty,
    required this.onChangedTimeLimit,
    required this.onChangedPoints,
    required this.onChangedNeverExpire,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune, color: Color(0xFF2563EB), size: 21),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Properti Quiz & Soal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          _buildLevelDropdown(),
          const SizedBox(height: 14),
          _buildDifficulty(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildTimeDropdown()),
              const SizedBox(width: 10),
              Expanded(child: _buildPointDropdown()),
            ],
          ),
          const SizedBox(height: 14),
          _buildExpirySwitch(),
        ],
      ),
    );
  }

  Widget _buildLevelDropdown() {
    const levels = [
      'SD / MI',
      'SMP / MTs',
      'SMA / MA / SMK Sederajat',
      'Perguruan Tinggi / Umum',
    ];

    final String selectedLevel =
        levels.contains(question.level) ? question.level : levels[2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.school_outlined, size: 16, color: Color(0xFF6366F1)),
            SizedBox(width: 6),
            Text(
              'Jenjang Quiz',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedLevel,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          icon: const Icon(
            Icons.expand_more,
            size: 19,
            color: Color(0xFF94A3B8),
          ),
          items: levels.map((level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Text(
                level,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChangedLevel(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDifficulty() {
    const difficulties = ['Mudah', 'Sedang', 'Sulit'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.trending_up, size: 16, color: Color(0xFF0891B2)),
            SizedBox(width: 6),
            Text(
              'Tingkat Kesulitan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: List.generate(difficulties.length, (index) {
            final bool selected = question.difficulty == difficulties[index];
            final selectedColor = [
              const Color(0xFF059669),
              const Color(0xFFD97706),
              const Color(0xFFE11D48),
            ][index];

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 7),
                child: InkWell(
                  onTap: () => onChangedDifficulty(difficulties[index]),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedColor.withOpacity(0.08)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? selectedColor
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      difficulties[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? selectedColor
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown() {
    return _buildSmallSetting(
      icon: Icons.timer_outlined,
      iconColor: const Color(0xFFF43F5E),
      title: 'Batas Waktu',
      child: _buildDropdown<int>(
        value: question.timeLimit,
        items: const [10, 20, 30, 60, 90],
        itemLabel: (value) => '$value detik',
        onChanged: (value) {
          if (value != null) {
            onChangedTimeLimit(value);
          }
        },
      ),
    );
  }

  Widget _buildPointDropdown() {
    return _buildSmallSetting(
      icon: Icons.military_tech,
      iconColor: const Color(0xFFF59E0B),
      title: 'Bobot Poin',
      child: _buildDropdown<int>(
        value: question.points,
        items: const [5, 10, 20, 50],
        itemLabel: (value) => '$value Poin',
        onChanged: (value) {
          if (value != null) {
            onChangedPoints(value);
          }
        },
      ),
    );
  }

  Widget _buildSmallSetting({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T value)? itemLabel,
  }) {
    final safeValue = items.contains(value) ? value : items.first;

    return DropdownButtonFormField<T>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      icon: const Icon(Icons.expand_more, size: 19, color: Color(0xFF94A3B8)),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel != null ? itemLabel(item) : item.toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildExpirySwitch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_busy, color: Color(0xFF6366F1), size: 19),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tidak Pernah Kadaluarsa',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Kuis dapat diakses kapan saja',
                  style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Switch(
            value: question.neverExpire,
            onChanged: onChangedNeverExpire,
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }
}
