import 'package:coronavirus_project/app/repositories/endpoints_data.dart';
import 'package:coronavirus_project/app/services/api.dart';
import 'package:coronavirus_project/app/services/api_service.dart';
import 'package:coronavirus_project/app/services/data_cache_service.dart';
import 'package:coronavirus_project/app/services/endpoint_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class DataRepository {
  DataRepository({@required this.dataCacheService, @required this.apiService});
  final APIService apiService;
  final DataCacheService dataCacheService;

  String _accessToken;

  Future<EndpointData> getEndpointData(Endpoint endpoint) async =>
    await _getDataRefreshingToken<EndpointData>(
      onGetData: () => apiService.getEndpointData(
        accessToken: _accessToken, endpoint: endpoint) 
    );

  EndpointsData getAllEndpointsCacheData() => dataCacheService.getData();

  Future<EndpointsData> getAllEndpointsData() async {
    final endpointsData = await _getDataRefreshingToken<EndpointsData>(
      onGetData: _getAllEndpointData,
       );
      await dataCacheService.setData(endpointsData);
      return endpointsData;
    }
  Future<T> _getDataRefreshingToken<T>({Future<T> Function() onGetData}) async{
    
    // throw 'error';
    try{
    if (_accessToken == null){
      _accessToken = await apiService.getAccessToken();
    }
    // final accessToken = await apiService.getAccessToken();
    return await onGetData();
    } on Response catch (response){
      if(response.statusCode == 401){
        _accessToken = await apiService.getAccessToken();
        return await onGetData();
      }
      rethrow;
    }
  }

    Future<EndpointsData> _getAllEndpointData() async{
    
    final values = await Future.wait([
        apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.cases),
        apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.casesSuspected),
        apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.casesConfirmed),
        apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.deaths),
        apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.recovered),
    ]);
    return EndpointsData(
      values: {
      Endpoint.cases: values[0],
      Endpoint.casesSuspected: values[1],
      Endpoint.casesConfirmed: values[2],
      Endpoint.deaths: values[3],
      Endpoint.recovered: values[4],
      }
    );
  }
}

