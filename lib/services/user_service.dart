import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_ahaar/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create new user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(uid).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Get all users (with optional role filter)
  Stream<List<UserModel>> getUsers({String? role}) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);
      if (role != null) {
        query = query.where('roles', arrayContains: role);
      }
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      print('Error getting users: $e');
      rethrow;
    }
  }
} 