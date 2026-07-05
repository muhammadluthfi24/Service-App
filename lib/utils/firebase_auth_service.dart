import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../config/firebase_config.dart';

class FirebaseAuthService {
  static User? _currentUser;
  static final List<User> _registeredUsers = [];

  static User? get currentUser => _currentUser;
  static List<User> get allUsers => _registeredUsers;
  static bool get isLoggedIn => _currentUser != null;
  static bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Login with Firebase Auth
  static Future<bool> login(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await FirebaseConfig.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Check if it's admin
        final isAdmin = email == 'admin@servify.com' && password == 'admin123';
        
        // Try to get user data from Firestore first
        try {
          final userDoc = await FirebaseConfig.usersCollection.doc(user.uid).get();
          final userData = userDoc.data() as Map<String, dynamic>?;
          
          _currentUser = User(
            id: user.uid,
            name: userData?['name'] ?? user.displayName ?? user.email?.split('@')[0] ?? 'User',
            email: user.email ?? '',
            avatar: user.photoURL,
            isAdmin: isAdmin,
            createdAt: DateTime.parse(userData?['createdAt'] ?? DateTime.now().toIso8601String()),
          );
        } catch (e) {
          // Fallback if Firestore fails
          _currentUser = User(
            id: user.uid,
            name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
            email: user.email ?? '',
            avatar: user.photoURL,
            isAdmin: isAdmin,
            createdAt: DateTime.now(),
          );
        }

        // Store user in local list for admin management
        if (!_registeredUsers.any((u) => u.id == _currentUser!.id)) {
          _registeredUsers.add(_currentUser!);
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Register new user with Firebase Auth
  static Future<bool> register(String email, String password, String name) async {
    try {
      firebase_auth.UserCredential userCredential = await FirebaseConfig.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        final newUser = User(
          id: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await FirebaseConfig.usersCollection.doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'isAdmin': false,
        });

        _registeredUsers.add(newUser);
        _currentUser = newUser;

        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    await FirebaseConfig.auth.signOut();
    _currentUser = null;
  }

  // Get all users from Firestore
  static Future<void> fetchUsers() async {
    try {
      final snapshot = await FirebaseConfig.usersCollection.get();
      _registeredUsers.clear();
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          _registeredUsers.add(User(
            id: doc.id,
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
          ));
        }
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Mock user for testing (when Firebase config has issues)
  static void setMockUser(User user) {
    _currentUser = user;
    if (!_registeredUsers.any((u) => u.id == user.id)) {
      _registeredUsers.add(user);
    }
  }

  // Save user to Firestore
  static Future<void> saveUser(User user) async {
    try {
      await FirebaseConfig.usersCollection.doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'avatar': user.avatar,
        'isAdmin': user.isAdmin,
        'createdAt': user.createdAt.toIso8601String(),
      });
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  // Update user in Firestore
  static Future<void> updateUser(User user) async {
    try {
      await FirebaseConfig.usersCollection.doc(user.id).update({
        'name': user.name,
        'email': user.email,
        'avatar': user.avatar,
        'isAdmin': user.isAdmin,
      });
      
      // Update local list
      final index = _registeredUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _registeredUsers[index] = user;
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Delete user from Firestore
  static Future<void> deleteUser(String userId) async {
    try {
      await FirebaseConfig.usersCollection.doc(userId).delete();
      _registeredUsers.removeWhere((user) => user.id == userId);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // Initialize with default admin
  static Future<void> initializeAdmin() async {
    try {
      // Try to create admin user in Firebase Auth
      try {
        await FirebaseConfig.auth.createUserWithEmailAndPassword(
          email: 'admin@servify.com',
          password: 'admin123',
        );
        
        // Update display name
        final user = FirebaseConfig.auth.currentUser;
        if (user != null) {
          await user.updateDisplayName('Admin');
        }
      } catch (e) {
        // Admin user might already exist, that's okay
        print('Admin user might already exist: $e');
      }
      
      // Save admin user to Firestore
      final adminUser = User(
        id: FirebaseConfig.auth.currentUser?.uid ?? 'admin_001',
        name: 'Admin',
        email: 'admin@servify.com',
        isAdmin: true,
        createdAt: DateTime.now(),
      );
      
      if (!_registeredUsers.any((u) => u.isAdmin)) {
        _registeredUsers.add(adminUser);
        await saveUser(adminUser);
      }
    } catch (e) {
      print('Error initializing admin: $e');
    }
  }

  // Get current user stream
  static Stream<User?> get authStateChanges => FirebaseConfig.auth.authStateChanges().map((user) {
    if (user != null) {
      return User(
        id: user.uid,
        name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
        email: user.email ?? '',
        avatar: user.photoURL,
        isAdmin: user.email == 'admin@servify.com',
        createdAt: DateTime.now(),
      );
    }
    return null;
  });
}
