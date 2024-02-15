class UserModel{
  final String uid;
  final String name;
  final String email;
  final String image;

  const UserModel(
    {required this.uid,
    required this.name,
    required this.email,
    required this.image,
  });

  factory UserModel.fromJson(Map<String,dynamic> json) =>
     UserModel(
      uid: json['uid'], 
      name: json['username'],
      email: json['email'],
      image: json['imageUrl'],
    );
}