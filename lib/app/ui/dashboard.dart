import 'dart:io';

import 'package:coronavirus_project/app/repositories/data_repository.dart';
import 'package:coronavirus_project/app/repositories/endpoints_data.dart';
import 'package:coronavirus_project/app/services/api.dart';
import 'package:coronavirus_project/app/ui/endpoint_card.dart';
import 'package:coronavirus_project/app/ui/last_updated_status_text.dart';
import 'package:coronavirus_project/app/ui/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
    EndpointsData _endpointsData;

    @override
    void initState(){
        super.initState();
        final dataRepository = Provider.of<DataRepository>(context, listen: false);
        _endpointsData = dataRepository.getAllEndpointsCacheData();
        _updateData();
    }
    
    Future<void> _updateData() async{
      try{
      final dataRepository = Provider.of<DataRepository>(context, listen: false);
      final endpointsData = await dataRepository.getAllEndpointsData();
      setState(() => _endpointsData = endpointsData);
      } on SocketException {
          showAlertDialog(
              context: context,
              title: 'Connection Error',
              content: 'Could not retrieve data. Please try again later.',
              defaultActionTest: 'OK',
          );
      } catch (_){
          showAlertDialog(
              context: context,
              title: 'Unknown Error',
              content: 'Please contact support or try again later.',
              defaultActionTest: 'OK',
          );
      }
    }

  @override
  Widget build(BuildContext context) {
    final formatter = LastUpdatedDataFormatter(
      lastUpdated: _endpointsData != null 
                    ?_endpointsData.values[Endpoint.cases]?.date : null
                  );
    return Scaffold(
      appBar: AppBar(
        title: Text('COVID-19 WORLD TRACKER'),
      ),
      body: RefreshIndicator(
        onRefresh: _updateData,
          child: ListView(    
          children: <Widget>[
            LastUpdatedStatusText(
              text: formatter.lastUpdatedStatusText(),),
            for(var endpoint in Endpoint.values)
            EndpointCard(
              endpoint: endpoint,
              value : _endpointsData != null 
              ?_endpointsData.values[endpoint]?.value : null,
            ),
          ],
        ), 
      )
    );
  }
}