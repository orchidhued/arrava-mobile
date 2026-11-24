import 'package:flutter/material.dart';

import 'parent_profile_service.dart';

class ParentPasswordForm extends StatefulWidget {
  const ParentPasswordForm({super.key});

  @override
  State<ParentPasswordForm> createState() => _ParentPasswordFormState();
}

class _ParentPasswordFormState extends State<ParentPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ParentProfileService.changePassword(
        currentPassword: _current.text,
        password: _password.text,
        confirmation: _confirmation.text,
      );
      if (!mounted) return;
      _current.clear();
      _password.clear();
      _confirmation.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi berhasil diperbarui.')),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          TextFormField(
            controller: _current,
            enabled: !_saving,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Kata sandi saat ini'),
            validator: (value) =>
                (value ?? '').isEmpty ? 'Masukkan kata sandi saat ini.' : null,
          ),
          TextFormField(
            controller: _password,
            enabled: !_saving,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(labelText: 'Kata sandi baru'),
            validator: (value) =>
                (value ?? '').length < 8 ? 'Gunakan minimal 8 karakter.' : null,
          ),
          TextFormField(
            controller: _confirmation,
            enabled: !_saving,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(
              labelText: 'Konfirmasi kata sandi',
            ),
            validator: (value) => value != _password.text
                ? 'Konfirmasi kata sandi belum cocok.'
                : null,
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Menyimpan…' : 'Simpan Kata Sandi'),
          ),
        ],
      ),
    );
  }
}
