import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/student_style_filter_bar.dart';
import 'models/module_model.dart';
import 'providers/module_provider.dart';

class ModulePage extends StatelessWidget {
  const ModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModuleProvider()..fetchModules(),
      child: const _ModulePageContent(),
    );
  }
}

class _ModulePageContent extends StatefulWidget {
  const _ModulePageContent();

  @override
  State<_ModulePageContent> createState() => _ModulePageContentState();
}

class _ModulePageContentState extends State<_ModulePageContent> {
  static const List<String> _primaryFilters = [
    'Semua',
    'Terbit',
    'Draft',
    'Video',
    'PDF',
  ];
  static const List<String> _jenjangFilters = [
    'Semua Jenjang',
    'SD',
    'SMP',
    'SMA',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _selectedJenjang = 'Semua Jenjang';
  String _selectedMapel = 'Semua Mapel';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadModules() async {
    await context.read<ModuleProvider>().fetchModules();
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty ||
      _selectedFilter != 'Semua' ||
      _selectedJenjang != 'Semua Jenjang' ||
      _selectedMapel != 'Semua Mapel';

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedFilter = 'Semua';
      _selectedJenjang = 'Semua Jenjang';
      _selectedMapel = 'Semua Mapel';
    });
  }

  List<String> _getMapels(List<ModuleModel> modules) {
    final mapels = modules
        .map((m) => m.namaMapel?.trim())
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    mapels.sort();
    return mapels;
  }

  List<ModuleModel> _getFilteredModules(
    List<ModuleModel> modules,
    List<String> mapels,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final activeMapel = mapels.contains(_selectedMapel)
        ? _selectedMapel
        : 'Semua Mapel';

    return modules.where((m) {
      final matchQuery =
          query.isEmpty ||
          m.judulModul.toLowerCase().contains(query) ||
          (m.namaMapel?.toLowerCase().contains(query) ?? false) ||
          (m.namaJenjang?.toLowerCase().contains(query) ?? false) ||
          (m.namaTipe?.toLowerCase().contains(query) ?? false);

      final isVideo =
          m.isVideo ||
          m.idTipeModul == 1 ||
          (m.namaTipe?.toLowerCase().contains('video') ?? false);
      final isPdf =
          m.isPdf ||
          m.idTipeModul == 2 ||
          (m.namaTipe?.toLowerCase().contains('pdf') ?? false);

      final bool matchPrimary;
      switch (_selectedFilter) {
        case 'Terbit':
          matchPrimary = !m.isDraft;
          break;
        case 'Draft':
          matchPrimary = m.isDraft;
          break;
        case 'Video':
          matchPrimary = isVideo;
          break;
        case 'PDF':
          matchPrimary = isPdf;
          break;
        default:
          matchPrimary = true;
      }

      final matchJenjang = matchesJenjangFilter(
        m.namaJenjang,
        _selectedJenjang,
        idJenjang: m.idJenjang,
      );

      final matchMapel =
          activeMapel == 'Semua Mapel' || m.namaMapel?.trim() == activeMapel;

      return matchQuery && matchPrimary && matchJenjang && matchMapel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModuleProvider>();
    final modules = provider.modules;
    final mapels = _getMapels(modules);
    final filteredModules = _getFilteredModules(modules, mapels);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadModules,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildStats(modules),

              const SizedBox(height: 18),

              _buildFilter(mapels),

              const SizedBox(height: 14),

              Row(
                children: [
                  Text(
                    'Menampilkan ${filteredModules.length} modul',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: kStudentFilterMuted,
                    ),
                  ),
                  const Spacer(),
                  if (_hasActiveFilters)
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh_rounded, size: 15),
                      label: const Text(
                        'Reset Filter',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: kStudentFilterBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              _buildContent(provider, filteredModules),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Modul',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Kelola modul pembelajaran yang tersedia.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStats(List<ModuleModel> modules) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Modul',
            value: modules.length.toString(),
            icon: Icons.menu_book_outlined,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            title: 'Modul Aktif',
            value: modules
                .where((module) => !module.isDraft)
                .length
                .toString(),
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(List<String> mapels) {
    final activeMapel = mapels.contains(_selectedMapel)
        ? _selectedMapel
        : 'Semua Mapel';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudentStyleSearchField(
          controller: _searchController,
          hintText: 'Cari judul, mapel, atau jenjang modul...',
          hasQuery: _searchController.text.isNotEmpty,
          onChanged: (_) => setState(() {}),
          onClear: () {
            _searchController.clear();
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        StudentStyleFilterChipBar(
          options: _primaryFilters,
          selectedOption: _selectedFilter,
          onSelected: (value) => setState(() => _selectedFilter = value),
        ),
        const SizedBox(height: 8),
        StudentStyleFilterChipBar(
          options: _jenjangFilters,
          selectedOption: _selectedJenjang,
          onSelected: (value) => setState(() => _selectedJenjang = value),
        ),
        if (mapels.isNotEmpty) ...[
          const SizedBox(height: 8),
          StudentStyleFilterChipBar(
            options: ['Semua Mapel', ...mapels],
            selectedOption: activeMapel,
            onSelected: (value) => setState(() => _selectedMapel = value),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(
    ModuleProvider provider,
    List<ModuleModel> filteredModules,
  ) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }

    if (filteredModules.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: filteredModules
          .map((module) => _buildModuleCard(module))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _hasActiveFilters;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 32,
              color: Color(0xFF2563EB),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            hasFilters ? 'Modul tidak ditemukan' : 'Belum ada modul',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Text(
            hasFilters
                ? 'Coba ubah kata kunci pencarian atau filter di atas.'
                : 'Data modul dari database belum tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: hasFilters ? _resetFilters : _loadModules,
            icon: Icon(hasFilters ? Icons.filter_alt_off_rounded : Icons.refresh),
            label: Text(hasFilters ? 'Reset Filter' : 'Muat Ulang'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),

          const SizedBox(height: 12),

          const Text(
            'Gagal mengambil data modul',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _loadModules,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(ModuleModel module) {
    final isVideo = module.isVideo || module.idTipeModul == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow3D,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleCover(module, isVideo),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildStatusBadge(module.progressModul ?? 'Tersedia'),

              const Spacer(),

              if (module.tipeFile != null)
                Text(
                  module.tipeFile!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            module.judulModul,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tag, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 5),
                  Text(
                    'ID Modul: ${module.idModul}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (module.namaJenjang != null &&
                  module.namaJenjang!.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Text(
                    '🎓 ${module.namaJenjang}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              if (module.namaMapel != null &&
                  module.namaMapel!.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    '📖 ${module.namaMapel}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCover(ModuleModel module, bool isVideo) {
    final customCover = ApiConstants.resolveMediaUrl(
      module.fotoUrl?.isNotEmpty == true ? module.fotoUrl : module.fotoModul,
    );
    final youtubeThumbnail = module.youtubeId?.isNotEmpty == true
        ? 'https://img.youtube.com/vi/${module.youtubeId}/maxresdefault.jpg'
        : null;

    Widget placeholder() {
      return Container(
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
          borderRadius: BorderRadius.circular(14),
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
    }

    Widget cover;
    if (customCover != null) {
      cover = Image.network(
        customCover,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder(),
      );
    } else if (youtubeThumbnail != null) {
      cover = Image.network(
        youtubeThumbnail,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.network(
          'https://img.youtube.com/vi/${module.youtubeId}/hqdefault.jpg',
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder(),
        ),
      );
    } else {
      cover = placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          cover,
          if (isVideo && customCover == null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                shape: BoxShape.circle,
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

  Widget _buildStatusBadge(String status) {
    final isDraft = status.toLowerCase() == 'draft';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isDraft ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDraft ? const Color(0xFFB45309) : const Color(0xFF047857),
        ),
      ),
    );
  }
}
