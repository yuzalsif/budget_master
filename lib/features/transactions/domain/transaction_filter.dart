
enum DateFilter { allTime, thisMonth, thisYear, custom }

class TransactionFilter {
  final int? accountId;
  final int? categoryId;
  final DateFilter dateFilter;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.dateFilter = DateFilter.allTime,
  });

  factory TransactionFilter.initial() => const TransactionFilter();

  TransactionFilter copyWith({
    int? accountId,
    int? categoryId,
    DateFilter? dateFilter,
  }) {
    return TransactionFilter(
      accountId: accountId,
      categoryId: categoryId,
      dateFilter: dateFilter ?? this.dateFilter,
    );
  }
}
