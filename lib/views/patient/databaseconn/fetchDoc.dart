import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String name;
  final String qualification;
  final String hospital;
  final String location;
  final String experience;

  Doctor({
    required this.name,
    required this.qualification,
    required this.hospital,
    required this.location,
    required this.experience,
  });
}

Future<Map<String, dynamic>?> fetchDoctorData(String doctorId) async {
  try {
    DocumentSnapshot doctorSnapshot =
    await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();

    if (doctorSnapshot.exists) {
      return doctorSnapshot.data() as Map<String, dynamic>;
    }
  } catch (e) {
    print('Error fetching doctor data: $e');
  }
  return null; // Return null if the doctor data couldn't be fetched
}
