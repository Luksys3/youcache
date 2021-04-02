import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youcache/enums/snack_bar_type_enum.dart';
import 'package:youcache/helpers/showSnackBar.dart';

class FetchService {
  final BuildContext context;

  FetchService(this.context);

  Future<http.Response?> get({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    return await _fetcher(
      method: 'GET',
      url: url,
      query: query,
    );
  }

  Future<http.Response?> post({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? query,
  }) async {
    return await _fetcher(
      method: 'POST',
      url: url,
      data: data,
      query: query,
    );
  }

  Future<http.Response?> _fetcher({
    required String method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    if (query != null) {
      url += url.contains('?') ? '&' : '?';

      List<String> queryList = [];
      query.forEach((key, value) {
        if (value == null) {
          return;
        }

        queryList.add('$key=${Uri.encodeQueryComponent(value.toString())}');
      });
      url += queryList.join('&');
    }

    final parsedUrl = Uri.parse(url);

    try {
      final response = method == 'POST'
          ? await http.post(
              parsedUrl,
              body: data,
            )
          : await http.get(
              parsedUrl,
            );

      if (response.statusCode == 404) {
        showSnackBar(
          context,
          'Playlist was not found or it cannot be accessed via link.',
          type: SnackBarTypeEnum.ERROR,
        );
        return null;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        showSnackBar(
          context,
          'Error occurred with status code ${response.statusCode}. Please try again later.',
          type: SnackBarTypeEnum.ERROR,
        );
        return null;
      }

      return response;
    } on SocketException {
      showSnackBar(
        context,
        'Error occurred. No connection to internet.',
        type: SnackBarTypeEnum.ERROR,
      );
    }
  }
}
