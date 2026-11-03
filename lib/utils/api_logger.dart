import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Colored request / response logging for the debug console. Only active in
/// debug builds; release builds neither log nor wrap anything.
///
/// ANSI colors show in `flutter run`, the VS Code / Android Studio run consoles
/// and `adb logcat` viewers that render them.
class ApiLog {
  const ApiLog._();

  static const _reset = '\x1B[0m';
  static const _dim = '\x1B[2m';
  static const _bold = '\x1B[1m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _magenta = '\x1B[35m';
  static const _cyan = '\x1B[36m';
  static const _gray = '\x1B[90m';

  /// Longest body that is printed; the rest is cut so the console stays readable.
  static const _maxBody = 3000;

  static String _methodColor(String method) {
    return switch (method.toUpperCase()) {
      'GET' => _cyan,
      'POST' => _green,
      'PUT' || 'PATCH' => _yellow,
      'DELETE' => _red,
      _ => _magenta,
    };
  }

  static String _statusColor(int code) {
    if (code >= 500) {
      return _magenta;
    }
    if (code >= 400) {
      return _red;
    }
    if (code >= 300) {
      return _yellow;
    }
    if (code >= 200) {
      return _green;
    }
    return _red;
  }

  /// One console line per call: the console cuts long lines and would drop the
  /// color of the rest, so every line carries its own color codes.
  static void _line(String color, String text) {
    // ignore: avoid_print
    print('$color$text$_reset');
  }

  static String _pretty(String body) {
    if (body.isEmpty) {
      return '';
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(json.decode(body));
    } catch (_) {
      return body;
    }
  }

  static void _printBody(String color, String body) {
    final text = _pretty(body);
    if (text.isEmpty) {
      return;
    }
    final cut = text.length > _maxBody;
    final lines = (cut ? text.substring(0, _maxBody) : text).split('\n');
    for (final line in lines) {
      _line(color, '$_gray│$_reset $color$line');
    }
    if (cut) {
      _line(_gray, '│ … ${text.length - _maxBody} more characters');
    }
  }

  /// `Bearer eyJhbGci…` → `Bearer eyJhbGci…(masked)`; tokens stay out of the logs.
  static String _maskAuth(String value) {
    final parts = value.split(' ');
    final token = parts.last;
    final shown = token.length <= 10 ? token : '${token.substring(0, 10)}…';
    return '${parts.length > 1 ? '${parts.first} ' : ''}$shown (masked)';
  }

  static void request(String method, Uri uri, {Map<String, String>? headers, String? body}) {
    final color = _methodColor(method);
    _line(_gray, '┌──────────────────────────────────────────────');
    _line(color, '$_bold${method.toUpperCase().padRight(6)}$_reset$color $uri');
    final auth = headers?.entries.where((e) => e.key.toLowerCase() == 'authorization').firstOrNull;
    if (auth != null) {
      _line(_gray, '│ auth: ${_maskAuth(auth.value)}');
    }
    if (body != null && body.isNotEmpty) {
      _line(_blue, '│ request body:');
      _printBody(_blue, body);
    }
  }

  static void response(String method, Uri uri, int status, Duration took, String body) {
    final color = _statusColor(status);
    final slow = took.inMilliseconds > 1500;
    _line(color, '$_bold$status$_reset$color ${method.toUpperCase()} ${uri.path}  $_dim${slow ? _yellow : _gray}${took.inMilliseconds} ms');
    _printBody(color, body);
    _line(_gray, '└──────────────────────────────────────────────');
  }

  static void failure(String method, Uri uri, Object error, Duration took) {
    _line(_red, '$_bold✗$_reset$_red ${method.toUpperCase()} ${uri.path}  $_dim${took.inMilliseconds} ms');
    _line(_red, '│ $error');
    _line(_gray, '└──────────────────────────────────────────────');
  }

  /// A new [Dio] that logs in debug builds.
  static Dio newDio() {
    final dio = Dio();
    if (kDebugMode) {
      dio.interceptors.add(_DioLogger());
    }
    return dio;
  }
}

/// Wraps an [http.Client] so every `http.get` / `http.post` of the app is logged.
/// Installed once in `main` with `http.runWithClient`.
class LoggingClient extends http.BaseClient {
  LoggingClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final watch = Stopwatch()..start();
    final String? body = switch (request) {
      http.Request() => request.body,
      http.MultipartRequest() => 'multipart  fields: ${request.fields}  files: ${request.files.map((f) => f.filename).toList()}',
      _ => null,
    };
    ApiLog.request(request.method, request.url, headers: request.headers, body: body);
    try {
      final response = await _inner.send(request);
      // The body stream can be read once; read it for the log and hand on a copy.
      final bytes = await response.stream.toBytes();
      ApiLog.response(request.method, request.url, response.statusCode, watch.elapsed, utf8.decode(bytes, allowMalformed: true));
      return http.StreamedResponse(
        http.ByteStream.fromBytes(bytes),
        response.statusCode,
        contentLength: bytes.length,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error) {
      ApiLog.failure(request.method, request.url, error, watch.elapsed);
      rethrow;
    }
  }

  @override
  void close() => _inner.close();
}

class _DioLogger extends Interceptor {
  static const _startKey = 'api_log_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    final data = options.data;
    ApiLog.request(
      options.method,
      options.uri,
      headers: {for (final e in options.headers.entries) e.key: '${e.value}'},
      body: data == null ? null : (data is String ? data : (data is FormData ? 'form-data  fields: ${data.fields}  files: ${data.files.map((f) => f.value.filename).toList()}' : jsonEncode(data))),
    );
    handler.next(options);
  }

  Duration _took(RequestOptions options) {
    final start = options.extra[_startKey] as int?;
    return start == null ? Duration.zero : Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - start);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    ApiLog.response(response.requestOptions.method, response.requestOptions.uri, response.statusCode ?? 0, _took(response.requestOptions), data is String ? data : jsonEncode(data));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      final data = response.data;
      ApiLog.response(err.requestOptions.method, err.requestOptions.uri, response.statusCode ?? 0, _took(err.requestOptions), data is String ? data : jsonEncode(data));
    } else {
      ApiLog.failure(err.requestOptions.method, err.requestOptions.uri, err.message ?? err.type.name, _took(err.requestOptions));
    }
    handler.next(err);
  }
}
