import 'dart:async';

import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

class FakeBuzzRepository extends BuzzRepository {
  FakeBuzzRepository({this.buzzId = 'buzz-123', this.token = 'token-abc'});

  final String buzzId;
  final String token;
  final List<(String, bool)> directCallResponses = <(String, bool)>[];
  final List<(String, bool)> invitationResponses = <(String, bool)>[];
  Completer<Map<String, dynamic>>? pendingInitiateCall;

  @override
  Future<Map<String, dynamic>> initiateDirectCall(String participantId) async {
    if (pendingInitiateCall != null) {
      return pendingInitiateCall!.future;
    }
    return <String, dynamic>{
      'success': true,
      'buzzId': buzzId,
      'token': token,
      'channelName': 'channel-$participantId',
    };
  }

  @override
  Future<bool> respondToDirectCall(String buzzId, bool accept) async {
    directCallResponses.add((buzzId, accept));
    return true;
  }

  @override
  Future<bool> respondToInvitation(String buzzId, bool accept) async {
    invitationResponses.add((buzzId, accept));
    return true;
  }
}

class _FakeRingtone implements CallRingtone {
  final calls = <String>[];

  @override
  Future<void> start() async => calls.add('start');

  @override
  Future<void> stop() async => calls.add('stop');

  @override
  Future<void> dispose() async => calls.add('dispose');
}

void main() {
  group('ActiveCallNotifier.initiateCall (#1281)', () {
    late FakeBuzzRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeBuzzRepository();
      container = ProviderContainer(
        overrides: [
          buzzRepositoryProvider.overrideWithValue(repository),
          activeCallProvider.overrideWith(
            (ref) => ActiveCallNotifier(
              ref,
              ringTimeout: const Duration(milliseconds: 250),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    test(
      'remains in calling status when no remote accept signal arrives',
      () async {
        final localContainer = ProviderContainer(
          overrides: [
            buzzRepositoryProvider.overrideWithValue(repository),
            activeCallProvider.overrideWith(
              (ref) => ActiveCallNotifier(
                ref,
                ringTimeout: const Duration(seconds: 30),
              ),
            ),
          ],
        );
        addTearDown(localContainer.dispose);

        final notifier = localContainer.read(activeCallProvider);
        await notifier.initiateCall(
          remoteUserId: 'user-2',
          remoteUserName: 'Bob',
          channelId: 'dm-1',
        );

        expect(notifier.state.status, CallStatus.calling);
        expect(notifier.state.buzzId, 'buzz-123');

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(notifier.state.status, CallStatus.calling);
      },
    );

    test(
      'transitions to active only on matching buzzId accept signal',
      () async {
        final notifier = container.read(activeCallProvider);
        await notifier.initiateCall(
          remoteUserId: 'user-2',
          remoteUserName: 'Bob',
          channelId: 'dm-1',
        );

        // Stale event for a different buzzId is ignored.
        repository.emitCallEvent(<String, dynamic>{
          'type': 'call_accepted',
          'buzzId': 'other-buzz-id',
        });
        await Future<void>.delayed(Duration.zero);
        expect(notifier.state.status, CallStatus.calling);

        // Matching accept event transitions to active.
        repository.emitCallEvent(<String, dynamic>{
          'type': 'call_accepted',
          'buzzId': 'buzz-123',
          'token': 'live-rtc-token',
        });
        await Future<void>.delayed(Duration.zero);

        expect(notifier.state.status, CallStatus.active);
        expect(notifier.state.token, 'live-rtc-token');
      },
    );

    test(
      'ends the call when the remote user declines or ring timeout elapses',
      () async {
        final notifier = container.read(activeCallProvider);
        await notifier.initiateCall(
          remoteUserId: 'user-2',
          remoteUserName: 'Bob',
          channelId: 'dm-1',
        );

        repository.emitCallEvent(<String, dynamic>{
          'type': 'call_declined',
          'buzzId': 'buzz-123',
        });
        await Future<void>.delayed(Duration.zero);
        expect(notifier.state.status, CallStatus.none);

        // Ring timeout also cancels an unanswered call.
        await notifier.initiateCall(
          remoteUserId: 'user-2',
          remoteUserName: 'Bob',
          channelId: 'dm-1',
        );
        expect(notifier.state.status, CallStatus.calling);

        await Future<void>.delayed(const Duration(milliseconds: 350));
        expect(notifier.state.status, CallStatus.none);
        expect(repository.directCallResponses, contains(('buzz-123', false)));
      },
    );

    test(
      'does not throw or leak subscriptions when disposed during initiateCall (#2572)',
      () async {
        repository.pendingInitiateCall = Completer<Map<String, dynamic>>();
        final notifier = container.read(activeCallProvider);

        final future = notifier.initiateCall(
          remoteUserId: 'user-2',
          remoteUserName: 'Bob',
          channelId: 'dm-1',
        );

        expect(notifier.state.status, CallStatus.calling);

        // Dispose while initiateCall is waiting on initiateDirectCall
        notifier.dispose();
        expect(notifier.isDisposed, isTrue);

        // Resolve the async network call
        repository.pendingInitiateCall!.complete(<String, dynamic>{
          'success': true,
          'buzzId': 'buzz-123',
          'token': 'token-abc',
          'channelName': 'channel-user-2',
        });

        await expectLater(future, completes);
        // Verify state is not modified and buzzId is not populated after disposal
        expect(notifier.state.buzzId, isNull);
      },
    );
  });

  group('ActiveCallNotifier incoming calls (#2917)', () {
    late FakeBuzzRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeBuzzRepository();
      container = ProviderContainer(
        overrides: [
          buzzRepositoryProvider.overrideWithValue(repository),
          callRingtoneProvider.overrideWithValue(_FakeRingtone()),
          activeCallProvider.overrideWith(
            (ref) => ActiveCallNotifier(
              ref,
              ringTimeout: const Duration(milliseconds: 250),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    Map<String, dynamic> incomingEvent({
      String buzzId = 'in-buzz-1',
      String type = 'incoming_call',
    }) {
      return <String, dynamic>{
        'type': type,
        'buzzId': buzzId,
        'remoteUserId': 'user-2',
        'remoteUserName': 'Bob',
        'channelId': 'dm-1',
        'remoteAvatarUrl': 'https://example.com/bob.png',
      };
    }

    test(
      'an idle client flips to incoming when a call signal arrives',
      () async {
        final notifier = container.read(activeCallProvider);
        expect(notifier.state.status, CallStatus.none);

        repository.emitCallEvent(incomingEvent());
        await Future<void>.delayed(Duration.zero);

        expect(notifier.state.status, CallStatus.incoming);
        expect(notifier.state.buzzId, 'in-buzz-1');
        expect(notifier.state.remoteUserId, 'user-2');
        expect(notifier.state.remoteUserName, 'Bob');
        expect(notifier.state.channelId, 'dm-1');
        expect(notifier.state.remoteAvatarUrl, 'https://example.com/bob.png');
      },
    );

    test('keeps the modal reachable after an outgoing call ends', () async {
      final notifier = container.read(activeCallProvider);
      await notifier.initiateCall(
        remoteUserId: 'user-3',
        remoteUserName: 'Cara',
        channelId: 'dm-2',
      );
      expect(notifier.state.status, CallStatus.calling);

      // Caller gives up.
      notifier.endCall();
      expect(notifier.state.status, CallStatus.none);

      repository.emitCallEvent(incomingEvent());
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.status, CallStatus.incoming);
    });

    test('declines an incoming call when already busy', () async {
      final notifier = container.read(activeCallProvider);
      await notifier.initiateCall(
        remoteUserId: 'user-3',
        remoteUserName: 'Cara',
        channelId: 'dm-2',
      );

      repository.emitCallEvent(incomingEvent());
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.status, CallStatus.calling);
      expect(repository.invitationResponses, [('in-buzz-1', false)]);
    });

    test('accepting an incoming call goes active with a token', () async {
      final notifier = container.read(activeCallProvider);
      repository.emitCallEvent(incomingEvent());
      await Future<void>.delayed(Duration.zero);

      await notifier.acceptCall();

      expect(notifier.state.status, CallStatus.active);
      expect(repository.invitationResponses, [('in-buzz-1', true)]);
    });

    test('stops ringing when the incoming call times out unanswered', () async {
      final notifier = container.read(activeCallProvider);
      repository.emitCallEvent(incomingEvent());
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.status, CallStatus.incoming);

      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(notifier.state.status, CallStatus.none);
      expect(repository.invitationResponses, [('in-buzz-1', false)]);
    });

    test('ignores malformed incoming events instead of half-ringing', () async {
      final notifier = container.read(activeCallProvider);

      repository.emitCallEvent(<String, dynamic>{
        'type': 'incoming_call',
        'buzzId': 'in-buzz-1',
        'remoteUserId': 'user-2',
        // Missing remoteUserName and channelId.
      });
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.status, CallStatus.none);
    });
  });
}
