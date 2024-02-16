class UserModel{

  final String email;
  final String image;
  final String userType;
  final String username;

  const UserModel(
    {
    required this.email,
    required this.image,
    required this.userType,
    required this.username,
  });

  factory UserModel.fromJson(Map<String,dynamic> json) =>
     UserModel(
      email: json['email'],
      image: json['image_url'],
      userType: json['userType'],
      username: json['username'],
    );
}