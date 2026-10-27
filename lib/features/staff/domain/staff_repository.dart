import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';

abstract interface class StaffRepository {
  Future<Paginated<StaffConversation>> conversations({
    int page = 1,
    int limit = 20,
    String? status,
    bool? unassigned,
    bool? mine,
    bool? escalated,
  });
  Future<StaffConversation> conversation(int id);
  Future<Paginated<StaffMessage>> messages(int id, int page, int limit);
  Future<StaffMessage> sendMessage(int id, String content, bool isInternal);
  Future<void> assign(int id, {int? agentId});
  Future<void> escalate(int id, String reason);
  Future<void> closeConversation(int id);
  Future<Paginated<StaffLot>> lots({
    int page = 1,
    int limit = 20,
    String? status,
    int? supplierId,
    int? productId,
  });
  Future<StaffLot> lot(int id);
  Future<void> validateLot(int id);
  Future<void> rejectLot(int id, String reason);
  Future<void> returnLot(int id, String reason);
  Future<void> qualityCheck(int id, String grade, String? notes);
  Future<List<Map<String, Object?>>> qualityChecks(int id);
  Future<Paginated<Map<String, Object?>>> stockMovements(
    int lotId, {
    int page = 1,
    int limit = 20,
  });
  Future<Paginated<StaffListing>> listings({
    int page = 1,
    int limit = 20,
    String? status,
    int? productId,
    int? supplierId,
  });
  Future<StaffListing> listing(int id);
  Future<StaffListing> createListing(
    int lotId,
    String title,
    String? description,
    List<String> imagePaths,
  );
  Future<StaffListing> updateListing(int id, Map<String, Object?> fields);
  Future<void> publishListing(int id);
  Future<void> unpublishListing(int id);
}
