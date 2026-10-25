import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/paginated_controller.dart';
import 'package:agri_connect/core/ui/ui_state.dart';

void main() {
  test('loads and appends pages while preventing duplicate requests', () async {
    final controller = _TestPaginatedController();

    final firstRequest = controller.loadFirst();
    final duplicateFirstRequest = controller.loadFirst();
    expect(controller.fetchCount, 1);
    expect(controller.state.value, isA<Loading<List<int>>>());
    controller.pending[0].complete(_page([1, 2], 1, 4));
    await Future.wait([firstRequest, duplicateFirstRequest]);

    final moreRequest = controller.loadMore();
    final duplicateMoreRequest = controller.loadMore();
    expect(controller.fetchCount, 2);
    controller.pending[1].complete(_page([3, 4], 2, 4));
    await Future.wait([moreRequest, duplicateMoreRequest]);

    expect((controller.state.value as Success<List<int>>).data, [1, 2, 3, 4]);
    expect(controller.hasMore, isFalse);
  });
}

Paginated<int> _page(List<int> items, int page, int total) =>
    Paginated<int>(items: items, page: page, limit: 2, total: total);

class _TestPaginatedController extends PaginatedController<int> {
  final List<Completer<Paginated<int>>> pending = [];
  int fetchCount = 0;

  @override
  Future<Paginated<int>> fetch(int page, int limit) {
    fetchCount++;
    final request = Completer<Paginated<int>>();
    pending.add(request);
    return request.future;
  }
}
