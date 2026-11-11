import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/quiz_model.dart';
import '../models/quiz_question.dart';

class QuizProperties extends StatelessWidget {
  final QuizQuestion question;
  final List<MapelModel> availableMapels;

  // Quiz-level properties
  final String level;
  final int? idMapel;
  final String difficulty;
  final String modePengerjaan;
  final int durasiTotalMenit;
  final String opsiPreview;
  final bool neverExpire;
  final DateTime? expiryDate;
  final TextEditingController descriptionController;
  final bool useToken;
  final TextEditingController tokenController;
  final Uint8List? coverBytes;
  final String? coverUrl;
  final bool deleteCover;

  // Callbacks
  final ValueChanged<int> onChangedTimeLimit;
  final ValueChanged<int> onChangedPoints;
  final ValueChanged<String> onChangedLevel;
  final ValueChanged<int?> onChangedMapel;
  final ValueChanged<String> onChangedDifficulty;
  final ValueChanged<String> onChangedMode;
  final ValueChanged<int> onChangedDurasiTotal;
  final ValueChanged<String> onChangedOpsiPreview;
  final ValueChanged<bool> onChangedNeverExpire;
  final ValueChanged<DateTime?> onChangedExpiryDate;
  final ValueChanged<bool> onChangedUseToken;
  final VoidCallback onGenerateToken;
  final VoidCallback onPickCover;
  final VoidCallback onRemoveCover;

  const QuizProperties({
    super.key,
    required this.question,
    this.availableMapels = const [],
    required this.level,
    this.idMapel,
    required this.difficulty,
    required this.modePengerjaan,
    required this.durasiTotalMenit,
    required this.opsiPreview,
    required this.neverExpire,
    this.expiryDate,
    required this.descriptionController,
    required this.useToken,
    required this.tokenController,
    this.coverBytes,
    this.coverUrl,
    this.deleteCover = false,
    required this.onChangedTimeLimit,
    required this.onChangedPoints,
    required this.onChangedLevel,
    required this.onChangedMapel,
    required this.onChangedDifficulty,
    required this.onChangedMode,
    required this.onChangedDurasiTotal,
    required this.onChangedOpsiPreview,
    required this.onChangedNeverExpire,
    required this.onChangedExpiryDate,
    required this.onChangedUseToken,
    required this.onGenerateToken,
    required this.onPickCover,
    required this.onRemoveCover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. PENGATURAN SOAL AKTIF
        _buildActiveQuestionSection(context),

        const SizedBox(height: 14),

        // 2. PENGATURAN KUIS LENGKAP
        _buildQuizSettingsSection(context),
      ],
    );
  }

  // ===========================================================================
  // 1. PENGATURAN SOAL AKTIF
  // ===========================================================================
  Widget _buildActiveQuestionSection(BuildContext context) {
    final isWayground = modePengerjaan == 'wayground';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on_rounded, color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Soal Aktif',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Timer dan bobot nilai untuk butir soal yang sedang diedit',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Batas Waktu & Poin
          Row(
            children: [
              Expanded(
                child: _buildSmallSetting(
                  icon: Icons.timer_outlined,
                  iconColor: isWayground ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                  title: 'Timer Soal',
                  child: Opacity(
                    opacity: isWayground ? 1.0 : 0.5,
                    child: _buildDropdown<int>(
                      value: question.timeLimit,
                      items: const [5, 10, 20, 30, 60, 90, 120, 240],
                      itemLabel: (v) => '$v detik',
                      onChanged: isWayground
                          ? (val) {
                              if (val != null) onChangedTimeLimit(val);
                            }
                          : (_) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallSetting(
                  icon: Icons.military_tech_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Bobot Poin',
                  child: _buildDropdown<int>(
                    value: question.points,
                    items: const [5, 10, 15, 20, 25, 50, 100],
                    itemLabel: (v) => '$v Poin',
                    onChanged: (val) {
                      if (val != null) onChangedPoints(val);
                    },
                  ),
                ),
              ),
            ],
          ),

          if (!isWayground) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Timer per soal dinonaktifkan karena Mode Kuis Biasa (durasi total kuis) sedang digunakan.',
                      style: TextStyle(fontSize: 9.5, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. PENGATURAN KUIS LENGKAP
  // ===========================================================================
  Widget _buildQuizSettingsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings_outlined, color: Color(0xFF059669), size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Kuis',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Konfigurasi umum, durasi, cover, dan keamanan kuis',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Jenjang
          _buildLevelDropdown(),
          const SizedBox(height: 14),

          // Mapel
          _buildMapelDropdown(),
          const SizedBox(height: 14),

          // Tingkat Kesulitan
          _buildDifficulty(),
          const SizedBox(height: 16),

          // Mode Pengerjaan
          _buildModePengerjaan(context),
          const SizedBox(height: 16),

          // Opsi Preview Siswa
          _buildOpsiPreview(),
          const SizedBox(height: 16),

          // Batas Waktu Kadaluarsa
          _buildExpirySection(context),
          const SizedBox(height: 16),

          // Deskripsi / Petunjuk
          _buildDeskripsiInput(),
          const SizedBox(height: 16),

          // Foto Cover Quiz
          _buildCoverSection(context),
          const SizedBox(height: 16),

          // Token Masuk Quiz
          _buildTokenSection(),
        ],
      ),
    );
  }

  // Dropdown Jenjang
  Widget _buildLevelDropdown() {
    const levels = [
      'SD / MI',
      'SMP / MTs',
      'SMA / MA / SMK Sederajat',
      'Perguruan Tinggi / Umum',
    ];

    final String selectedLevel = levels.contains(level) ? level : levels[2];

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
            SizedBox(width: 4),
            Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: selectedLevel,
          isExpanded: true,
          decoration: _inputDecoration(),
          icon: const Icon(Icons.expand_more, size: 19, color: Color(0xFF94A3B8)),
          items: levels.map((lvl) {
            return DropdownMenuItem<String>(
              value: lvl,
              child: Text(
                lvl,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChangedLevel(val);
          },
        ),
      ],
    );
  }

  // Dropdown Mapel
  Widget _buildMapelDropdown() {
    final bool hasMatch = idMapel != null && availableMapels.any((m) => m.idMapel == idMapel);
    final int? selectedValue = hasMatch ? idMapel : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFF2563EB)),
            SizedBox(width: 6),
            Text(
              'Mata Pelajaran (Mapel)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            SizedBox(width: 6),
            Text(
              '(Opsional)',
              style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int?>(
          initialValue: selectedValue,
          isExpanded: true,
          decoration: _inputDecoration(),
          icon: const Icon(Icons.expand_more, size: 19, color: Color(0xFF94A3B8)),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                '-- Tanpa Mapel / Umum --',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            ...availableMapels.map((mapel) {
              return DropdownMenuItem<int?>(
                value: mapel.idMapel,
                child: Text(
                  mapel.namaMapel + (mapel.namaJenjang != null ? ' (${mapel.namaJenjang})' : ''),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              );
            }),
          ],
          onChanged: onChangedMapel,
        ),
      ],
    );
  }

  // Tingkat Kesulitan
  Widget _buildDifficulty() {
    const difficulties = ['Mudah', 'Sedang', 'Sulit'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF0891B2)),
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
            final bool selected = difficulty == difficulties[index];
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
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedColor.withValues(alpha: 0.1)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? selectedColor : const Color(0xFFE2E8F0),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      difficulties[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        color: selected ? selectedColor : const Color(0xFF475569),
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

  // Mode Pengerjaan
  Widget _buildModePengerjaan(BuildContext context) {
    final isWayground = modePengerjaan == 'wayground';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 6),
              Text(
                'Mode Pengerjaan Kuis',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Wayground Card
              Expanded(
                child: InkWell(
                  onTap: () => onChangedMode('wayground'),
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isWayground ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isWayground ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: isWayground ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: isWayground ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Wayground',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isWayground ? const Color(0xFF1D4ED8) : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Timer per soal (Kahoot style)',
                          style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Biasa Card
              Expanded(
                child: InkWell(
                  onTap: () => onChangedMode('biasa'),
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: !isWayground ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: !isWayground ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: !isWayground ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: !isWayground ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Kuis Biasa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: !isWayground ? const Color(0xFF1D4ED8) : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Waktu total seluruh kuis',
                          style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Durasi Total jika mode biasa
          if (!isWayground) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Total Durasi Pengerjaan:',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<int>(
                      initialValue: durasiTotalMenit,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                        border: OutlineInputBorder(),
                      ),
                      items: const [10, 15, 20, 30, 45, 60, 90, 120, 180].map((m) {
                        return DropdownMenuItem<int>(
                          value: m,
                          child: Text('$m Menit', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) onChangedDurasiTotal(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Opsi Preview Siswa
  Widget _buildOpsiPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF6366F1)),
              SizedBox(width: 6),
              Text(
                'Tampilan Info Kuis Bagi Siswa',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            value: 'lengkap',
            groupValue: opsiPreview,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF2563EB),
            title: const Text(
              'Preview Soal Lengkap',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            subtitle: const Text(
              'Menampilkan ringkasan jenis soal, estimasi waktu, poin, dan cuplikan pertanyaan.',
              style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
            ),
            onChanged: (val) {
              if (val != null) onChangedOpsiPreview(val);
            },
          ),
          const Divider(height: 8),
          RadioListTile<String>(
            value: 'tipe_saja',
            groupValue: opsiPreview,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF2563EB),
            title: const Text(
              'Hanya Tipe Soal Saja',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            subtitle: const Text(
              'Hanya menampilkan ringkasan jenis soal. Pertanyaan dirahasiakan sebelum mulai kuis.',
              style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
            ),
            onChanged: (val) {
              if (val != null) onChangedOpsiPreview(val);
            },
          ),
        ],
      ),
    );
  }

  // Batas Waktu Kadaluarsa
  Widget _buildExpirySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_busy_outlined, size: 16, color: Color(0xFFF43F5E)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Batas Waktu Pengerjaan Kuis',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
              ),
              Switch(
                value: neverExpire,
                activeThumbColor: const Color(0xFF2563EB),
                onChanged: onChangedNeverExpire,
              ),
            ],
          ),
          Text(
            neverExpire ? 'Kuis tidak pernah kedaluwarsa (dapat diakses kapan saja).' : 'Kuis memiliki batas akhir waktu akses.',
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
          ),
          if (!neverExpire) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: expiryDate ?? now.add(const Duration(days: 7)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (pickedDate != null && context.mounted) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(expiryDate ?? now),
                  );
                  if (pickedTime != null) {
                    final combined = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    onChangedExpiryDate(combined);
                  }
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        expiryDate != null
                            ? '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}  ${expiryDate!.hour.toString().padLeft(2, '0')}:${expiryDate!.minute.toString().padLeft(2, '0')}'
                            : 'Pilih Tanggal & Waktu Kedaluwarsa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: expiryDate != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Deskripsi / Petunjuk
  Widget _buildDeskripsiInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, size: 16, color: Color(0xFF0284C7)),
              SizedBox(width: 6),
              Text(
                'Deskripsi / Petunjuk Kuis',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              SizedBox(width: 6),
              Text('(Opsional)', style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan gambaran materi, aturan pengerjaan, atau petunjuk untuk siswa...',
              hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  // Foto Cover Quiz
  Widget _buildCoverSection(BuildContext context) {
    final bool hasMemoryCover = coverBytes != null;
    final bool hasExistingCover = coverUrl != null && coverUrl!.isNotEmpty && !deleteCover;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 6),
              Text(
                'Foto Cover Quiz',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              SizedBox(width: 6),
              Text('(Opsional)', style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 8),

          if (hasMemoryCover || hasExistingCover) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: hasMemoryCover
                        ? Image.memory(coverBytes!, fit: BoxFit.cover)
                        : Image.network(
                            ApiConstants.resolveMediaUrl(coverUrl) ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onRemoveCover,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBE123C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Hapus Cover', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton.icon(
                onPressed: onPickCover,
                icon: const Icon(Icons.photo_camera, size: 14),
                label: const Text('Ganti Foto Cover', style: TextStyle(fontSize: 11)),
              ),
            ),
          ] else ...[
            InkWell(
              onTap: onPickCover,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 30, color: Color(0xFF3B82F6)),
                    SizedBox(height: 6),
                    Text(
                      'Unggah Foto Cover Quiz',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Rasio 16:9 • Maks 2MB (PNG, JPG, WebP)',
                      style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Token Masuk Quiz
  Widget _buildTokenSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_outlined, size: 16, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Token Masuk Quiz',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
              ),
              Switch(
                value: useToken,
                activeThumbColor: const Color(0xFF2563EB),
                onChanged: onChangedUseToken,
              ),
            ],
          ),
          const Text(
            'Jika diaktifkan, siswa wajib memasukkan token sebelum bisa memulai kuis.',
            style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
          ),
          if (useToken) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tokenController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Contoh: KUIS12',
                      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onGenerateToken,
                  icon: const Icon(Icons.shuffle, size: 14),
                  label: const Text('Acak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helpers
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
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
      initialValue: safeValue,
      isExpanded: true,
      decoration: _inputDecoration(),
      icon: const Icon(Icons.expand_more, size: 19, color: Color(0xFF94A3B8)),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel != null ? itemLabel(item) : item.toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
