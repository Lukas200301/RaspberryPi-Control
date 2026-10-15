/// A saved device (Raspberry Pi or any Linux box reachable over SSH)
class SSHConnection {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;

  /// OpenSSH/PEM private key; used instead of (or before) the password
  final String privateKey;
  final String passphrase;

  final bool isFavorite;
  final DateTime? lastConnected;
  final String? agentVersion;

  /// Free-form group such as "Home" or "Office"
  final String group;

  SSHConnection({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.password = '',
    this.privateKey = '',
    this.passphrase = '',
    this.isFavorite = false,
    this.lastConnected,
    this.agentVersion,
    this.group = '',
  });

  bool get usesKey => privateKey.trim().isNotEmpty;

  String get address => '$username@$host${port == 22 ? '' : ':$port'}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
    'privateKey': privateKey,
    'passphrase': passphrase,
    'isFavorite': isFavorite,
    'lastConnected': lastConnected?.toIso8601String(),
    'agentVersion': agentVersion,
    'group': group,
  };

  factory SSHConnection.fromJson(Map<String, dynamic> json) => SSHConnection(
    id: json['id'] as String,
    name: json['name'] as String,
    host: json['host'] as String,
    port: json['port'] as int? ?? 22,
    username: json['username'] as String,
    password: json['password'] as String? ?? '',
    privateKey: json['privateKey'] as String? ?? '',
    passphrase: json['passphrase'] as String? ?? '',
    isFavorite: json['isFavorite'] as bool? ?? false,
    lastConnected: json['lastConnected'] != null
        ? DateTime.tryParse(json['lastConnected'] as String)
        : null,
    agentVersion: json['agentVersion'] as String?,
    group: json['group'] as String? ?? '',
  );

  SSHConnection copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    String? password,
    String? privateKey,
    String? passphrase,
    bool? isFavorite,
    DateTime? lastConnected,
    String? agentVersion,
    String? group,
    bool clearAgentVersion = false,
  }) {
    return SSHConnection(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      privateKey: privateKey ?? this.privateKey,
      passphrase: passphrase ?? this.passphrase,
      isFavorite: isFavorite ?? this.isFavorite,
      lastConnected: lastConnected ?? this.lastConnected,
      agentVersion: clearAgentVersion ? null : (agentVersion ?? this.agentVersion),
      group: group ?? this.group,
    );
  }
}
