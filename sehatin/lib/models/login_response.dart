class LoginResponse {
  final String token;
  final int id;
  final String username;
  final String email;

  LoginResponse({
    required this.token,
    required this.id,
    required this.username,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      id: json['user']['id'],
      username: json['user']['username'],
      email: json['user']['email'],
    );
  }
}