import 'dart:async';

import '../../../../../helpers/helpers.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  group('UserProfileNotifier.updateAccount', () {
    late MockUserProfileRepository repository;

    setUpAll(() => registerFallbackValue(ProfileAccount.empty()));

    setUp(() {
      repository = MockUserProfileRepository();
      when(
        () => repository.updateAccount(any()),
      ).thenAnswer((_) async => Success(ProfileAccount.empty()));
    });

    // The profile load started in build() still fails with the
    // uninitialized-provider error tracked in #51, so it's ignored here; the
    // account is then the placeholder the edit form opens with.
    Future<void> ignoringProfileLoadError(Future<void> Function() body) {
      final done = Completer<void>();
      runZonedGuarded(
        () => body().then(done.complete, onError: done.completeError),
        (error, stack) {
          if (error is! StateError) done.completeError(error, stack);
        },
      );
      return done.future;
    }

    test('sends only the edited fields and shows only what was saved', () {
      return ignoringProfileLoadError(() async {
        final container = ProviderContainer(
          overrides: [
            userProfileRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(userProfileNotifierProvider.notifier);
        final placeholder = ProfileAccount.empty();

        await notifier.updateAccount(
          placeholder.copyWith(
            phoneNumber: '+2348012345678',
            email: 'me@zedu.chat',
          ),
        );

        final sent =
            verify(() => repository.updateAccount(captureAny())).captured.single
                as ProfileAccount;
        expect(sent.name, kUnchangedField);
        expect(sent.phoneNumber, '+2348012345678');

        final shown = container.read(userProfileNotifierProvider).account!;
        expect(shown.phoneNumber, '+2348012345678');
        expect(shown.name, placeholder.name);
        expect(shown.email, placeholder.email);
      });
    });

    test(
      'allows clearing optional fields (title, phone, display name, pronunciation)',
      () {
        return ignoringProfileLoadError(() async {
          final container = ProviderContainer(
            overrides: [
              userProfileRepositoryProvider.overrideWithValue(repository),
            ],
          );
          addTearDown(container.dispose);
          final notifier = container.read(userProfileNotifierProvider.notifier);
          const current = ProfileAccount(
            name: 'Jane Doe',
            email: 'jane@zedu.chat',
            timezone: 'Africa/Lagos',
            title: 'Software Engineer',
            phoneNumber: '+2348012345678',
            displayName: 'JaneD',
            namePronunciation: 'Jayn',
          );

          notifier.state = notifier.state.copyWith(account: current);

          await notifier.updateAccount(
            current.copyWith(
              title: '',
              phoneNumber: '',
              displayName: '',
              namePronunciation: '',
            ),
          );

          final sent =
              verify(
                    () => repository.updateAccount(captureAny()),
                  ).captured.single
                  as ProfileAccount;
          expect(sent.name, kUnchangedField);
          expect(sent.title, '');
          expect(sent.phoneNumber, '');
          expect(sent.displayName, '');
          expect(sent.namePronunciation, '');

          final shown = container.read(userProfileNotifierProvider).account!;
          expect(shown.title, '');
          expect(shown.phoneNumber, '');
          expect(shown.displayName, '');
          expect(shown.namePronunciation, '');
          expect(shown.name, 'Jane Doe');
        });
      },
    );
  });
}
