class DoctorModel {
  DoctorModel({
    required this.address,
    required this.profImage,
    required this.city,
    required this.medicalLic,
    required this.createdAt,
    required this.description,
    required this.availability,
    required this.experience,
    required this.phoneno,
    required this.speciality,
    required this.qualification,
    required this.password,
    required this.name,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.hospital,
    required this.email,
    required this.pushToken,
  });
  late final String address;
  late final String profImage;
  late final String city;
  late final String medicalLic;
  late final String createdAt;
  late final String description;
  late final Availability availability;
  late final String experience;
  late final String phoneno;
  late final List<String> speciality;
  late final String qualification;
  late final String password;
  late final String name;
  late final bool isOnline;
  late final String id;
  late final String lastActive;
  late final String hospital;
  late final String email;
  late final String pushToken;

  DoctorModel.fromJson(Map<String, dynamic> json){
    address = json['address'];
    profImage = json['prof_image'];
    city = json['city'];
    medicalLic = json['medical_lic'];
    createdAt = json['created_at'];
    description = json['description'];
    availability = Availability.fromJson(json['availability']);
    experience = json['experience'];
    phoneno = json['phoneno'];
    speciality = List.castFrom<dynamic, String>(json['speciality']);
    qualification = json['qualification'];
    password = json['password'];
    name = json['name'];
    isOnline = json['is_online'];
    id = json['id'];
    lastActive = json['last_active'];
    hospital = json['hospital'];
    email = json['email'];
    pushToken = json['push_token'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['address'] = address;
    _data['prof_image'] = profImage;
    _data['city'] = city;
    _data['medical_lic'] = medicalLic;
    _data['created_at'] = createdAt;
    _data['description'] = description;
    _data['availability'] = availability.toJson();
    _data['experience'] = experience;
    _data['phoneno'] = phoneno;
    _data['speciality'] = speciality;
    _data['qualification'] = qualification;
    _data['password'] = password;
    _data['name'] = name;
    _data['is_online'] = isOnline;
    _data['id'] = id;
    _data['last_active'] = lastActive;
    _data['hospital'] = hospital;
    _data['email'] = email;
    _data['push_token'] = pushToken;
    return _data;
  }
}

class Availability {
  Availability({
    required this.weekday,
    required this.time,
  });
  late final List<int> weekday;
  late final List<String> time;

  Availability.fromJson(Map<String, dynamic> json){
    weekday = List.castFrom<dynamic, int>(json['weekday']);
    time = List.castFrom<dynamic, String>(json['time']);
  }
  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['weekday'] = weekday;
    _data['time'] = time;
    return _data;
  }
}