import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore'a veri kaydetme fonksiyonu
  Future<void> saveData(String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
      print("Veri başarılı bir şekilde kaydedildi!");
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  Future<List<Map<String, dynamic>>?> fetchAllDocuments(String collectionName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionName).get();
      List<Map<String, dynamic>> tasks = [];
      // Belgeleri döngü ile işleme
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        print("Belge ID: ${doc.id}, Veri: ${doc.data()}");
        tasks.add(doc.data() as Map<String, dynamic>);
      }
      return tasks;
    } catch (e) {
      print("Hata oluştu: $e");
    }
    return null;
  }

  Future<String?> getUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Şu anki oturumdaki kullanıcıyı al
      if (user != null) {
        return user.email; // Kullanıcının e-posta adresini döndür
      } else {
        print("Kullanıcı oturum açmamış.");
        return null;
      }
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }
}