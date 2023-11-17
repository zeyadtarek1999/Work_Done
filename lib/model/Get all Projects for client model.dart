class GetAllProjectsApiRequest {
  String token;

  GetAllProjectsApiRequest({
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'auth': {
        'type': 'bearer',
        'bearer': [
          {'key': 'token', 'value': token, 'type': 'string'},
        ],
      },
      'method': 'GET',
      'header': [],
      'url': {
        'raw': 'https://www.workdonecorp.com/api/get_all_projects',
        'protocol': 'https',
        'host': ['www', 'workdonecorp', 'com'],
        'path': ['api', 'get_all_projects'],
      },
      'response': [],
    };
  }
}
