import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';

Future<List<dynamic>> fetchList(String raceId,String organisationId) async {
  final response = await http.get(Uri.parse('$apiUrl/organisation?id=$raceId&organisation_id=$organisationId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return List<dynamic>.from(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load classes');
  }


}


class OrganisationRoute extends StatefulWidget {
  final String raceId;
  final String organisationName;
  final String organisationId;
  const OrganisationRoute(this.raceId,this.organisationId,this.organisationName,{Key? key}) : super(key: key);

  @override
  State<OrganisationRoute> createState() => _OrganisationRouteState();

}

class _OrganisationRouteState extends State<OrganisationRoute> {
  late Future<List<dynamic>> partecipants;

  @override
  void initState() {
    partecipants = fetchList(widget.raceId,widget.organisationId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.organisationName),
        ),
        body: _buildList()
    );
  }

  Widget _buildList() {
    return Center(
      child: FutureBuilder<List<dynamic>>(
          future: partecipants,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var pList = snapshot.data!;
                return ListView.builder(
                    itemCount: pList.length,
                    itemBuilder: (context, index) {
                      if (pList[index]["id"] != null) {
                        return Card(
                          child:ListTile(
                                title: Text("#${pList[index]["Position"]}: ${pList[index]["Name"]["Given"]} ${pList[index]["Name"]["Family"]} - ${pList[index]["class"]}",style: TextStyle(fontSize:18)),
                                subtitle: Text(pList[index]["id"],style: TextStyle(fontSize:16)),
                                dense: true,
                              ),
                        );
                      } else {
                        return Card(
                          child: ListTile(
                            title: Text("#${pList[index]["Position"]}: ${pList[index]["Name"]['Given']} ${pList[index]["Name"]['Family']} - ${pList[index]["class"]} ",style: TextStyle(fontSize:18)),
                            subtitle: Text('Not defined'),
                            dense: true,
                          ),
                        );
                      }
                    });
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          }),
    );
  }
}
