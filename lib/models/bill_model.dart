// lib/models/bill_model.dart

class BillModel {
  final String id;
  final String name; 
  final String amount; 
  final String category;
  final String dueDate; // Format: dd/MM/yyyy HH:mm
  final String status;  // Default: Unpaid Bill
  final String? notes; // Catatan opsional

  BillModel({
    required this.name,
    required this.amount,
    required this.category,
    required this.dueDate,
    this.status = 'Unpaid Bill',
    this.notes,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(); 

  // Metode untuk mengonversi BillModel menjadi Map (untuk Provider atau penyimpanan)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'dueDate': dueDate,
      'status': status,
      'notes': notes,
    };
  }

  // Metode untuk membuat BillModel dari Map (untuk pemuatan dari penyimpanan)
  static BillModel fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as String,
      category: map['category'] as String,
      dueDate: map['dueDate'] as String,
      status: map['status'] as String? ?? 'Unpaid Bill',
      notes: map['notes'] as String?,
    );
  }
}