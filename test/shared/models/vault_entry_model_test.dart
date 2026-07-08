import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/shared/models/vault_entry_model.dart';

Map<String, dynamic> _fullJson({String password = 'super-secret-pw'}) => {
      'id': 'entry-1',
      'title': 'Bank of Example',
      'username': 'alice',
      'url': 'https://bank.example',
      'notes': 'primary checking',
      // A password key should never legitimately be sent to fromJson (the
      // native side keeps it out of listEntries payloads), but if it ever
      // leaked through, the model must not expose it anywhere.
      'password': password,
      'createdAt': 1000,
      'updatedAt': 2000,
    };

void main() {
  group('VaultEntryModel.fromJson', () {
    test('parses all fields from a full json map', () {
      final entry = VaultEntryModel.fromJson(_fullJson());

      expect(entry.id, 'entry-1');
      expect(entry.title, 'Bank of Example');
      expect(entry.username, 'alice');
      expect(entry.url, 'https://bank.example');
      expect(entry.notes, 'primary checking');
      expect(entry.createdAt, DateTime.fromMillisecondsSinceEpoch(1000));
      expect(entry.updatedAt, DateTime.fromMillisecondsSinceEpoch(2000));
    });

    test('defaults missing optional string fields to empty string', () {
      final entry = VaultEntryModel.fromJson({'id': 'entry-2'});

      expect(entry.id, 'entry-2');
      expect(entry.title, '');
      expect(entry.username, '');
      expect(entry.url, '');
      expect(entry.notes, '');
    });

    test('defaults missing timestamps to epoch 0', () {
      final entry = VaultEntryModel.fromJson({'id': 'entry-3'});

      expect(entry.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
      expect(entry.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('tolerates null values for optional fields', () {
      final entry = VaultEntryModel.fromJson({
        'id': 'entry-4',
        'title': null,
        'username': null,
        'url': null,
        'notes': null,
        'createdAt': null,
        'updatedAt': null,
      });

      expect(entry.title, '');
      expect(entry.username, '');
      expect(entry.url, '');
      expect(entry.notes, '');
      expect(entry.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
      expect(entry.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test(
      'never exposes a password value even if the incoming json carries one',
      () {
        final entry = VaultEntryModel.fromJson(_fullJson());

        // VaultEntryModel has no `password` field or getter at all — that is
        // a compile-time guarantee, not just a runtime one. The lines below
        // would fail to compile if a `password` getter ever got added:
        //
        //   entry.password;
        //
        // As a runtime safety net, confirm none of the values reachable
        // through the model's public surface ever equal the injected
        // password, and that it doesn't leak into toString().
        final exposedValues = <Object?>[
          entry.id,
          entry.title,
          entry.username,
          entry.url,
          entry.notes,
          entry.createdAt,
          entry.updatedAt,
        ];

        expect(exposedValues, isNot(contains('super-secret-pw')));
        expect(entry.toString(), isNot(contains('super-secret-pw')));
      },
    );
  });

  group('VaultEntryModel.copyWith', () {
    test('overrides only the fields that are provided', () {
      final original = VaultEntryModel.fromJson(_fullJson());
      final updated = original.copyWith(title: 'New Title');

      expect(updated.title, 'New Title');
      expect(updated.username, original.username);
      expect(updated.url, original.url);
      expect(updated.notes, original.notes);
    });

    test('preserves id, createdAt and updatedAt unconditionally', () {
      final original = VaultEntryModel.fromJson(_fullJson());
      final updated = original.copyWith(
        title: 'New Title',
        username: 'new-user',
        url: 'https://new.example',
        notes: 'new notes',
      );

      expect(updated.id, original.id);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, original.updatedAt);
    });

    test('with no arguments returns field-equivalent copy', () {
      final original = VaultEntryModel.fromJson(_fullJson());
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.username, original.username);
      expect(copy.url, original.url);
      expect(copy.notes, original.notes);
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
    });

    test('copyWith never re-introduces a password field', () {
      final original = VaultEntryModel.fromJson(_fullJson());
      final updated = original.copyWith(title: 'New Title');

      expect(updated.toString(), isNot(contains('super-secret-pw')));
    });
  });

  group('VaultEntryModel equality', () {
    // VaultEntryModel does not override `==`/`hashCode`, so equality falls
    // back to Object identity. These tests pin down that actual behavior
    // (rather than an assumed value-equality) so a future accidental change
    // to identity semantics is caught, and document field-level sameness as
    // the practical equivalent used elsewhere in the codebase.
    test('two instances built from the same json are not identical/==', () {
      final a = VaultEntryModel.fromJson(_fullJson());
      final b = VaultEntryModel.fromJson(_fullJson());

      expect(identical(a, b), isFalse);
      expect(a == b, isFalse);
    });

    test('a variable holding the same instance is equal to itself', () {
      final a = VaultEntryModel.fromJson(_fullJson());
      final sameRef = a;

      expect(a == sameRef, isTrue);
    });

    test('instances from the same json are field-by-field equivalent', () {
      final a = VaultEntryModel.fromJson(_fullJson());
      final b = VaultEntryModel.fromJson(_fullJson());

      expect(a.id, b.id);
      expect(a.title, b.title);
      expect(a.username, b.username);
      expect(a.url, b.url);
      expect(a.notes, b.notes);
      expect(a.createdAt, b.createdAt);
      expect(a.updatedAt, b.updatedAt);
    });

    test('differing a single field breaks field-by-field equivalence', () {
      final a = VaultEntryModel.fromJson(_fullJson());
      final b = a.copyWith(title: 'Different Title');

      expect(a.title == b.title, isFalse);
    });
  });
}
