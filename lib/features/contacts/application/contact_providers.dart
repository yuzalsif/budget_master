import 'package:budget_master/domain/models/contact.dart';
import 'package:budget_master/features/contacts/application/contact_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactsProvider = StateProvider<List<Contact>>((ref) {
  return ref.read(contactServiceProvider).getAllContacts();
});
