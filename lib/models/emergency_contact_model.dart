class EmergencyContactModel {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContactModel.fromMap(
      Map<String, dynamic> map) {
    return EmergencyContactModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      relationship: map['relationship'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}