import '../../../../../helpers/helpers.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockDmRepository extends Mock implements DmRepository {}

void main() {
  group('DmListNotifier', () {
    late MockDmRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = MockDmRepository();
      container = ProviderContainer(
        overrides: [
          currentOrgIdProvider.overrideWithValue('org-1'),
          dmRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() => container.dispose());

    void stubConversations(List<DmConversation> conversations) {
      when(
        () => repository.getConversations(
          orgId: any(named: 'orgId'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => conversations);
    }

    test('returns an empty list when the organisation has no DMs', () async {
      stubConversations(const []);

      final conversations = await container.read(dmListProvider.future);

      expect(conversations, isEmpty);
      expect(container.read(dmListProvider.notifier).hasMore, isFalse);
    });

    test('stays empty after a refresh that returns no DMs', () async {
      stubConversations(const []);
      await container.read(dmListProvider.future);

      await container.read(dmListProvider.notifier).refresh();

      expect(container.read(dmListProvider).value, isEmpty);
    });

    test('returns only the conversations the API sent', () async {
      final real = DmConversation(
        channelId: 'channel-1',
        username: 'Ada',
        participantId: 'user-1',
        previewMessage: 'Hi',
        unreadCount: 0,
      );
      stubConversations([real]);

      final conversations = await container.read(dmListProvider.future);

      expect(conversations, [real]);
    });
  });
}
