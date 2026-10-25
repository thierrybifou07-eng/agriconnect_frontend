import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage {
  PrefsStorage({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  Future<String?> readLanguage() async =>
      (await _preferences).getString('language');

  Future<void> saveLanguage(String language) async =>
      (await _preferences).setString('language', language);

  Future<bool> readOnboardingSeen() async =>
      (await _preferences).getBool('onboarding_seen') ?? false;

  Future<void> saveOnboardingSeen(bool seen) async =>
      (await _preferences).setBool('onboarding_seen', seen);

  Future<String?> readRegistrationRole() async =>
      (await _preferences).getString('registration_role');

  Future<void> saveRegistrationRole(String role) async =>
      (await _preferences).setString('registration_role', role);

  Future<String?> readNotificationCache() async =>
      (await _preferences).getString('notification_cache');

  Future<void> saveNotificationCache(String json) async =>
      (await _preferences).setString('notification_cache', json);

  Future<int?> readLastReadMessage(int conversationId) async =>
      (await _preferences).getInt('last_read_message_$conversationId');

  Future<void> saveLastReadMessage(int conversationId, int messageId) async =>
      (await _preferences).setInt(
        'last_read_message_$conversationId',
        messageId,
      );
}
