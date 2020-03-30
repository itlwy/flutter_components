import 'package:flutter/material.dart';
import 'package:flutter_components/utils/rich_text_util.dart';
import 'package:flutter_components/widgets/keyboard_input.dart';
import 'package:flutter_components/formatter/rich_text_input_formatter.dart';
import 'package:toast/toast.dart';
import 'sub/user_picker_page.dart';

class KeyboardInputAtPeoplePage extends StatefulWidget {
  @override
  _KeyboardInputAtPeoplePageState createState() =>
      _KeyboardInputAtPeoplePageState();
}

class _KeyboardInputAtPeoplePageState extends State<KeyboardInputAtPeoplePage> {
  GlobalKey<KeyboardInputState> kbInputKey;

  Map<String, dynamic> richParam;

  @override
  void initState() {
    kbInputKey = GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("键盘输入框+@人示例"),
        ),
        body: KeyboardInput(
          key: kbInputKey,
          mediaQueryData: MediaQuery.of(context),
          builder: (context) => SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                OutlineButton(
                  onPressed: () {
                    kbInputKey.currentState.popKeyboard();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.message,
                        color: Colors.blue,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text("input"),
                      )
                    ],
                  ),
                ),
                Divider(),
                RichTextUtil.buildRichText(
                    context: context,
                    paramMap: richParam,
                    actionCallback: (Map<String, dynamic> rule) => Toast.show(
                        "跳转协议: ${rule['router']}", context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)),
              ],
            ),
          ),
          unique: "userName",
          showContent: "userName",
          triggerAtCallback: triggerCallback,
          doneCallback: doneInput,
          rightMenuBuilder: (context) => GestureDetector(
            onTap: () => kbInputKey.currentState.doneInput(),
            child: Icon(
              Icons.send,
              color: Colors.blue,
              size: 20,
            ),
          ),
          decoration: InputDecoration(
            enabledBorder: null,
            disabledBorder: null,
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
            hintText: "请输入内容，可@人",
            border: InputBorder.none,
          ),
//          style: TextStyle(
//              fontSize: 16,
//              color: Color(0xFF020F22),
//
//              /// hintText不居中与光标位置不一致
//              textBaseline: TextBaseline.alphabetic),
        ));
  }

  Future<Map<String, dynamic>> triggerCallback(
      List<Map<String, dynamic>> routerParams) async {
    String ret = await Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => UserPickerPage()));
    if (ret != null) {
      Map<String, dynamic> map = {"userName": ret};
      return map;
    }
  }

  Future<bool> doneInput(List<Rule> rules, String value) async {
    print("输入完成：  value - $value ,rules: $rules");
    richParam = {
      "contentText": "$value",
      "rules": rules
          .map((Rule rule) => {
                "startIndex": rule.startIndex,
                "endIndex": rule.endIndex,
                "color": "#1E88E5",
                "router":
                    "scheme://go/to/userDetails/${rule.params['userName']}"
              })
          .toList()
    };
    setState(() {});
    return Future.value(true);
  }
}
