// lib/features/transactions/domain/transaction_filter.dart

// An enum for our predefined date ranges for simplicity and type safety.
enum DateFilter { allTime, thisMonth, thisYear, custom }

class TransactionFilter {
  final int? accountId;
  final int? categoryId;
  final DateFilter dateFilter;
  // For custom date ranges in the future
  // final DateTimeRange? customDateRange;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.dateFilter = DateFilter.allTime,
  });

  // A factory for the default "no filters applied" state.
  factory TransactionFilter.initial() => const TransactionFilter();

  // A method to create a copy of the filter with updated values.
  // This is great for immutable state management with Riverpod.
  TransactionFilter copyWith({
    int? accountId,
    int? categoryId,
    DateFilter? dateFilter,
  }) {
    return TransactionFilter(
      // If a new value is provided, use it. Otherwise, keep the old one.
      // Note: We need a way to clear filters. A trick is needed.
      // Let's adjust the logic slightly to handle clearing.
      accountId: accountId,
      categoryId: categoryId,
      dateFilter: dateFilter ?? this.dateFilter,
    );
  }
}
