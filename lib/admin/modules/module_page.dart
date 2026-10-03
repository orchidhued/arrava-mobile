import 'package:flutter/material.dart';

import '../../models/module.dart';
import '../../services/module_service.dart';

class ModulePage extends StatefulWidget {
  const ModulePage({super.key});

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  List<Module> _modules = [];

  bool _isLoading = true;
  String? _errorMessage;

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
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final modules = await ModuleService.getModules();

      if (!mounted) return;

      setState(() {
        _modules = modules;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Module> get _filteredModules {
    if (_selectedFilter == 'Semua') {
      return _modules;
    }

    // Untuk sementara filter kategori belum diterapkan
    // karena API saat ini belum mengirim nama kategori.
    return _modules;
  }

  @override
  Widget build(BuildContext context) {
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

              _buildStats(),

              const SizedBox(height: 20),

              _buildFilter(),

              const SizedBox(height: 20),

              _buildContent(),
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

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Modul',
            value: _modules.length.toString(),
            icon: Icons.menu_book_outlined,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            title: 'Modul Aktif',
            value: _modules
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_filteredModules.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _filteredModules
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

  Widget _buildErrorState() {
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
            _errorMessage ?? 'Terjadi kesalahan.',
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

  Widget _buildModuleCard(Module module) {
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