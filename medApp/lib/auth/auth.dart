import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medApp/auth/user.dart';

import 'error_handling.dart';

class AuthService {
  // sign up user
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        address: '',
        type: '',
        token: '',
        cart: [],
      );
    } catch (e) {
      print("faillllll");
      //showSnackBar(context, e.toString());
    }
  }
}
