import 'package:ctracker/models/user.dart';
import 'package:ctracker/utils/storage_service.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthService {
  final StorageService _storageService;
  final PocketBase _pocketBase;
  AuthService(this._storageService, this._pocketBase) {
    _initializeAuthStore();
    _initAuthListener();
  }

  void _initializeAuthStore() {
    User? localUser = _storageService.getUser();
    if (localUser == null || localUser.token.isEmpty) return;

    _pocketBase.authStore
        .save(localUser.token, RecordModel.fromJson(localUser.toJson()));
  }

  void _initAuthListener() {
    _pocketBase.authStore.onChange.listen((AuthStoreEvent event) {
      if (event.model is RecordModel) {
        var userModel = User.fromJson(event.model.toJson());
        userModel.token = event.token;
        _storageService.saveUser(userModel);
      } else {
        // Optionally handle logout or token expiration
        _storageService.clearUser();
      }
    });
  }

  User? get currentUser => _storageService.getUser();

  bool get isAuth => currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      final authData = await _pocketBase.collection('users').authWithPassword(
            email,
            password,
          );

      _pocketBase.authStore.save(authData.token, authData.record);

      User user = User(
          id: authData.record?.id ?? "", email: email, token: authData.token);
      await _storageService.saveUser(user);
      return true;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearUser(); // Clear user info from local storage
  }
}
