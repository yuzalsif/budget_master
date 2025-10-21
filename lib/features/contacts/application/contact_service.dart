import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/domain/models/contact.dart';
import 'package:budget_master/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactServiceProvider = Provider<ContactService>((ref) {
  final store = ref.watch(objectboxProvider).value!;
  return ContactService(store.box<Contact>());
});

class ContactService {
  final Box<Contact> _box;

  ContactService(this._box);

  List<Contact> getAllContacts() {
    return _box.getAll();
  }

  void addContact(Contact contact) {
    _box.put(contact);
  }

  void updateContact(Contact contact) {
    _box.put(contact);
  }

  void deleteContact(int contactId) {
    _box.remove(contactId);
  }
}
