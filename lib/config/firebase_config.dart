import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseConfig {
  // Firestore references
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  // Collection references
  static CollectionReference get usersCollection => firestore.collection('users');
  static CollectionReference get servicesCollection => firestore.collection('services');
}
