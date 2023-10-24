class PatientModel {
  PatientModel({
    required this.phoneNumber,
    required this.name,
    required this.id,
    required this.lastActive,
    required this.isOnline,
    required this.email,
    required this.pushToken,
  });
  late final String phoneNumber;
  late final String name;
  late final String id;
  late final String lastActive;
  late final bool isOnline;
  late final String email;
  late final String pushToken;

  PatientModel.fromJson(Map<String, dynamic> json){
    phoneNumber = json['phoneNumber'];
    name = json['name'];
    id = json['id'];
    lastActive = json['last_active'];
    isOnline = json['is_online'];
    email = json['email'];
    email = json['email'];
    pushToken = json['push_token'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['phoneNumber'] = phoneNumber;
    _data['name'] = name;
    _data['id'] = id;
    _data['last_active'] = lastActive;
    _data['is_online'] = isOnline;
    _data['email'] = email;
    _data['push_token'] = pushToken;
    return _data;
  }
}