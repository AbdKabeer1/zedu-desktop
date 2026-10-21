import 'dart:async';

import '../../../../../helpers/helpers.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class _FakeWorkspaceNotifier extends WorkspaceNotifier {
  @override
  WorkspaceState build() => const WorkspaceState(
    selectedWorkspace: Workspace(
      id: 'org-1',
      name: 'Test Workspace',
      avatar: '',
    ),
  );
}

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
        expect(sent.name, '');
        expect(sent.phoneNumber, '+2348012345678');

        final shown = container.read(userProfileNotifierProvider).account!;
        expect(shown.phoneNumber, '+2348012345678');
        expect(shown.name, placeholder.name);
        expect(shown.email, placeholder.email);
      });
    });
  });

  group('UserProfileNotifier.updateNotificationPreferences', () {
    late MockUserProfileRepository repository;
    late ProviderContainer container;

    final edited = NotificationPreferences.empty().copyWith(
      mode: NotificationMode.mentionsOnly,
    );

    setUp(() {
      repository = MockUserProfileRepository();

      final storage = MockSecureStorageService();
      when(() => storage.readData(any())).thenAnswer((_) async => null);
      if (locator.isRegistered<SecureStorageService>()) {
        locator.unregister<SecureStorageService>();
      }
      locator.registerSingleton<SecureStorageService>(storage);
      if (locator.isRegistered<AppConfig>()) locator.unregister<AppConfig>();
      locator.registerSingleton<AppConfig>(
        const AppConfig(apiBaseUrl: 'http://test/', usesMockData: false),
      );

      when(
        () => repository.getAccount(),
      ).thenAnswer((_) async => Success(ProfileAccount.empty()));
      when(
        () => repository.getNotificationPreferences(orgId: any(named: 'orgId')),
      ).thenAnswer((_) async => Success(NotificationPreferences.empty()));
      when(
        () => repository.getSecuritySessions(),
      ).thenAnswer((_) async => const Success(<SecuritySession>[]));
      when(
        () => repository.getOrganization(orgId: any(named: 'orgId')),
      ).thenAnswer(
        (_) async => const Success(
          OrganizationProfile(
            id: '',
            name: '',
            natureOfBusiness: '',
            country: '',
          ),
        ),
      );
      when(
        () => repository.getTeamMembers(orgId: any(named: 'orgId')),
      ).thenAnswer((_) async => const Success(<TeamMember>[]));
      when(
        () => repository.getRolesAndPermissions(),
      ).thenAnswer((_) async => const Success(<RolePermission>[]));
      when(
        () => repository.getBillingInfo(),
      ).thenAnswer((_) async => Success(BillingInfo.empty()));

      container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
    });

    tearDown(() {
      locator.unregister<SecureStorageService>();
      locator.unregister<AppConfig>();
    });

    Future<UserProfileState> loaded() async {
      final completer = Completer<UserProfileState>();
      final subscription = container.listen<UserProfileState>(
        userProfileNotifierProvider,
        (_, next) {
          if (!next.isLoading && !completer.isCompleted) {
            completer.complete(next);
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      return completer.future.timeout(const Duration(seconds: 5));
    }

    void stubSave(Future<Result<NotificationPreferences>> Function() answer) {
      when(
        () => repository.updateNotificationPreferences(
          orgId: any(named: 'orgId'),
          preferences: edited,
        ),
      ).thenAnswer((_) => answer());
    }

    test('makes the saved preferences the new baseline', () async {
      stubSave(() async => Success(edited));
      await loaded();
      final notifier = container.read(userProfileNotifierProvider.notifier);

      await notifier.updateNotificationPreferences(edited);

      final state = container.read(userProfileNotifierProvider);
      expect(state.notifications, edited);
      expect(state.isSaving, isFalse);
      expect(state.error, isNull);
    });

    test('keeps the old baseline and reports a failed save', () async {
      stubSave(
        () async => const Failure(
          ApiFailure(message: 'Nope', kind: ApiFailureKind.client),
        ),
      );
      await loaded();
      final notifier = container.read(userProfileNotifierProvider.notifier);

      await notifier.updateNotificationPreferences(edited);

      final state = container.read(userProfileNotifierProvider);
      expect(state.notifications, NotificationPreferences.empty());
      expect(state.isSaving, isFalse);
      expect(state.error, 'Nope');
    });

    test('ignores a second save while one is running', () async {
      final pending = Completer<Result<NotificationPreferences>>();
      stubSave(() => pending.future);
      await loaded();
      final notifier = container.read(userProfileNotifierProvider.notifier);

      final first = notifier.updateNotificationPreferences(edited);
      await notifier.updateNotificationPreferences(edited);
      pending.complete(Success(edited));
      await first;

      verify(
        () => repository.updateNotificationPreferences(
          orgId: any(named: 'orgId'),
          preferences: edited,
        ),
      ).called(1);
    });
  });

  group('UserProfileNotifier.inviteMember', () {
    late MockUserProfileRepository repository;

    setUp(() {
      registerFallbackValue('');
      repository = MockUserProfileRepository();

      locator.registerSingleton<AppConfig>(
        AppConfig(apiBaseUrl: 'https://api.example.com', usesMockData: false),
      );
      final mockStorage = MockSecureStorageService();
      when(() => mockStorage.readData(any())).thenAnswer((_) async => null);
      locator.registerSingleton<SecureStorageService>(mockStorage);

      // Stub every repository call made by the background load() microtask
      // scheduled in build() so it completes without errors.
      when(
        () => repository.getAccount(),
      ).thenAnswer((_) async => Success(ProfileAccount.empty()));
      when(
        () => repository.getNotificationPreferences(),
      ).thenAnswer((_) async => Success(NotificationPreferences.empty()));
      when(
        () => repository.getSecuritySessions(),
      ).thenAnswer((_) async => Success(<SecuritySession>[]));
      when(
        () => repository.getOrganization(),
      ).thenAnswer((_) async => Success(OrganizationProfile.empty()));
      when(
        () => repository.getTeamMembers(orgId: any(named: 'orgId')),
      ).thenAnswer((_) async => Success(<TeamMember>[]));
      when(
        () => repository.getRolesAndPermissions(),
      ).thenAnswer((_) async => Success(<RolePermission>[]));
      when(
        () => repository.getBillingInfo(),
      ).thenAnswer((_) async => Success(BillingInfo.empty()));
    });

    tearDown(() async {
      await locator.reset();
    });

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repository),
          workspaceProvider.overrideWith(_FakeWorkspaceNotifier.new),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    /// Waits for the background [load] microtask (scheduled in [build])
    /// to finish before interacting with the notifier.
    Future<void> waitForLoad(ProviderContainer container) async {
      while (container.read(userProfileNotifierProvider).isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('stores the selected role name instead of the backend UUID '
        'returned by inviteMember', () async {
      final roleUuid = '019700d8-9085-7f7b-839a-fcbd08b9e26d';
      final invitedMember = TeamMember(
        id: 'new-member',
        email: 'invitee@example.com',
        role: roleUuid,
        dateJoined: '2026-01-01',
        status: TeamMemberStatus.pending,
      );
      when(
        () => repository.inviteMember(
          email: any(named: 'email'),
          role: any(named: 'role'),
          orgId: any(named: 'orgId'),
        ),
      ).thenAnswer((_) async => Success(invitedMember));

      final container = makeContainer();
      await waitForLoad(container);

      await container
          .read(userProfileNotifierProvider.notifier)
          .inviteMember(email: 'invitee@example.com', role: 'User');

      final state = container.read(userProfileNotifierProvider);
      expect(state.teamMembers, hasLength(1));
      expect(
        state.teamMembers.first.role,
        equals('User'),
        reason:
            'role should be the human-readable name passed to '
            'inviteMember, not the UUID returned by the backend',
      );
      expect(state.teamMembers.first.email, equals('invitee@example.com'));
      expect(state.teamMembers.first.id, equals('new-member'));
      expect(state.isSaving, isFalse);
      expect(state.successMessage, isNotNull);
    });

    test('does not add a member when the invitation fails', () async {
      when(
        () => repository.inviteMember(
          email: any(named: 'email'),
          role: any(named: 'role'),
          orgId: any(named: 'orgId'),
        ),
      ).thenAnswer(
        (_) async =>
            Failure<TeamMember>(ApiFailure(message: 'Unable to invite member')),
      );

      final container = makeContainer();
      await waitForLoad(container);

      await container
          .read(userProfileNotifierProvider.notifier)
          .inviteMember(email: 'invitee@example.com', role: 'User');

      final state = container.read(userProfileNotifierProvider);
      expect(state.teamMembers, isEmpty);
      expect(state.isSaving, isFalse);
      expect(state.error, isNotNull);
    });
  });
}
