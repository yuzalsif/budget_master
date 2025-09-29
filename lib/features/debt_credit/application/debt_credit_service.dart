// // lib/features/debt_credit/application/debt_credit_service.dart
// import 'package:budget_master/core/providers/database_provider.dart';
// import 'package:budget_master/domain/models/contact.dart';
// import 'package:budget_master/domain/models/transaction.dart';
// import 'package:budget_master/objectbox.g.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:googleapis/domains/v1.dart';

// final debtCreditServiceProvider = Provider<DebtCreditService>((ref) {
//   final store = ref.watch(objectboxProvider).value!;
//   return DebtCreditService(store);
// });

// // This provider will give us a map of each AppContact and their net balance.
// final AppContactBalancesProvider = Provider<Map<AppContact, double>>((ref) {
//   return ref.watch(debtCreditServiceProvider).getAppContactBalances();
// });

// class DebtCreditService {
//   final Store _store;
//   late final Box<Transaction> _transactionBox;

//   DebtCreditService(this._store) {
//     _transactionBox = _store.box<Transaction>();
//   }

//   Map<AppContact, double> getAppContactBalances() {
//     final allTransactions = _transactionBox.getAll();
//     final Map<AppContact, double> balances = {};

//     for (final txn in allTransactions) {
//       // Only consider transactions that are linked to a AppContact
//       if (txn.AppContact.target != null) {
//         final AppContact = txn.AppContact.target!;
//         final amount = txn.amount;

//         // A withdrawal means the AppContact now owes us more (or we owe them less).
//         // A deposit means the AppContact now owes us less (or we owe them more).
//         final value =
//             TransactionType.values[txn.type] == TransactionType.withdrawal
//             ? amount
//             : -amount;

//         // Add the value to the AppContact's running total.
//         balances.update(
//           AppContact,
//           (existing) => existing + value,
//           ifAbsent: () => value,
//         );
//       }
//     }

//     // Remove AppContacts with a zero balance
//     balances.removeWhere((key, value) => value.abs() < 0.01);

//     return balances;
//   }
// }
