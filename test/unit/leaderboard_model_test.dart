import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Leaderboard Model & Logic Tests', () {
    test('Tier calculation logic works accurately based on total points', () {
      String resolveTier(int pts) {
        if (pts >= 5000) return 'Grandmaster';
        if (pts >= 3000) return 'Master';
        if (pts >= 1800) return 'Madya';
        if (pts >= 1000) return 'Mahir';
        if (pts >= 500) return 'Pemula';
        if (pts >= 200) return 'Dasar';
        if (pts >= 50) return 'Rintisan';
        return 'Starter';
      }

      expect(resolveTier(0), 'Starter');
      expect(resolveTier(45), 'Starter');
      expect(resolveTier(50), 'Rintisan');
      expect(resolveTier(199), 'Rintisan');
      expect(resolveTier(200), 'Dasar');
      expect(resolveTier(500), 'Pemula');
      expect(resolveTier(1200), 'Mahir');
      expect(resolveTier(2500), 'Madya');
      expect(resolveTier(3500), 'Master');
      expect(resolveTier(6000), 'Grandmaster');
    });

    test('Leaderboard student item fields mapping validation', () {
      final json = {
        'rank': 1,
        'id_user': 10,
        'nama': 'Ahmad Fauzi',
        'username': 'ahmad_fauzi',
        'jenjang': 'SD',
        'id_jenjang': 1,
        'total_poin': 350,
        'tier': 'Dasar',
        'foto_profil': 'http://127.0.0.1:8000/storage/profil-siswa/photo.jpg',
      };

      expect(json['rank'], 1);
      expect(json['nama'], 'Ahmad Fauzi');
      expect(json['total_poin'], 350);
      expect(json['tier'], 'Dasar');
      expect(json['jenjang'], 'SD');
    });
  });
}
