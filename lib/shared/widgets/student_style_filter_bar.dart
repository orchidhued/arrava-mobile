import 'package:flutter/material.dart';

/// Palet warna filter pill yang selaras dengan halaman Modul & Kuis siswa.
const Color kStudentFilterBlue = Color(0xFF007FBE);
const Color kStudentFilterMuted = Color(0xFF465673);
const Color kStudentFilterBorder = Color(0xFFDCEFFF);

/// Mencocokkan nilai jenjang dari API (mis. "SD", "SD / MI", "Umum")
/// terhadap pilihan chip filter jenjang.
bool matchesJenjangFilter(
  String? rawJenjang,
  String selected, {
  int? idJenjang,
}) {
  final sel = selected.trim().toLowerCase();
  if (sel.isEmpty || sel == 'semua' || sel == 'semua jenjang') {
    return true;
  }

  final raw = (rawJenjang ?? '').trim().toLowerCase();
  if (sel == 'sd') {
    return idJenjang == 1 ||
        raw == 'sd' ||
        RegExp(r'\bsd\b').hasMatch(raw);
  }
  if (sel == 'smp') {
    return idJenjang == 2 ||
        raw == 'smp' ||
        RegExp(r'\bsmp\b').hasMatch(raw);
  }
  if (sel == 'sma') {
    return idJenjang == 3 ||
        raw == 'sma' ||
        RegExp(r'\b(sma|smk|ma)\b').hasMatch(raw);
  }
  if (sel == 'umum') {
    return raw.isEmpty ||
        raw.contains('umum') ||
        raw.contains('perguruan') ||
        (idJenjang != null && idJenjang > 3);
  }

  return raw == sel || raw.contains(sel);
}

/// Search field yang mengikuti gaya input pencarian halaman siswa.
class StudentStyleSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool? hasQuery;

  const StudentStyleSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    final showClear = hasQuery ?? controller.text.isNotEmpty;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8),
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: kStudentFilterBlue,
        ),
        suffixIcon: showClear
            ? IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: kStudentFilterMuted,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kStudentFilterBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kStudentFilterBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kStudentFilterBlue, width: 1.8),
        ),
      ),
    );
  }
}

/// Bar filter chip horizontal dengan gaya ChoiceChip halaman siswa.
class StudentStyleFilterChipBar extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;
  final String? label;

  const StudentStyleFilterChipBar({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final row = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selectedOption == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: kStudentFilterBlue,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : kStudentFilterMuted,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? kStudentFilterBlue : kStudentFilterBorder,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (label == null || label!.trim().isEmpty) {
      return row;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: kStudentFilterMuted,
          ),
        ),
        const SizedBox(height: 6),
        row,
      ],
    );
  }
}

