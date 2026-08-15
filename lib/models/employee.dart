class EmployeeModel {
  final String id;
  final String name;
  final String role;
  final double payRate;
  final String payRateUnit;
  final String? phone;
  final bool isActive;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.payRate,
    required this.payRateUnit,
    this.phone,
    required this.isActive,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        payRate: (json['payRate'] as num).toDouble(),
        payRateUnit: json['payRateUnit'] as String,
        phone: json['phone'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );
}
