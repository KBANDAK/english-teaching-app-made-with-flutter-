import 'dart:async';
import 'dart:convert';
import 'dart:io' show InternetAddress, SocketException; // works on mobile/desktop
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ApiClient similar to axios instance with:
/// - baseURL
/// - cookie-based sessions (best-effort on mobile/desktop)
/// - response interceptor: on 401/403 -> refresh-token -> retry + queue
///
/// Notes:
/// - On Web, setting "Cookie" header manually is blocked by browser security.
///   For Web you usually need proper CORS + SameSite cookies + browser-managed credentials.
/// - Dart http doesn't expose headersAll, so multiple Set-Cookie headers may be collapsed.
///   We parse what we can from res.headers["set-cookie"].
class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 25),
    this.debug = false,
    this.userAgent = "KasselApp/1.0 (Flutter)",
    this.maxNetworkRetries = 1,
    this.retryDelay = const Duration(milliseconds: 350),
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  /// Global request timeout
  final Duration timeout;

  /// Print logs
  final bool debug;

  /// User-Agent header
  final String userAgent;

  /// retry count for transient network errors (Socket/Timeout)
  final int maxNetworkRetries;

  /// delay between retries
  final Duration retryDelay;

  bool _isRefreshing = false;
  final List<_QueuedRequest> _failedQueue = [];

  // very small in-memory cookie jar
  final Map<String, String> _cookies = {};

  // -------------------------
  // URL builder (safe)
  // -------------------------
  Uri _u(String path) {
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return Uri.parse(path);
    }

    final b = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final p = path.startsWith("/") ? path : "/$path";
    return Uri.parse("$b$p");
  }

  // -------------------------
  // Headers + Cookies
  // -------------------------
  Map<String, String> _defaultHeaders({Map<String, String>? headers}) {
    final h = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
      "User-Agent": userAgent,
      ...?headers,
    };

    // On Web you cannot set Cookie header manually.
    if (!kIsWeb) {
      final cookieHeader = _cookieHeader();
      if (cookieHeader.isNotEmpty) {
        h["Cookie"] = cookieHeader;
      }
    }

    return h;
  }

  String _cookieHeader() {
    if (_cookies.isEmpty) return "";
    return _cookies.entries.map((e) => "${e.key}=${e.value}").join("; ");
  }

  void _saveCookies(http.Response res) {
    if (kIsWeb) return; // browser manages cookies on web (if configured)

    final setCookie = res.headers["set-cookie"];
    if (setCookie == null || setCookie.isEmpty) return;

    final parts = _splitSetCookie(setCookie);
    for (final sc in parts) {
      final cookiePair = sc.split(";").first.trim(); // name=value
      final eq = cookiePair.indexOf("=");
      if (eq <= 0) continue;

      final name = cookiePair.substring(0, eq).trim();
      final value = cookiePair.substring(eq + 1).trim();
      if (name.isEmpty) continue;

      if (value.isEmpty) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
      }
    }
  }

  List<String> _splitSetCookie(String header) {
    // Parse concatenated Set-Cookie values, splitting only on commas that are
    // NOT inside Expires=... attribute.
    final out = <String>[];
    final sb = StringBuffer();

    bool inExpires = false;

    for (var i = 0; i < header.length; i++) {
      final ch = header[i];

      // detect "Expires="
      if (!inExpires && _startsWithIgnoreCase(header, i, "expires=")) {
        inExpires = true;
      }

      // Expires ends at ';'
      if (inExpires && ch == ';') {
        inExpires = false;
      }

      if (ch == ',' && !inExpires) {
        final part = sb.toString().trim();
        if (part.isNotEmpty) out.add(part);
        sb.clear();
        continue;
      }

      sb.write(ch);
    }

    final last = sb.toString().trim();
    if (last.isNotEmpty) out.add(last);

    return out;
  }

  bool _startsWithIgnoreCase(String s, int start, String pat) {
    if (start + pat.length > s.length) return false;
    return s.substring(start, start + pat.length).toLowerCase() == pat.toLowerCase();
    // simple + safe
  }

  // -------------------------
  // PUBLIC methods
  // -------------------------
  Future<http.Response> get(String path, {Map<String, String>? headers}) =>
      _send(method: "GET", path: path, headers: headers);

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) =>
      _send(method: "POST", path: path, headers: headers, body: body);

  Future<http.Response> put(String path, {Map<String, String>? headers, Object? body}) =>
      _send(method: "PUT", path: path, headers: headers, body: body);

  Future<http.Response> patch(String path, {Map<String, String>? headers, Object? body}) =>
      _send(method: "PATCH", path: path, headers: headers, body: body);

  Future<http.Response> delete(String path, {Map<String, String>? headers, Object? body}) =>
      _send(method: "DELETE", path: path, headers: headers, body: body);

  // -------------------------
  // Core sender with interceptor logic
  // -------------------------
  Future<http.Response> _send({
    required String method,
    required String path,
    Map<String, String>? headers,
    Object? body,
    bool retry = false,
    int networkAttempt = 0,
  }) async {
    final uri = _u(path);

    final h = _defaultHeaders(headers: headers);
    final encodedBody = body == null ? null : jsonEncode(body);

    http.Response res;

    try {
      res = await _rawRequest(
        method: method,
        uri: uri,
        headers: h,
        body: encodedBody,
      ).timeout(timeout);
    } on TimeoutException catch (e) {
      // network retry
      if (networkAttempt < maxNetworkRetries) {
        await Future.delayed(retryDelay);
        return _send(
          method: method,
          path: path,
          headers: headers,
          body: body,
          retry: retry,
          networkAttempt: networkAttempt + 1,
        );
      }
      rethrow;
    } on SocketException catch (e) {
      if (networkAttempt < maxNetworkRetries) {
        await Future.delayed(retryDelay);
        return _send(
          method: method,
          path: path,
          headers: headers,
          body: body,
          retry: retry,
          networkAttempt: networkAttempt + 1,
        );
      }
      rethrow;
    } catch (_) {
      rethrow;
    }

    _saveCookies(res);

    if (debug) {
      _logResponse(method: method, uri: uri, res: res);
    }

    final status = res.statusCode;

    // Refresh only on 401/403 and only if not already retried
    // Also avoid refresh recursion if the request itself is refresh-token.
    final isRefreshCall = _isRefreshPath(path);

    if (!isRefreshCall && (status == 401 || status == 403) && !retry) {
      return _handleAuthErrorAndRetry(
        method: method,
        path: path,
        headers: headers,
        body: body,
      );
    }

    return res;
  }

  bool _isRefreshPath(String path) {
    final p = path.trim().toLowerCase();
    return p.contains("/users/refresh-token");
  }

  Future<http.Response> _rawRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    switch (method.toUpperCase()) {
      case "GET":
        return _client.get(uri, headers: headers);
      case "POST":
        return _client.post(uri, headers: headers, body: body);
      case "PUT":
        return _client.put(uri, headers: headers, body: body);
      case "PATCH":
        return _client.patch(uri, headers: headers, body: body);
      case "DELETE":
        return _client.delete(uri, headers: headers, body: body);
      default:
        throw UnsupportedError("Unsupported method: $method");
    }
  }

  Future<http.Response> _handleAuthErrorAndRetry({
    required String method,
    required String path,
    Map<String, String>? headers,
    Object? body,
  }) async {
    // If refresh in progress -> queue the request
    if (_isRefreshing) {
      final completer = Completer<http.Response>();
      _failedQueue.add(
        _QueuedRequest(
          completer: completer,
          method: method,
          path: path,
          headers: headers,
          body: body,
        ),
      );
      return completer.future;
    }

    _isRefreshing = true;

    try {
      // refresh-token
      final refreshUri = _u("/users/refresh-token");

      final refreshRes = await _rawRequest(
        method: "POST",
        uri: refreshUri,
        headers: _defaultHeaders(),
        body: jsonEncode({}),
      ).timeout(timeout);

      _saveCookies(refreshRes);

      if (debug) {
        _logResponse(method: "POST", uri: refreshUri, res: refreshRes);
      }

      if (refreshRes.statusCode >= 400) {
        final err = Exception("Refresh failed: ${refreshRes.statusCode} ${refreshRes.body}");
        _processQueue(error: err);

        // Return a clear failed response
        return http.Response(
          refreshRes.body.isNotEmpty ? refreshRes.body : "Refresh failed",
          refreshRes.statusCode,
          headers: refreshRes.headers,
          request: refreshRes.request,
        );
      }

      // success -> process queue
      _processQueue(error: null);

      // retry original request with retry=true
      return _send(
        method: method,
        path: path,
        headers: headers,
        body: body,
        retry: true,
      );
    } catch (e) {
      _processQueue(error: e);
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  void _processQueue({Object? error}) {
    for (final q in _failedQueue) {
      if (error != null) {
        if (!q.completer.isCompleted) q.completer.completeError(error);
      } else {
        _send(
          method: q.method,
          path: q.path,
          headers: q.headers,
          body: q.body,
          retry: true,
        ).then((r) {
          if (!q.completer.isCompleted) q.completer.complete(r);
        }).catchError((e) {
          if (!q.completer.isCompleted) q.completer.completeError(e);
        });
      }
    }
    _failedQueue.clear();
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required http.Response res,
  }) {
    debugPrint("API [$method] ${uri.toString()}");
    debugPrint("-> Status: ${res.statusCode}");
    final ct = res.headers["content-type"] ?? "";
    debugPrint("-> Content-Type: $ct");
    if (res.body.isNotEmpty) {
      final sample = res.body.length > 1200 ? res.body.substring(0, 1200) : res.body;
      debugPrint("-> Body: $sample");
    }
  }

  /// Optional: quick connectivity check (mobile/desktop only).
  /// Use before calls if you want.
  Future<bool> hasInternet({Duration checkTimeout = const Duration(seconds: 3)}) async {
    if (kIsWeb) return true; // browser decides
    try {
      final r = await InternetAddress.lookup("google.com").timeout(checkTimeout);
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void close() => _client.close();
}

class _QueuedRequest {
  _QueuedRequest({
    required this.completer,
    required this.method,
    required this.path,
    this.headers,
    this.body,
  });

  final Completer<http.Response> completer;
  final String method;
  final String path;
  final Map<String, String>? headers;
  final Object? body;
}
