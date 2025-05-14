class DocumentItem {
  final String id;
  final String name;
  final bool signRequired;
  final String description;
  bool isSigned;
  List<DocumentsChainMetadataItem>?
      chainMetadata; // Добавляем поле для цепочки подписания

  DocumentItem({
    required this.id,
    required this.name,
    required this.signRequired,
    required this.description,
    this.isSigned = false,
    this.chainMetadata,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      signRequired: json['sign_required'] as bool? ?? false,
      isSigned: json['signed'] as bool? ?? false,
      chainMetadata: json['chain_metadata'] != null
          ? (json['chain_metadata'] as List)
              .map((item) => DocumentsChainMetadataItem.fromJson(item))
              .toList()
          : null, // Парсим цепочку подписания, если она есть
    );
  }

  DocumentItem copyWith({
    bool? isSigned,
    List<DocumentsChainMetadataItem>? chainMetadata,
  }) {
    return DocumentItem(
      id: id,
      name: name,
      signRequired: signRequired,
      description: description,
      isSigned: isSigned ?? this.isSigned,
      chainMetadata: chainMetadata ?? this.chainMetadata,
    );
  }
}

class DocumentsChainMetadataItem {
  final String employeeId;
  final bool requiresSignature;
  int status;

  DocumentsChainMetadataItem({
    required this.employeeId,
    required this.requiresSignature,
    required this.status,
  });

  factory DocumentsChainMetadataItem.fromJson(Map<String, dynamic> json) {
    return DocumentsChainMetadataItem(
      employeeId: json['employee_id'] as String,
      requiresSignature: json['requires_signature'] as bool,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'requires_signature': requiresSignature,
      'status': status,
    };
  }
}

class DocumentsChainUpdateItem {
  final String employeeId;
  final bool requiresSignature;
  int approvalStatus;
  DocumentsChainUpdateItem({
    required this.employeeId,
    required this.requiresSignature,
    required this.approvalStatus,
  });

  factory DocumentsChainUpdateItem.fromJson(Map<String, dynamic> json) {
    return DocumentsChainUpdateItem(
      employeeId: json['employee_id'] as String,
      requiresSignature: json['requires_signature'] as bool,
      approvalStatus: json['approval_status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'requires_signature': requiresSignature,
      'approval_status': approvalStatus,
    };
  }
}

class SignItem {
  final ListEmployee employee;
  final bool signed;
  final String documentId;

  SignItem({
    required this.employee,
    required this.signed,
    required this.documentId,
  });

  factory SignItem.fromJson(Map<String, dynamic> json) {
    return SignItem(
      employee: ListEmployee.fromJson(json['employee'] as Map<String, dynamic>),
      signed: json['signed'] as bool,
      documentId: json['document_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee.toJson(),
      'signed': signed,
      'document_id': documentId,
    };
  }
}

class ListEmployee {
  final String id;
  final String name;
  final String surname;
  final String patronymic;
  final String photoLink;

  ListEmployee({
    required this.id,
    required this.name,
    required this.surname,
    required this.patronymic,
    required this.photoLink,
  });

  factory ListEmployee.fromJson(Map<String, dynamic> json) {
    return ListEmployee(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      patronymic: json['patronymic'] as String? ?? '',
      photoLink: json['photo_link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'patronymic': patronymic,
      'photo_link': photoLink,
    };
  }
}
