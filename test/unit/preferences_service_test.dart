import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrava_mobile/core/storage/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PreferencesService Audio & Haptic Tests', () {
    test('Default audio and haptic settings should be true', () async {
      expect(await PreferencesService.isSoundEnabled(), isTrue);
      expect(await PreferencesService.isHapticEnabled(), isTrue);
      expect(await PreferencesService.isBgmEnabled(), isTrue);
    });

    test('Toggling sound and haptic should persist values', () async {
      await PreferencesService.setSoundEnabled(false);
      expect(await PreferencesService.isSoundEnabled(), isFalse);

      await PreferencesService.setHapticEnabled(false);
      expect(await PreferencesService.isHapticEnabled(), isFalse);

      await PreferencesService.setBgmEnabled(false);
      expect(await PreferencesService.isBgmEnabled(), isFalse);
    });
  });

  group('PreferencesService Quiz Draft Tests', () {
    const int quizId = 42;

    test('Initial draft state should be empty', () async {
      expect(await PreferencesService.hasQuizDraft(quizId), isFalse);
      expect(await PreferencesService.getQuizDraft(quizId), isNull);
    });

    test('Saving and retrieving quiz draft should preserve data accurately', () async {
      final answers = {1: 'A', 2: 'C', 5: 'Jawaban Singkat'};
      await PreferencesService.saveQuizDraft(
        quizId: quizId,
        answers: answers,
        currentIndex: 2,
        remainingSeconds: 150,
      );

      expect(await PreferencesService.hasQuizDraft(quizId), isTrue);

      final draft = await PreferencesService.getQuizDraft(quizId);
      expect(draft, isNotNull);
      expect(draft!['quizId'], equals(quizId));
      expect(draft['currentIndex'], equals(2));
      expect(draft['remainingSeconds'], equals(150));

      final retrievedAnswers = draft['answers'] as Map<int, String>;
      expect(retrievedAnswers[1], equals('A'));
      expect(retrievedAnswers[2], equals('C'));
      expect(retrievedAnswers[5], equals('Jawaban Singkat'));
    });

    test('clearQuizDraft should remove the draft completely', () async {
      await PreferencesService.saveQuizDraft(
        quizId: quizId,
        answers: {1: 'A'},
        currentIndex: 0,
      );
      expect(await PreferencesService.hasQuizDraft(quizId), isTrue);

      await PreferencesService.clearQuizDraft(quizId);
      expect(await PreferencesService.hasQuizDraft(quizId), isFalse);
      expect(await PreferencesService.getQuizDraft(quizId), isNull);
    });
  });
}
