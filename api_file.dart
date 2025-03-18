import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class Api_Service {
  String baseURL = 'https://67d18b0990e0670699ba88cb.mockapi.io/user/';
  ProgressDialog? pd;

  void showProgressDialog(context) {
    if (pd == null) {
      pd = ProgressDialog(context);
      pd!.style(
        message: 'Please Wait',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
    }
    pd!.show();
  }

  void dismissProgress() {
    if (pd != null && pd!.isShowing()) {
      pd!.hide();
    }
  }

  Future<dynamic> getUsers(context) async {
    showProgressDialog(context);
    http.Response res = await http.get(Uri.parse(baseURL + 'users'));
    dismissProgress();
    return convertJSONToData(res);
  }

  Future<dynamic> addUser({context, Map<String, dynamic>? map}) async {
    showProgressDialog(context);
    http.Response res = await http.post(
      Uri.parse(baseURL + 'users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(map),
    );
    dismissProgress();
    return convertJSONToData(res);
  }

  Future<dynamic> updateUser({required String id, Map<String, dynamic>? map, context}) async {
    showProgressDialog(context);
    http.Response res = await http.put(
      Uri.parse(baseURL + 'users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(map),
    );
    dismissProgress();
    return convertJSONToData(res);
  }

  Future<dynamic> deleteUser({required String id, context}) async {
    showProgressDialog(context);
    http.Response res = await http.delete(Uri.parse(baseURL + 'users/$id'));
    dismissProgress();
    return convertJSONToData(res);
  }

  dynamic convertJSONToData(http.Response res) {
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 404) {
      return 'PAGE NOT FOUND, PLEASE CHECK YOUR URL';
    } else if (res.statusCode == 500) {
      return 'SERVER ERROR';
    } else {
      return 'NO DATA FOUND';
    }
  }
}
