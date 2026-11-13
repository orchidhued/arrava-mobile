import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'models/quiz_model.dart';
import 'models/quiz_question.dart';
import 'providers/quiz_provider.dart';
import 'widgets/quiz_header.dart';
import 'widgets/quiz_navigation.dart';
import 'widgets/quiz_properties.dart';
import 'widgets/quiz_question_editor.dart';

class CreateQuizPage extends StatefulWidget {
  final QuizModel? quizToEdit;

  const CreateQuizPage({super.key, this.quizToEdit});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  // Title & Quiz Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  // Quiz-level settings
  String _level = 'SMA / MA / SMK Sederajat';
  int? _idMapel;
  String _difficulty = 'Mudah';
  String _modePengerjaan = 'wayground';
  int _durasiTotalMenit = 30;
  String _opsiPreview = 'lengkap';
  bool _neverExpire = true;
  DateTime? _expiryDate;
  bool _useToken = false;

  // Cover image
  Uint8List? _coverBytes;
  String? _coverUrl;
  bool _deleteCover = false;

  int _currentQuestion = 0;
  final List<QuizQuestion> _questions = [];

  QuizQuestion get _question {
    if (_questions.isEmpty) return QuizQuestion();
    return _questions[_currentQuestion];
  }

  bool get _isEditing => widget.quizToEdit != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final q = widget.quizToEdit!;
      _titleController.text = q.judul;
      _descriptionController.text = q.deskripsi ?? '';
      _level = q.namaJenjang ?? 'SMA / MA / SMK Sederajat';
      _idMapel = q.idMapel;
      _difficulty = q.namaTingkat ?? 'Mudah';
      _modePengerjaan = q.modePengerjaan.isNotEmpty ? q.modePengerjaan : 'wayground';
      _durasiTotalMenit = q.durasiTotalMenit ?? 30;
      _opsiPreview = q.opsiPreview.isNotEmpty ? q.opsiPreview : 'lengkap';
      _neverExpire = q.waktuKadaluarsa == null || q.waktuKadaluarsa!.isEmpty;
      _expiryDate = q.waktuKadaluarsa != null ? DateTime.tryParse(q.waktuKadaluarsa!) : null;
      _useToken = q.token != null && q.token!.isNotEmpty;
      _tokenController.text = q.token ?? '';
      _coverUrl = q.fotoQuiz ?? q.coverUrl;

      if (q.soal.isNotEmpty) {
        for (final item in q.soal) {
          final choices = item.pilihan.map((p) => p.teksPilihan).toList();
          while (choices.length < 4) {
            choices.add('');
          }

          int correctIdx = 0;
          if (item.jenisSoal == JenisSoal.trueFalse) {
            correctIdx = (item.jawabanBenar == 'B' || item.correctAnswerIndex == 1) ? 1 : 0;
          } else {
            correctIdx = item.correctAnswerIndex >= 0 ? item.correctAnswerIndex : 0;
          }

          _questions.add(
            QuizQuestion(
              question: item.pertanyaan,
              jenisSoal: item.jenisSoal,
              shortAnswer: item.jenisSoal == JenisSoal.isianSingkat ? (item.jawabanBenar ?? '') : '',
              answers: choices,
              correctAnswer: correctIdx,
              timeLimit: item.durasiDetik,
              points: item.poin,
              existingFotoUrl: item.fotoSoal,
            ),
          );
        }
      }
    }

    if (_questions.isEmpty) {
      _questions.add(QuizQuestion());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuizProvider>().fetchMapels();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tokenController.dispose();

    for (final question in _questions) {
      question.dispose();
    }

    super.dispose();
  }

  // Cover image picking
  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 900,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _coverBytes = bytes;
          _deleteCover = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar cover: $e')),
        );
      }
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverBytes = null;
      _deleteCover = true;
    });
  }

  // Question photo picking
  Future<void> _pickQuestionPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _question.fotoBytes = bytes;
          _question.fotoName = picked.name;
          _question.removeFoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar soal: $e')),
        );
      }
    }
  }

  void _removeQuestionPhoto() {
    setState(() {
      _question.fotoBytes = null;
      _question.fotoName = null;
      _question.removeFoto = true;
    });
  }

  // Token generator
  void _generateRandomToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    final token = List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
    setState(() {
      _tokenController.text = token;
    });
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuizQuestion());
      _currentQuestion = _questions.length - 1;
    });
  }

  void _duplicateQuestion() {
    final original = _question;
    final copy = original.copy();

    setState(() {
      _questions.insert(_currentQuestion + 1, copy);
      _currentQuestion++;
    });
  }

  void _deleteQuestion() {
    if (_questions.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz minimal harus memiliki 1 soal!')),
      );
      return;
    }

    setState(() {
      final removed = _questions.removeAt(_currentQuestion);
      removed.dispose();

      if (_currentQuestion >= _questions.length) {
        _currentQuestion = _questions.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            QuizHeader(onSave: _saveQuiz),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    QuizTitleSection(
                      titleController: _titleController,
                      currentQuestion: _currentQuestion,
                      totalQuestions: _questions.length,
                      timeLimit: _question.timeLimit,
                      points: _question.points,
                    ),
                    const SizedBox(height: 14),
                    QuizQuestionEditor(
                      question: _question,
                      onSelectCorrectAnswer: (index) {
                        setState(() {
                          _question.correctAnswer = index;
                        });
                      },
                      onChangedJenisSoal: (jenis) {
                        setState(() {
                          _question.jenisSoal = jenis;
                          if (jenis == JenisSoal.trueFalse) {
                            if (_question.answers[0].text.isEmpty) {
                              _question.answers[0].text = 'Benar';
                            }
                            if (_question.answers[1].text.isEmpty) {
                              _question.answers[1].text = 'Salah';
                            }
                            if (_question.correctAnswer > 1) {
                              _question.correctAnswer = 0;
                            }
                          }
                        });
                      },
                      onPickPhoto: _pickQuestionPhoto,
                      onRemovePhoto: _removeQuestionPhoto,
                    ),
                    const SizedBox(height: 14),
                    QuizProperties(
                      question: _question,
                      availableMapels: context.watch<QuizProvider>().mapels,
                      level: _level,
                      idMapel: _idMapel,
                      difficulty: _difficulty,
                      modePengerjaan: _modePengerjaan,
                      durasiTotalMenit: _durasiTotalMenit,
                      opsiPreview: _opsiPreview,
                      neverExpire: _neverExpire,
                      expiryDate: _expiryDate,
                      descriptionController: _descriptionController,
                      useToken: _useToken,
                      tokenController: _tokenController,
                      coverBytes: _coverBytes,
                      coverUrl: _coverUrl,
                      deleteCover: _deleteCover,
                      onChangedTimeLimit: (limit) {
                        setState(() {
                          _question.timeLimit = limit;
                        });
                      },
                      onChangedPoints: (pts) {
                        setState(() {
                          _question.points = pts;
                        });
                      },
                      onChangedLevel: (lvl) {
                        setState(() {
                          _level = lvl;
                        });
                      },
                      onChangedMapel: (mId) {
                        setState(() {
                          _idMapel = mId;
                        });
                      },
                      onChangedDifficulty: (diff) {
                        setState(() {
                          _difficulty = diff;
                        });
                      },
                      onChangedMode: (m) {
                        setState(() {
                          _modePengerjaan = m;
                        });
                      },
                      onChangedDurasiTotal: (d) {
                        setState(() {
                          _durasiTotalMenit = d;
                        });
                      },
                      onChangedOpsiPreview: (op) {
                        setState(() {
                          _opsiPreview = op;
                        });
                      },
                      onChangedNeverExpire: (ne) {
                        setState(() {
                          _neverExpire = ne;
                        });
                      },
                      onChangedExpiryDate: (dt) {
                        setState(() {
                          _expiryDate = dt;
                        });
                      },
                      onChangedUseToken: (ut) {
                        setState(() {
                          _useToken = ut;
                          if (ut && _tokenController.text.trim().isEmpty) {
                            _generateRandomToken();
                          }
                        });
                      },
                      onGenerateToken: _generateRandomToken,
                      onPickCover: _pickCoverImage,
                      onRemoveCover: _removeCoverImage,
                    ),
                    const SizedBox(height: 12),
                    _buildQuestionActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: QuizNavigation(
        totalQuestions: _questions.length,
        currentQuestion: _currentQuestion,
        questions: _questions,
        onSelectQuestion: (index) {
          setState(() {
            _currentQuestion = index;
          });
        },
        onAddQuestion: _addQuestion,
      ),
    );
  }

  Widget _buildQuestionActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _duplicateQuestion,
              icon: const Icon(Icons.content_copy, size: 16),
              label: const Text('Gandakan Soal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _deleteQuestion,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Hapus Soal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFBE123C),
                backgroundColor: const Color(0xFFFFF1F2),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isSameQuestionImage(QuizQuestion a, QuizQuestion b) {
    if (a.fotoBytes != null && b.fotoBytes != null) {
      return listEquals(a.fotoBytes, b.fotoBytes);
    }
    if (a.existingFotoUrl != null &&
        b.existingFotoUrl != null &&
        !a.removeFoto &&
        !b.removeFoto) {
      return a.existingFotoUrl == b.existingFotoUrl;
    }
    return false;
  }

  void _saveQuiz() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul kuis tidak boleh kosong! Silakan isi judul kuis terlebih dahulu.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Perbarui Kuis' : 'Pilih Mode Simpan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Tentukan status perubahan kuis saat disimpan ke database.'
                    : 'Tentukan status kuis saat disimpan ke dalam sistem.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                ),
                tileColor: const Color(0xFFECFDF5),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.send_rounded, color: Color(0xFF059669), size: 22),
                ),
                title: Text(
                  _isEditing ? 'Simpan & Publikasikan' : 'Publikasikan Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF065F46)),
                ),
                subtitle: const Text(
                  'Kuis berstatus "Tersedia" dan langsung bisa dikerjakan oleh siswa.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _submitQuiz(isDraft: false);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note, color: Color(0xFF475569), size: 22),
                ),
                title: const Text(
                  'Simpan sebagai Draf',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                subtitle: const Text(
                  'Kuis berstatus "Draft" dan belum bisa dilihat oleh siswa.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _submitQuiz(isDraft: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitQuiz({required bool isDraft}) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // VALIDASI SEPERTI DI WEB create.blade.php
    if (!isDraft) {
      if (_useToken && _tokenController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap masukkan token kuis atau matikan opsi token!'),
            backgroundColor: Color(0xFFE11D48),
          ),
        );
        return;
      }

      if (_modePengerjaan == 'biasa' && _durasiTotalMenit < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Total durasi kuis minimal 1 menit!'),
            backgroundColor: Color(0xFFE11D48),
          ),
        );
        return;
      }

      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final no = i + 1;
        final hasText = q.hasText;
        final hasFoto = q.hasFoto;

        if (!hasText && !hasFoto) {
          setState(() => _currentQuestion = i);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Soal no. $no harus memiliki teks pertanyaan atau foto soal (tidak boleh kosong keduanya).',
              ),
              backgroundColor: const Color(0xFFE11D48),
            ),
          );
          return;
        }

        if (q.jenisSoal == JenisSoal.isianSingkat) {
          if (q.shortAnswerController.text.trim().isEmpty) {
            setState(() => _currentQuestion = i);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Soal #$no: Kunci jawaban isian singkat wajib diisi!'),
                backgroundColor: const Color(0xFFE11D48),
              ),
            );
            return;
          }
        } else if (q.jenisSoal == JenisSoal.kuis) {
          final filledChoices = q.answers.where((a) => a.text.trim().isNotEmpty).toList();
          if (filledChoices.length < 2) {
            setState(() => _currentQuestion = i);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Soal #$no: Pilihan ganda harus memiliki minimal 2 pilihan jawaban yang terisi!'),
                backgroundColor: const Color(0xFFE11D48),
              ),
            );
            return;
          }
          if (q.correctAnswer >= q.answers.length || q.answers[q.correctAnswer].text.trim().isEmpty) {
            setState(() => _currentQuestion = i);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Soal #$no: Kunci jawaban yang dipilih tidak boleh kosong!'),
                backgroundColor: const Color(0xFFE11D48),
              ),
            );
            return;
          }
        }
      }

      // Deteksi duplikat cerdas 3 tingkat dalam 1 kuis (persis QuizController Laravel)
      final count = _questions.length;
      for (int i = 0; i < count; i++) {
        for (int j = i + 1; j < count; j++) {
          final qI = _questions[i];
          final qJ = _questions[j];

          final textI = qI.questionController.text.trim().toLowerCase();
          final textJ = qJ.questionController.text.trim().toLowerCase();
          final sameText = textI.isNotEmpty && textI == textJ;
          final sameImage = qI.hasFoto && qJ.hasFoto && _isSameQuestionImage(qI, qJ);

          if (sameText && sameImage) {
            setState(() => _currentQuestion = j);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Soal no. ${i + 1} dan ${j + 1} benar-benar IDENTIK (teks & gambar sama persis)!',
                ),
                backgroundColor: const Color(0xFFE11D48),
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }

          if (sameText && !sameImage) {
            setState(() => _currentQuestion = j);
            final snippet = qI.questionController.text.trim();
            final preview = snippet.length > 35 ? '${snippet.substring(0, 35)}...' : snippet;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚠️ Soal no. ${i + 1}, ${j + 1} memiliki teks pertanyaan yang sama persis: "$preview"',
                ),
                backgroundColor: const Color(0xFFD97706),
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }

          if (sameImage && !sameText) {
            setState(() => _currentQuestion = j);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚠️ Soal no. ${i + 1}, ${j + 1} memiliki gambar yang sama persis!',
                ),
                backgroundColor: const Color(0xFFD97706),
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }
        }
      }
    }

    final jenjangMap = {
      'SD / MI': 1,
      'SMP / MTs': 2,
      'SMA / MA / SMK Sederajat': 3,
      'Perguruan Tinggi / Umum': 4,
    };

    final difficultyMap = {
      'Mudah': 1,
      'Sedang': 2,
      'Sulit': 3,
    };

    final labels = ['A', 'B', 'C', 'D'];

    final soalList = _questions.map((q) {
      final qText = q.questionController.text.trim();
      final typeStr = q.jenisSoal.apiValue;

      // Handle photo
      String? fotoVal;
      if (q.fotoBytes != null) {
        fotoVal = 'data:image/jpeg;base64,${base64Encode(q.fotoBytes!)}';
      } else if (q.existingFotoUrl != null && !q.removeFoto) {
        fotoVal = q.existingFotoUrl;
      }

      List<Map<String, dynamic>> pilihan = [];
      String jawabanBenar = 'A';

      if (q.jenisSoal == JenisSoal.trueFalse) {
        jawabanBenar = q.correctAnswer == 1 ? 'B' : 'A';
        pilihan = [
          {'label': 'A', 'teks_pilihan': 'Benar', 'is_correct': q.correctAnswer == 0},
          {'label': 'B', 'teks_pilihan': 'Salah', 'is_correct': q.correctAnswer == 1},
        ];
      } else if (q.jenisSoal == JenisSoal.isianSingkat) {
        jawabanBenar = q.shortAnswerController.text.trim();
      } else {
        jawabanBenar = labels[q.correctAnswer.clamp(0, 3)];
        pilihan = List.generate(4, (i) {
          final text = i < q.answers.length ? q.answers[i].text.trim() : '';
          return {
            'label': labels[i],
            'teks_pilihan': text,
            'is_correct': q.correctAnswer == i,
          };
        });
      }

      final item = <String, dynamic>{
        'pertanyaan': qText,
        'jenis_soal': typeStr,
        'poin': q.points,
        'durasi_detik': q.timeLimit,
        'jawaban_benar': jawabanBenar,
        'pilihan': pilihan,
      };

      if (q.jenisSoal == JenisSoal.isianSingkat) {
        item['jawaban_singkat'] = q.shortAnswerController.text.trim();
      }

      if (fotoVal != null) {
        item['foto_soal'] = fotoVal;
      }
      if (q.removeFoto) {
        item['remove_foto'] = true;
      }

      return item;
    }).toList();

    // Cover image handling
    String? coverVal;
    if (_coverBytes != null) {
      coverVal = 'data:image/jpeg;base64,${base64Encode(_coverBytes!)}';
    } else if (_coverUrl != null && !_deleteCover) {
      coverVal = _coverUrl;
    }

    final payload = <String, dynamic>{
      'judul': title,
      'deskripsi': _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      'id_jenjang': jenjangMap[_level] ?? 3,
      'id_mapel': _idMapel,
      'id_tingkatquiz': difficultyMap[_difficulty] ?? 1,
      'mode_pengerjaan': _modePengerjaan,
      'durasi_total_menit': _modePengerjaan == 'biasa' ? _durasiTotalMenit : null,
      'opsi_preview': _opsiPreview,
      'waktu_kadaluarsa': (!_neverExpire && _expiryDate != null)
          ? '${_expiryDate!.year.toString().padLeft(4, '0')}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')} ${_expiryDate!.hour.toString().padLeft(2, '0')}:${_expiryDate!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'use_token': _useToken,
      'token': _useToken ? _tokenController.text.trim().toUpperCase() : null,
      'foto_quiz': coverVal,
      'hapus_foto_quiz': _deleteCover,
      'action_type': isDraft ? 'draft' : 'publish',
      'soal': soalList,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          elevation: 6,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(strokeWidth: 3),
                const SizedBox(width: 16),
                Text(
                  _isEditing ? 'Memperbarui kuis...' : 'Menyimpan kuis...',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final quizProvider = context.read<QuizProvider>();
      final bool success = _isEditing
          ? await quizProvider.updateQuiz(widget.quizToEdit!.idQuiz, payload)
          : await quizProvider.createQuiz(payload);

      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Kuis "$title" berhasil diperbarui!'
                    : (isDraft ? 'Kuis berhasil disimpan sebagai Draf!' : 'Kuis berhasil dipublikasikan!'),
              ),
              backgroundColor: const Color(0xFF059669),
            ),
          );
          Navigator.pop(context);
        } else {
          final err = quizProvider.error ?? 'Terjadi kesalahan sistem.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $err'),
              backgroundColor: const Color(0xFFE11D48),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi error: $e'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    }
  }
}
