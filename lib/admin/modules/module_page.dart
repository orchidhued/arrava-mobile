import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  final List<String> _filters = [
    'Semua',
    'Pemrograman',
    'Desain UI/UX',
    'Data Science',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadModules() async {
    await context.read<ModuleProvider>().fetchModules();
  }

  List<ModuleModel> _getFilteredModules(List<ModuleModel> modules) {
    if (_selectedFilter == 'Semua') {
      return modules;
    }
    return modules;
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

              _buildFilter(),

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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
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
                  (module) =>
                      module.progressModul?.toLowerCase() == 'tersedia',
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
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
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

  Widget _buildFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE5E7EB),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ModuleProvider provider, List<ModuleModel> filteredModules) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(),
        ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Data modul dari database belum tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
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
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),

          const SizedBox(height: 12),

          const Text(
            'Gagal mengambil data modul',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (module.fotoModul != null &&
              module.fotoModul!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                module.fotoModul!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _buildCoverPlaceholder();
                },
              ),
            )
          else
            _buildCoverPlaceholder(),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildStatusBadge(
                module.progressModul ?? 'Tersedia',
              ),

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
              Icon(
                Icons.tag,
                size: 16,
                color: Colors.grey.shade500,
              ),

              const SizedBox(width: 5),

              Text(
                'ID Modul: ${module.idModul}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: 48,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
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