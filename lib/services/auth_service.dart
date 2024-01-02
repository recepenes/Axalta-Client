import 'dart:convert';

import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/model/update_user_password_dto.dart';
import 'package:http/http.dart' as http;
import 'package:axalta/exceptions/form_exceptions.dart';
import 'package:axalta/exceptions/secure_storage_exceptions.dart';
import 'package:axalta/model/user_model.dart';
import 'package:axalta/services/helper_service.dart';
import 'dart:developer' as devtools show log;

import 'package:axalta/services/secure_storage_service.dart';

class AuthService {
  static const String loginPath = '/login';
  static const String registerPath = 'users/';
  static const String refreshPath = 'token/refresh/';
  static const String verifyPath = 'token/verify/';

  static Future<User> loadUser() async {
    final json = await SecureStorageService.storage.read(
      key: SecureStorageService.userKey,
    );
    if (json != null) {
      return User.fromJson(jsonDecode(json));
    } else {
      throw SecureStorageNotFoundException();
    }
  }

  static void saveUser(User user) async {
    await SecureStorageService.storage.write(
      key: SecureStorageService.userKey,
      value: user.toJson(),
    );
  }

  static Future<void> refreshToken(User user) async {
    final response = await http.post(
      HelperService.buildUri(refreshPath),
      headers: HelperService.buildHeaders(),
      body: jsonEncode(
        {
          'refresh': user.refreshToken,
        },
      ),
    );

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        user.accessToken = json['access'];
        saveUser(user);
        break;
      case 400:
      case 300:
      case 500:
      default:
        throw Exception('Error contacting the server!');
    }
  }

  static Future<User> register({
    required String email,
    required String password,
    required String cellphone,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.post(
      HelperService.buildUri(loginPath),
      headers: HelperService.buildHeaders(),
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'cellphone': cellphone,
          'first_name': firstName,
          'last_name': lastName
        },
      ),
    );

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        final user = User.fromJson(json);

        saveUser(user);

        return user;
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<void> logout() async {
    await SecureStorageService.storage.delete(
      key: SecureStorageService.userKey,
    );
  }

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      HelperService.buildUri(loginPath),
      headers: HelperService.buildHeaders(),
      body: jsonEncode(
        {
          'username': email,
          'password': password,
        },
      ),
    );

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        String token = json["token"];
        // final user = User.fromJson(json);
        userToken = token;
        var localUser = User(
            id: 1,
            email: "email@email.com",
            firstName: "firstName",
            lastName: "lastName",
            cellphone: "505",
            accessToken: token,
            refreshToken: "");

        saveUser(localUser);

        return localUser;
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<bool> updateUserPassword(UpdateUserPasswordDto dto) async {
    const path = "userauthentication/update-password";
    Uri uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: apiRoute + path,
    );

    final Map<String, dynamic> data = {
      "currentPassword": dto.currentPassword,
      "newPassword": dto.newPassword,
      "confirmPassword": dto.confirmPassword,
    };

    try {
      final http.Response response = await http.post(
        uri,
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken'
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        devtools.log(response.body);
      }
    } catch (e) {
      devtools.log("Update password Exception" + e.toString());
      return false;
    }
    return false;
  }
}
