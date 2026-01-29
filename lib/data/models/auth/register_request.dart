/// Register Request Model
class RegisterRequest {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String role;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.role = 'user',
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };
  }
}
