enum AppNotificationKind {
  message,
  deliveryAvailable,
  deliveryStatus,
  expiring,
  aiSuggestion,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.route,
    this.args,
  });

  final String id;
  final AppNotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? route;
  final Map<String, Object?>? args;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    createdAt: createdAt,
    read: read ?? this.read,
    route: route,
    args: args,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
    'route': route,
    'args': args,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind'];
    final kind = AppNotificationKind.values.firstWhere(
      (value) => value.name == kindName,
      orElse: () => throw const FormatException('Invalid notification kind'),
    );
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (json['id'] is! String ||
        json['title'] is! String ||
        json['body'] is! String ||
        createdAt == null ||
        json['read'] is! bool) {
      throw const FormatException('Invalid notification');
    }
    final rawArgs = json['args'];
    return AppNotification(
      id: json['id'] as String,
      kind: kind,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: createdAt.toUtc(),
      read: json['read'] as bool,
      route: json['route'] as String?,
      args: rawArgs is Map ? Map<String, Object?>.from(rawArgs) : null,
    );
  }
}
