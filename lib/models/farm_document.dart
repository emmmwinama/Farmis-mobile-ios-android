const documentTypes = [
  'receipt',
  'field_photo',
  'vet_record',
  'buyer_contract',
  'loan_document',
  'insurance_evidence',
  'certificate',
  'other',
];

String documentTypeLabel(String type) {
  switch (type) {
    case 'receipt':
      return 'Receipt';
    case 'field_photo':
      return 'Field photo';
    case 'vet_record':
      return 'Vet record';
    case 'buyer_contract':
      return 'Buyer contract';
    case 'loan_document':
      return 'Loan document';
    case 'insurance_evidence':
      return 'Insurance evidence';
    case 'certificate':
      return 'Certificate';
    default:
      return 'Other';
  }
}

class FarmDocument {
  final String id;
  final String name;
  final String type;
  final String url;
  final int? size;
  final String? linkedTo;
  final String? linkedType;
  final String? notes;
  final DateTime uploadedAt;

  const FarmDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.size,
    this.linkedTo,
    this.linkedType,
    this.notes,
    required this.uploadedAt,
  });

  bool get isImage => url.startsWith('data:image/') ||
      RegExp(r'\.(jpe?g|png|webp)$', caseSensitive: false).hasMatch(url);

  factory FarmDocument.fromJson(Map<String, dynamic> json) => FarmDocument(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Document',
        type: json['type'] as String? ?? 'other',
        url: json['url'] as String? ?? '',
        size: (json['size'] as num?)?.toInt(),
        linkedTo: json['linkedTo'] as String?,
        linkedType: json['linkedType'] as String?,
        notes: json['notes'] as String?,
        uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
