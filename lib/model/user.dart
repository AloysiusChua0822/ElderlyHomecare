class UserModel{

  final String email;
  final String image;
<<<<<<< HEAD
  final String userType;
  final String username;
=======

>>>>>>> d83ab7d50c7be6d099b1d2e48956f777aa0ba202
  const UserModel(
    {
    required this.email,
    required this.image,
<<<<<<< HEAD
    required this.userType,
    required this.username,
=======
>>>>>>> d83ab7d50c7be6d099b1d2e48956f777aa0ba202
  });

  factory UserModel.fromJson(Map<String,dynamic> json) =>
     UserModel(
<<<<<<< HEAD
      email: json['email'],
      image: json['image_url'],
      userType: json['userType'],
      username: json['username'],
=======
      uid: json['uid'], 
      name: json['username'],
      email: json['email'],
      image: json['imageUrl'],
>>>>>>> d83ab7d50c7be6d099b1d2e48956f777aa0ba202
    );
}