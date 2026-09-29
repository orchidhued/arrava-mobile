import 'package:flutter/material.dart';

class AddModulePage extends StatefulWidget {
  const AddModulePage({super.key});

  @override
  State<AddModulePage> createState() => _AddModulePageState();
}

class _AddModulePageState extends State<AddModulePage> {
  static const Color surface = Color(0xFFF8F9FF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFEFF4FF);
  static const Color surfaceHigh = Color(0xFFDCE9FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color text = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color secondaryContainer = Color(0xFFDAE2FD);
  static const Color tertiary = Color(0xFF006242);
  static const Color error = Color(0xFFBA1A1A);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String _moduleType = 'Video Belajar';
  String _level = 'SD';
  String? _materialFile;
  String? _coverFile;

  final List<String> _moduleTypes = ['Video Belajar', 'PDF / Dokumen'];

  final List<String> _levels = ['SD', 'SMP', 'SMA/K'];

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      bottomNavigationBar: _buildBottomActions(),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    _buildIntroCard(),
                    const SizedBox(height: 16),
                    _buildTitleCard(),
                    const SizedBox(height: 16),
                    _buildTypeCard(),
                    const SizedBox(height: 16),
                    _buildLevelCard(),
                    const SizedBox(height: 16),
                    _buildUploadCard(),
                    const SizedBox(height: 16),
                    _buildDividerText(),
                    const SizedBox(height: 16),
                    _buildUrlCard(),
                    const SizedBox(height: 16),
                    _buildCoverCard(),
                    const SizedBox(height: 16),
                    _buildAnnouncementCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: .94),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: text,
              tooltip: 'Kembali',
            ),
            const SizedBox(width: 2),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Modul',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                  Text(
                    'Draft Otomatis Tersimpan',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIntroCard() {
    return _card(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Modul Baru',
            style: TextStyle(
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Formulir ini digunakan oleh admin untuk menambahkan modul baru ke sistem pembelajaran sekolah dan madrasah.',
            style: TextStyle(fontSize: 14, height: 1.45, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Judul Modul Pembelajaran *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
              ),
              Text(
                '${_titleController.text.length}/100',
                style: const TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            maxLength: 100,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Masukkan judul modul pembelajaran...',
              hintStyle: const TextStyle(fontSize: 14, color: outline),
              prefixIcon: const Icon(
                Icons.menu_book_outlined,
                color: primary,
                size: 20,
              ),
              filled: true,
              fillColor: surfaceLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 14, color: textSecondary),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Gunakan judul yang ringkas, deskriptif, dan memuat bab kompetensi.',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Modul *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _moduleTypes.map((type) {
              final selected = _moduleType == type;
              final isVideo = type == 'Video Belajar';

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: type == _moduleTypes.first ? 4 : 0,
                    left: type == _moduleTypes.last ? 4 : 0,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _moduleType = type),
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? primary : surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isVideo
                                ? Icons.smart_display_outlined
                                : Icons.description_outlined,
                            size: 20,
                            color: selected ? Colors.white : textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isVideo ? 'MP4, Stream' : 'E-book & Catatan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? Colors.white.withValues(alpha: .8)
                                        : textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Jenjang Pendidikan *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.school_outlined, size: 14, color: tertiary),
                  const SizedBox(width: 3),
                  const Text(
                    'Terpilih: ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tertiary,
                    ),
                  ),
                  Text(
                    _level,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _levels.map((level) {
              final selected = _level == level;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: level != _levels.last ? 4 : 0,
                    left: level != _levels.first ? 4 : 0,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _level = level),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? primary : surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        level,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : text,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Berkas Materi (PDF / PPT)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Opsional jika modul berbasis video/tautan eksternal.',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showMaterialPicker(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _materialFile ?? 'Pilih berkas atau seret ke sini',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Format: .pdf, .ppt, .pptx (Maksimal 50MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _showMaterialPicker,
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    label: const Text('Jelajahi File'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: card,
                      foregroundColor: primary,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_materialFile != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.task_alt, color: tertiary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _materialFile!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _materialFile = null);
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaterialPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Berkas Materi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: error,
                  ),
                  title: const Text('dokumen_materi.pdf'),
                  onTap: () {
                    setState(() => _materialFile = 'dokumen_materi.pdf');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.slideshow_outlined, color: primary),
                  title: const Text('presentasi_materi.pptx'),
                  onTap: () {
                    setState(() => _materialFile = 'presentasi_materi.pptx');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDividerText() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: surfaceHigh,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Atau masukkan tautan video / materi daring',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: surfaceHigh,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Tautan Video / Materi Luar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
              ),
              Text(
                'Streaming / Cloud',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://www.youtube.com/watch?v=...',
              hintStyle: const TextStyle(fontSize: 14, color: outline),
              prefixIcon: const Icon(
                Icons.link,
                color: textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: surfaceLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mendukung YouTube, Vimeo, Google Drive, atau LMS internal.',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gambar Sampul / Thumbnail (Opsional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Rasio rekomendasi 16:9 untuk card pembelajaran siswa.',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 56,
                  decoration: BoxDecoration(
                    color: surfaceHigh,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 24,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _coverFile = 'sampul_modul.jpg');
                        },
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 16,
                        ),
                        label: const Text('Pilih Sampul'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _coverFile ?? 'Belum ada file dipilih',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTIONS
  // ============================================================

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: surface,
        border: const Border(top: BorderSide(color: surfaceHigh, width: 1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: surfaceLow,
                    foregroundColor: text,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              flex: 3,
              child: SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _publishModule,
                  icon: const Icon(Icons.publish_outlined, size: 17),
                  label: const Text(
                    'Terbitkan Modul',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _publishModule() {
    _showMessage('Modul siap diterbitkan.');
  }

  Widget _buildAnnouncementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withValues(alpha: .03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengumuman Distribusi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Modul yang diterbitkan akan langsung dapat diakses oleh guru dan siswa pada jenjang yang dipilih secara otomatis tanpa persetujuan tambahan.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
