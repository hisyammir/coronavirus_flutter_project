import 'dart:convert';
import 'dart:io';

import 'package:coronavirus_project/app/services/endpoint_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:coronavirus_project/app/services/api.dart';
import 'package:http/io_client.dart';

class APIService{
  APIService(this.api);
  final API api;

  Future<String> getAccessToken() async{
    HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = new IOClient(httpClient);
    final response = await ioClient.post(
      api.tokenUri().toString(),
      headers: {'Authorization': 'Basic ${api.apiKey}'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final accessToken = data['access_token'];
      if (accessToken != null) {
        return accessToken;
      }
    }
    print(
        'Request ${api.tokenUri()} failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
    throw response;
  }

  Future<EndpointData> getEndpointData ({
    @required String accessToken,
    @required Endpoint endpoint,
  }) async{
    HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = new IOClient(httpClient);
    final uri = api.endpointUri(endpoint);
    final response = await ioClient.get(
      uri.toString(),
      headers: {'Authorization': 'Bearer $accessToken'}
    );
    if (response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty){
          final Map<String, dynamic> endpointData = data[0];
          final String responseJsonKey = _responseJsonKeys[endpoint];
          final int value = endpointData[responseJsonKey];
          final String dateString = endpointData['date'];
          final date = DateTime.tryParse(dateString);
          if(value != null){
            return EndpointData(value: value, date: date);
          }
        }
     }
     print('Request $uri failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
     throw response;
  }

  static Map<Endpoint, String> _responseJsonKeys = {
      Endpoint.cases: 'cases',
      Endpoint.casesSuspected: 'data',
      Endpoint.casesConfirmed: 'data',
      Endpoint.deaths: 'data',
      Endpoint.recovered: 'data',
  };


}