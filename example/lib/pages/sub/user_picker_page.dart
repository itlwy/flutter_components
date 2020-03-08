import 'package:flutter/material.dart';

class UserPickerPage extends StatefulWidget {
  @override
  _UserPickerPageState createState() => _UserPickerPageState();
}

class _UserPickerPageState extends State<UserPickerPage> {
  TextEditingController dialogController;

  @override
  void initState() {
    dialogController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选择页"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: TextField(
              controller: dialogController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                hintText: "please input...",
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF020F22),

                  /// hintText不居中与光标位置不一致
                  textBaseline: TextBaseline.alphabetic),
            ),
          ),
          RaisedButton(
            onPressed: () {
              String value = dialogController.text;
              Navigator.of(context).pop(value);
            },
            child: Text("确定"),
          ),
        ],
      ),
    );
  }
}
