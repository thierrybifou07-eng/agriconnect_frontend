enum OrderStatus {
  quoted,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  completed,
  cancelled;

  static OrderStatus fromApi(Object? value) => switch (value) {
    'QUOTED' => quoted,
    'CONFIRMED' => confirmed,
    'PREPARING' => preparing,
    'READY_FOR_PICKUP' => readyForPickup,
    'OUT_FOR_DELIVERY' => outForDelivery,
    'COMPLETED' => completed,
    'CANCELLED' => cancelled,
    _ => throw FormatException('Unknown order status: $value'),
  };

  String get apiValue => switch (this) {
    quoted => 'QUOTED',
    confirmed => 'CONFIRMED',
    preparing => 'PREPARING',
    readyForPickup => 'READY_FOR_PICKUP',
    outForDelivery => 'OUT_FOR_DELIVERY',
    completed => 'COMPLETED',
    cancelled => 'CANCELLED',
  };

  bool get isTerminal => this == completed || this == cancelled;
  bool get canCancel =>
      this == quoted || this == confirmed || this == preparing;
}
