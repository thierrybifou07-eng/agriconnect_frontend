import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/staff/data/staff_api.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  const StaffRepositoryImpl(this._api);
  final StaffApi _api;

  @override
  Future<Paginated<StaffConversation>> conversations({
    int page = 1,
    int limit = 20,
    String? status,
    bool? unassigned,
    bool? mine,
    bool? escalated,
  }) => _parse(
    () => _api.conversations(
      page: page,
      limit: limit,
      status: status,
      unassigned: unassigned,
      mine: mine,
      escalated: escalated,
    ),
  );
  @override
  Future<StaffConversation> conversation(int id) =>
      _parse(() => _api.conversation(id));
  @override
  Future<Paginated<StaffMessage>> messages(int id, int page, int limit) =>
      _parse(() => _api.messages(id, page, limit));
  @override
  Future<StaffMessage> sendMessage(int id, String content, bool internal) =>
      _parse(() => _api.sendMessage(id, content, internal));
  @override
  Future<void> assign(int id, {int? agentId}) =>
      _parse(() => _api.assign(id, agentId: agentId));
  @override
  Future<void> escalate(int id, String reason) =>
      _parse(() => _api.escalate(id, reason));
  @override
  Future<void> closeConversation(int id) =>
      _parse(() => _api.closeConversation(id));
  @override
  Future<Paginated<StaffLot>> lots({
    int page = 1,
    int limit = 20,
    String? status,
    int? supplierId,
    int? productId,
  }) => _parse(
    () => _api.lots(
      page: page,
      limit: limit,
      status: status,
      supplierId: supplierId,
      productId: productId,
    ),
  );
  @override
  Future<StaffLot> lot(int id) => _parse(() => _api.lot(id));
  @override
  Future<void> validateLot(int id) => _parse(() => _api.validateLot(id));
  @override
  Future<void> rejectLot(int id, String reason) =>
      _parse(() => _api.rejectLot(id, reason));
  @override
  Future<void> returnLot(int id, String reason) =>
      _parse(() => _api.returnLot(id, reason));
  @override
  Future<void> qualityCheck(int id, String grade, String? notes) =>
      _parse(() => _api.qualityCheck(id, grade, notes));
  @override
  Future<List<Map<String, Object?>>> qualityChecks(int id) =>
      _parse(() => _api.qualityChecks(id));
  @override
  Future<Paginated<Map<String, Object?>>> stockMovements(
    int lotId, {
    int page = 1,
    int limit = 20,
  }) => _parse(() => _api.stockMovements(lotId, page: page, limit: limit));
  @override
  Future<Paginated<StaffListing>> listings({
    int page = 1,
    int limit = 20,
    String? status,
    int? productId,
    int? supplierId,
  }) => _parse(
    () => _api.listings(
      page: page,
      limit: limit,
      status: status,
      productId: productId,
      supplierId: supplierId,
    ),
  );
  @override
  Future<StaffListing> listing(int id) => _parse(() => _api.listing(id));
  @override
  Future<StaffListing> createListing(
    int id,
    String title,
    String? description,
    List<String> paths,
  ) => _parse(() => _api.createListing(id, title, description, paths));
  @override
  Future<StaffListing> updateListing(int id, Map<String, Object?> fields) =>
      _parse(() => _api.updateListing(id, fields));
  @override
  Future<void> publishListing(int id) => _parse(() => _api.publishListing(id));
  @override
  Future<void> unpublishListing(int id) =>
      _parse(() => _api.unpublishListing(id));

  Future<T> _parse<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (error) {
      throw ApiFailure(
        status: null,
        code: null,
        message: error.message,
        fieldErrors: const {},
        kind: ApiFailureKind.server,
      );
    }
  }
}
