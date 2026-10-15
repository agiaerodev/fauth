class OtpAccountNotFoundException implements Exception {
  const OtpAccountNotFoundException();

  static bool matchesApiError(Object error) {
    return RegExp(r'^Exception: HTTP 404 - ').hasMatch(error.toString());
  }

  @override
  String toString() => 'No account was found for this email address.';
}
