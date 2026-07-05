import '../models/user_model.dart';

class AuthService {
  static User? _currentUser;
  static final List<User> _registeredUsers = [];

  static User? get currentUser => _currentUser;
  static List<User> get allUsers => List.unmodifiable(_registeredUsers);

  static void login(User user) {
    _currentUser = user;
    // Add to registered users if not already there
    if (!_registeredUsers.any((u) => u.id == user.id)) {
      _registeredUsers.add(user);
    }
  }

  static void logout() {
    _currentUser = null;
  }

  static bool get isLoggedIn => _currentUser != null;
  static bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Admin methods
  static void registerAdmin(User admin) {
    final adminUser = User(
      id: admin.id,
      name: admin.name,
      email: admin.email,
      avatar: admin.avatar,
      isAdmin: true,
      createdAt: admin.createdAt,
    );
    _registeredUsers.add(adminUser);
  }

  static void deleteUser(String userId) {
    _registeredUsers.removeWhere((user) => user.id == userId);
  }

  static void updateUser(User updatedUser) {
    final index = _registeredUsers.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _registeredUsers[index] = updatedUser;
    }
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
    }
  }

  // Initialize with default admin
  static void initializeAdmin() {
    if (!_registeredUsers.any((u) => u.isAdmin)) {
      final defaultAdmin = User(
        id: 'admin_001',
        name: 'Admin',
        email: 'admin@servify.com',
        isAdmin: true,
      );
      _registeredUsers.add(defaultAdmin);
    }
  }

  // Register new user
  static void registerUser(User user) {
    _registeredUsers.add(user);
  }

  // Update existing user
  static void updateExistingUser(User user) {
    final index = _registeredUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _registeredUsers[index] = user;
    }
  }

  // Delete user by ID
  static void deleteExistingUser(String userId) {
    _registeredUsers.removeWhere((user) => user.id == userId);
  }
}
