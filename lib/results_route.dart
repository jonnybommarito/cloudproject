import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import './organisation_route.dart';

Future<List<dynamic>> fetchResults(String classId,String raceId) async {
  final response = await http.get(Uri.parse('$apiUrl/results?id=$raceId&class=$classId'));

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


class ResultsRoute extends StatefulWidget {
  final String raceId;
  final String classId;
  const ResultsRoute(this.raceId,this.classId,{Key? key}) : super(key: key);

  @override
  State<ResultsRoute> createState() => _ResultsRouteState();

}

class _ResultsRouteState extends State<ResultsRoute> {
  late Future<List<dynamic>> futureResults;
  var difResults = [];
  List<dynamic> results = [];
  var oldResult = [];

  @override
  void initState() {
    futureResults = fetchResults(widget.classId,widget.raceId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.classId} Results'),
      ),
      body: _buildList()
    );
  }


  Widget getCard(id,name,surname,position,organisationName,organisationID) {
    var sub = '';
    var color ;
    var icon;
    id == null ? {sub = 'Not defined',icon= FaIcon(FontAwesomeIcons.exclamation,size: 40,color: Colors.red)} : sub = id ;
    !difResults.contains(id)? color = Colors.red: color = Colors.black;
    return Card(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            ListTile(
              title: Text("#${position}: ${name} ${surname}",style: TextStyle(color: color,fontSize:18)),
              subtitle: Text(sub,style: TextStyle(fontSize:16)),
              trailing: icon,
              dense: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const SizedBox(width: 8),
                if(organisationName != null)
                  TextButton(
                    child: Text(organisationName),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrganisationRoute(widget.raceId,organisationID,organisationName),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ]
      ),
    );
  }

  Widget _buildList() {
    return Center(
      child: FutureBuilder<List<dynamic>>(
        future: futureResults,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            results = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return getCard(results[index]["id"],results[index]["Name"]["Given"],results[index]["Name"]["Family"],results[index]["Position"],results[index]["Organisation"]["Name"],results[index]["Organisation"]["Id"]);
                  }),
            );

          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        }),
    );
  }

  Future<void> _refresh() async {
    difResults.clear();//Clear the list everytime it enters the function to avoid repetition of already found differences
    oldResult = await futureResults;
    for (dynamic v in oldResult) {
      if( v['id'] != null){
        difResults.add(v['id']);
      }
    }
    setState (() {
      futureResults = fetchResults(widget.classId,widget.raceId);
    });

    return Future.delayed(
      Duration(seconds:8),
    );
  }
}
