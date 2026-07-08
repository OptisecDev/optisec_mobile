/// Metadata for a single Password Vault entry. Deliberately excludes the
/// password itself — the native store keeps it in a separately-encrypted
/// blob, and [PasswordVaultService.getEntryPassword] fetches it on demand.
/// Never add a password field here: the whole point is that the decrypted
/// password is never held in the in-memory entry list.
class VaultEntryModel {
  final String id;
  final String title;
  final String username;
  final String url;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultEntryModel({
    required this.id,
    required this.title,
    required this.username,
    required this.url,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VaultEntryModel.fromJson(Map<String, dynamic> json) {
    return VaultEntryModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      username: json['username'] as String? ?? '',
      url: json['url'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num?)?.toInt() ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  VaultEntryModel copyWith({
    String? title,
    String? username,
    String? url,
    String? notes,
  }) {
    return VaultEntryModel(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
