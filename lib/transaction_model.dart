enum TransactionType { pemasukan, pengeluaran }

class Transaction {
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });
}