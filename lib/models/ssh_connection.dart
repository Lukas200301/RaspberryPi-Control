class SSHConnection {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  final bool isFavorite;
  final DateTime? lastConnected;

  SSHConnection({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    required this.password,
    this.isFavorite = false,
    this.lastConnected,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'username': username,
        'password': password,
        'isFavorite': isFavorite,
        'lastConnected': lastConnected?.toIso8601String(),
      };

  factory SSHConnection.fromJson(Map<String, dynamic> json) => SSHConnection(
        id: json['id'] as String,
        name: json['name'] as String,
        host: json['host'] as String,
        port: json['port'] as int? ?? 22,
        username: json['username'] as String,
        password: json['password'] as String,
        isFavorite: json['isFavorite'] as bool? ?? false,
        lastConnected: json['lastConnected'] != null
            ? DateTime.parse(json['lastConnected'] as String)
            : null,
      );

  SSHConnection copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    String? password,
    bool? isFavorite,
    DateTime? lastConnected,
  }) {
    return SSHConnection(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      isFavorite: isFavorite ?? this.isFavorite,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }
}
