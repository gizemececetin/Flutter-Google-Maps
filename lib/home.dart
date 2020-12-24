import 'package:flutter/material.dart';

import 'maps.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: RaisedButton(
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0),
                side: BorderSide(color: Colors.deepPurple)
            ),
            onPressed: () {

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Maps()));
              //widget._task.warehouse, widget._task.destination)));
            },
            child: Text("Start Navigation",
                style: TextStyle(
                  fontFamily: "Quicksand-SemiBold",
                  color: Colors.white,
                  fontSize: 19,
                )),
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}
