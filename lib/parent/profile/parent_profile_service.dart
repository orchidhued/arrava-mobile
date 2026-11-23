import 'dart:typed_data';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';

class ParentProfile {
  final String name;
  final String email;
  final String phone;
  final String? photo;

  const ParentProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.photo,
  });

  factory ParentProfile.fromResponse(dynamic response) {
    final data = response is Map ? response['data'] : null;
    if (data is! Map) {
      throw const FormatException('Data profil tidak tersedia.');
    }

    return ParentProfile(
      name: data['nama']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['nomor_hp']?.toString() ?? '',
      photo: ApiConstants.resolveMediaUrl(data['foto_profil']?.toString()),
    );
  }
}

class ParentProfileService {
  static Future<ParentProfile> load() async {
    final response = await ApiClient.get(ApiConstants.parentProfile);
    return ParentProfile.fromResponse(response);
  }

  static Future<ParentProfile> save({
    required String name,
    required String email,
    required String phone,
    ({Uint8List bytes, String filename})? photo,
  }) async {
    final fields = {'nama': name, 'email': email, 'nomor_hp': phone};
    final response = photo == null
        ? await ApiClient.post(ApiConstants.parentProfile, body: fields)
        : await ApiClient.postMultipart(
            ApiConstants.parentProfile,
            fields: fields,
            photoBytes: photo.bytes,
            photoFilename: photo.filename,
          );
    final profile = ParentProfile.fromResponse(response);
    await SecureStorage.write('user_name', profile.name);
    await SecureStorage.write('user_email', profile.email);
    return profile;
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) async {
    final response = await ApiClient.put(
      ApiConstants.parentPassword,
      body: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': confirmation,
      },
    );
    if (response is! Map || response['success'] != true) {
      throw const FormatException('Kata sandi gagal diperbarui.');
    }
  }
}
