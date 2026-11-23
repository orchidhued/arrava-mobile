import 'package:flutter/material.dart';

import '../../admin/modules/models/module_model.dart';
import '../../admin/modules/repositories/module_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/launcher_service.dart';
import '../../core/theme/app_colors.dart';

class ParentMaterialsList extends StatefulWidget {
  final int? jenjangId;

  const ParentMaterialsList({super.key, required this.jenjangId});

  @override
  State<ParentMaterialsList> createState() => _ParentMaterialsListState();
}

class _ParentMaterialsListState extends State<ParentMaterialsList> {
  late Future<List<ModuleModel>> _modules = _loadModules();

  @override
  void didUpdateWidget(covariant ParentMaterialsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.jenjangId != oldWidget.jenjangId) _modules = _loadModules();
  }

  Future<List<ModuleModel>> _loadModules() => ModuleRepository().getModules(
    status: 'published',
    jenjang: widget.jenjangId,
  );

  Future<void> _openMaterial(String url, {required bool isVideo}) async {
    final opened = isVideo
        ? await LauncherService.openUrl(url)
        : await LauncherService.openPdf(url);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Materi gagal dibuka.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModuleModel>>(
      future: _modules,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              title: const Text('Materi gagal dimuat.'),
              trailing: TextButton(
                onPressed: () => setState(() => _modules = _loadModules()),
                child: const Text('Coba lagi'),
              ),
            ),
          );
        }

        final modules = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Materi yang tersedia'),
            const SizedBox(height: 8),
            if (modules.isEmpty)
              const Card(
                child: ListTile(title: Text('Belum ada materi tersedia.')),
              ),
            for (final module in modules) ...[
              _buildModuleTile(module),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  Widget _buildModuleTile(ModuleModel module) {
    final url = ApiConstants.resolveMediaUrl(
      module.isVideo ? module.videoPlayUrl : module.pdfDocumentUrl,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          module.isVideo
              ? Icons.play_circle_outline
              : Icons.picture_as_pdf_outlined,
          color: AppColors.primary,
        ),
        title: Text(module.judulModul),
        subtitle: Text(module.namaMapel ?? module.namaTipe ?? 'Modul belajar'),
        trailing: url == null ? null : const Icon(Icons.open_in_new_rounded),
        onTap: url == null
            ? null
            : () => _openMaterial(url, isVideo: module.isVideo),
      ),
    );
  }
}
