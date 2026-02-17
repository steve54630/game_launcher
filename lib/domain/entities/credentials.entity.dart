class IgdbCredentials {
  final String clientId;
  final String clientSecret;

  IgdbCredentials({required this.clientId, required this.clientSecret});

  bool get isValid => clientId.isNotEmpty && clientSecret.isNotEmpty;
}
