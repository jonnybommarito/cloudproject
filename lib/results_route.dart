import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';

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

  Widget _buildList() {
    return Center(
      child: FutureBuilder<List<dynamic>>(
        future: futureResults,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var results = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    if (results[index]["id"] != null) {
                      return Card(
                          child: ListTile(
                            title: Text("#${results[index]["Position"]}: ${results[index]["Name"]["Given"]} ${results[index]["Name"]["Family"]}"),
                            subtitle: Text(results[index]["id"]),
                            dense: true,
                          )
                      );
                    } else {
                      return Card(
                        child: ListTile(
                          title: Text("#${index+1}: ${results[index]["Name"]['Given']} ${results[index]["Name"]['Family']}"),
                          subtitle: Text('Not defined'),
                          dense: true,
                        ),
                      );
                    }
                  }),
            );

          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        }),
    );
  }

  Future<void> _refresh() async{
    setState (() {
      futureResults = fetchResults(widget.classId,widget.raceId);
    });
    return Future.delayed(
        Duration(seconds:8),
    );
  }
}
