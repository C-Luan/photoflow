class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String photoUrl;
  final bool isEmailVerified;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.isEmailVerified,
    this.phoneNumber,
  });

  factory UserModel.fromFirebaseUserMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoURL'],
      isEmailVerified: map['isEmailVerified'],
    );
  }
}
