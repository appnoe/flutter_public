import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:async/async.dart';

import './show_details.dart';
import '../api/api.dart';
import '../crypto/cryptokit.dart';
import '../model/tvmazesearchresult.dart' as _model;

class ShowList extends StatefulWidget {
  const ShowList({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ShowList> createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  static String hash = "";
  static CryptoKit cryptoKit = CryptoKit();
  var apiData = <_model.TVMazeSearchResult>[];
  String searchString = 'simpsons';
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
    cryptoKit.getHash("foobar");
    _loadData(searchString);
  }

  Future<bool> _loadData(String searchText) async {
    this._memoizer.runOnce(() async {
      var result = await Api().fetchShow(searchText);
      setState(() {
        apiData = result!;
      });
    });
    return true;
  }

  _model.Show? _showWithID(int id) {
    for (var i = 0; i < apiData.length; i++) {
      if (apiData[i].show?.id == id) {
        return apiData[i].show;
      }
    }
    return null;
  }

  void _onTapImage(int id) {
    if (kDebugMode) {
      logDebug("onTapImage: $id");
    }
    var show = _showWithID(id);
    if (show != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ShowDetails(show: show);
      }));
    }
  }

  List<TableRow> _buildTableRows(List<_model.TVMazeSearchResult>? result) {
    var rows = <TableRow>[];
    result?.forEach((show) {
      var row = TableRow(children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 0.0, top: 12.0, right: 0.0, bottom: 0.0),
              child: GestureDetector(
                  child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: show.show!.image != null
                          ? show.show!.image!.medium!
                          : ''),
                  onTap: () {
                    _onTapImage(show.show!.id!);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 0.0, top: 8.0, right: 0.0, bottom: 12.0),
              child: Text(show.show!.name!),
            )
          ],
        )
      ]);
      rows.add(row);
    });

    return rows;
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Suche nach Filmen'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  searchString = value;
                });
              },
              decoration: const InputDecoration(hintText: "Suchbegriff"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Abbrechen'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: const Text('Suchen'),
                onPressed: () {
                  setState(() {
                    _loadData(searchString);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: GestureDetector(
            onTap: () {
              _displayTextInputDialog(context);
            },
            child: const Icon(
              Icons.search,
            ),
          ),
        ),
        body: FutureBuilder<bool>(
          future: _loadData("simpsons"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Table(
                  children: _buildTableRows(apiData),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
