class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.firstName,
    required this.lastName,
    required this.groups,
    required this.level,
    required this.phoneNo,
  });

  late String image;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String firstName;
  late List groups;
  late String level;
  late String lastName;
  late String phoneNo;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    groups = json['groups'] ?? [];
    firstName = json['firstName'] ?? '';
    lastName = json['lastName'] ?? '';
    phoneNo = json['phone'] ?? '';
    level = json['level'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['level'] = level;
    data['phone'] = phoneNo;
    data['groups'] = groups;

    return data;
  }
}
