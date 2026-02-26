class UserModel {
  String id;
  String email;
  String phone;
  String userName;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.userName,
  });

  UserModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'],
        email: json['email'],
        phone: json['phone'],
        userName: json['userName'],
      );

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'phone': phone, 'userName': userName};
  }
}
