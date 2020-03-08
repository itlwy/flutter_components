import 'package:flutter/material.dart';

import 'pages/keyboard_input_at_people_page.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  List<Map<String, dynamic>> pages = [
    {"name": "软键盘输入组件+@人", "page": KeyboardInputAtPeoplePage()},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to components example',
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Welcome to components example'),
          ),
          body: Builder(
              builder: (context) => Center(
                      child: SingleChildScrollView(
                    child: Column(children: _buildExampleList(context)),
                  ))),
        ));
  }

  List<Widget> _buildExampleList(BuildContext context) {
    return pages
        .map((item) => RaisedButton(
              child: Text(item['name']),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return item['page'];
              })),
            ))
        .toList();
  }
}
