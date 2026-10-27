enum DeliveryStatus {
  pending,
  accepted,
  pickedUp,
  inTransit,
  delivered,
  failed,
  cancelled;

  static DeliveryStatus fromApi(Object? value) => switch (value) {
    'PENDING' => pending,
    'ACCEPTED' => accepted,
    'PICKED_UP' => pickedUp,
    'IN_TRANSIT' => inTransit,
    'DELIVERED' => delivered,
    'FAILED' => failed,
    'CANCELLED' => cancelled,
    _ => throw FormatException('Unknown delivery status: $value'),
  };

  String get apiValue => switch (this) {
    pending => 'PENDING',
    accepted => 'ACCEPTED',
    pickedUp => 'PICKED_UP',
    inTransit => 'IN_TRANSIT',
    delivered => 'DELIVERED',
    failed => 'FAILED',
    cancelled => 'CANCELLED',
  };

  DeliveryStatus? get driverNextStatus => switch (this) {
    accepted => pickedUp,
    pickedUp => inTransit,
    inTransit => delivered,
    pending || delivered || failed || cancelled => null,
  };

  bool get canFail => this == pickedUp || this == inTransit;

  bool get isActive =>
      this == accepted || this == pickedUp || this == inTransit;
}
