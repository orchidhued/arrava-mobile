import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
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
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadModules() async {
    await context.read<ModuleProvider>().fetchModules();
  }

  List<String> _getFilters(List<ModuleModel> modules) {
    final mapels = modules
        .map((m) => m.namaMapel)
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();
    mapels.sort();
    return ['Semua', ...mapels];
  }

  List<ModuleModel> _getFilteredModules(List<ModuleModel> modules) {
    if (_selectedFilter == 'Semua') {
      return modules;
    }
    return modules.where((m) => m.namaMapel == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModuleProvider>();
    final modules = provider.modules;
    final filteredModules = _getFilteredModules(modules);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadModules,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildHeader(),

              const SizedBox(height: 24),

              _buildStats(modules),

              const SizedBox(height: 20),

              _buildFilter(modules),

              const SizedBox(height: 20),

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
                .where(
                  (module) => module.progressModul?.toLowerCase() == 'tersedia',
                )
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

  Widget _buildFilter(List<ModuleModel> modules) {
    final filters = _getFilters(modules);
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == _selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: 1.2,
            ),
          );
        },
      ),
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

          const Text(
            'Belum ada modul',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Text(
            'Data modul dari database belum tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: _loadModules,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
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

          Row(
            children: [
              Icon(Icons.tag, size: 16, color: Colors.grey.shade500),

              const SizedBox(width: 5),

              Text(
                'ID Modul: ${module.idModul}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              if (module.namaMapel != null && module.namaMapel!.isNotEmpty) ...[
                const SizedBox(width: 8),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF047857),
        ),
      ),
    );
  }
}
