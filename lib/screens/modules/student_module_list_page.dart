import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/modules/models/module_model.dart';
import '../../admin/modules/providers/module_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'student_module_detail_page.dart';

class StudentModuleListPage extends StatefulWidget {
  const StudentModuleListPage({super.key});

  @override
  State<StudentModuleListPage> createState() => _StudentModuleListPageState();
}

class _StudentModuleListPageState extends State<StudentModuleListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter =
      'Semua'; // 'Semua', 'Video', 'PDF', 'Belum Selesai', 'Selesai'
  int? _userJenjangId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadModules();
    });
  }

  Future<void> _loadModules() async {
    final jenjangStr = await AuthService.getJenjang();
    if (mounted) {
      setState(() {
        _userJenjangId = int.tryParse(jenjangStr ?? '');
      });
      context.read<ModuleProvider>().fetchModules(
        status: 'published',
        jenjang: _userJenjangId,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ModuleModel> _filterModules(List<ModuleModel> list) {
    final query = _searchController.text.toLowerCase().trim();

    return list.where((modul) {
      if (modul.isDraft) return false;

      final matchQuery =
          query.isEmpty ||
          modul.judulModul.toLowerCase().contains(query) ||
          (modul.namaTipe?.toLowerCase().contains(query) ?? false);

      bool matchFilter = true;
      if (_selectedFilter == 'Video') {
        matchFilter = modul.isVideo || (modul.idTipeModul == 1);
      } else if (_selectedFilter == 'PDF') {
        matchFilter = modul.isPdf || (modul.idTipeModul == 2);
      } else if (_selectedFilter == 'Belum Selesai') {
        matchFilter = !modul.isMateriSelesai;
      } else if (_selectedFilter == 'Selesai') {
        matchFilter = modul.isMateriSelesai;
      }

      return matchQuery && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();
    final modules = _filterModules(moduleProvider.modules);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Materi & Modul Belajar',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs & Search
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari materi pembelajaran...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                            'Semua',
                            'Video',
                            'PDF',
                            'Belum Selesai',
                            'Selesai',
                          ].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (_) =>
                                    setState(() => _selectedFilter = filter),
                                selectedColor: const Color(0xFF2563EB),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                ),
                                backgroundColor: const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Body Content
            Expanded(
              child: moduleProvider.isLoading && moduleProvider.modules.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : moduleProvider.error != null &&
                        moduleProvider.modules.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal Memuat Materi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              moduleProvider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadModules,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : modules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum Ada Materi Tersedia',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Silakan periksa kembali nanti atau hubungi guru Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _loadModules,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadModules,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double maxW = constraints.maxWidth;
                          final int columns = maxW >= 1050
                              ? 3
                              : (maxW >= 600 ? 2 : 1);

                          if (columns == 1) {
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              itemCount: modules.length,
                              itemBuilder: (context, index) {
                                return _buildModuleCard(modules[index]);
                              },
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 360,
                                ),
                            itemCount: modules.length,
                            itemBuilder: (context, index) {
                              return _buildModuleCard(modules[index]);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCover(ModuleModel modul, bool isVideo) {
    final customCover = ApiConstants.resolveMediaUrl(
      modul.fotoUrl?.isNotEmpty == true ? modul.fotoUrl : modul.fotoModul,
    );
    final youtubeThumbnail = modul.youtubeId?.isNotEmpty == true
        ? 'https://img.youtube.com/vi/${modul.youtubeId}/maxresdefault.jpg'
        : null;

    Widget placeholder = Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVideo
              ? const [Color(0xFF4C1D95), Color(0xFF7C3AED)]
              : const [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          isVideo
              ? Icons.play_circle_fill_rounded
              : Icons.picture_as_pdf_rounded,
          size: 54,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );

    Widget image;
    if (customCover != null) {
      image = Image.network(
        customCover,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    } else if (youtubeThumbnail != null) {
      image = Image.network(
        youtubeThumbnail,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.network(
          'https://img.youtube.com/vi/${modul.youtubeId}/hqdefault.jpg',
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder,
        ),
      );
    } else {
      image = placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          image,
          if (isVideo && customCover == null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x4D000000), blurRadius: 10),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(ModuleModel modul) {
    final bool isVideo = modul.isVideo || (modul.idTipeModul == 1);
    final String typeName =
        modul.namaTipe ?? (isVideo ? 'Video Pembelajaran' : 'Dokumen PDF');
    final Color badgeColor = isVideo
        ? const Color(0xFF7C3AED)
        : const Color(0xFF2563EB);
    final bool isDone = modul.isMateriSelesai;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentModuleDetailPage(module: modul),
              ),
            ).then((_) => _loadModules());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModuleCover(modul, isVideo),
                const SizedBox(height: 12),

                // Header row: Type Badge & Completion status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVideo
                                ? Icons.play_circle_fill_rounded
                                : Icons.picture_as_pdf_rounded,
                            size: 14,
                            color: badgeColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            typeName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                            size: 13,
                            color: isDone
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDone ? 'Selesai' : 'Belum Selesai',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDone
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  modul.judulModul,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Meta row: Jenjang + XP + Quiz status
                Row(
                  children: [
                    if (modul.namaJenjang != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          modul.namaJenjang!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 12,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '+${modul.poinModul} XP',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (modul.idQuiz != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 12,
                              color: Color(0xFF7C3AED),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Ada Kuis',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudentModuleDetailPage(module: modul),
                        ),
                      ).then((_) => _loadModules());
                    },
                    icon: Icon(
                      isVideo
                          ? Icons.play_arrow_rounded
                          : Icons.menu_book_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isDone ? 'Buka Kembali Materi' : 'Pelajari Sekarang 🚀',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDone
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
