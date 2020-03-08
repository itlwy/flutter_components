# flutter_components

平常开发用到的一些组件汇总，希望以后能成为较为通用的组件库



## 目录

- [软键盘输入组件(可@人)](#软键盘输入组件(可@人))
- 



## 输入组件

### 软键盘输入组件(可@人)

#### 效果图

<img src="./resources/pics/keyboard_input.gif" width="320" height="640" />

#### 使用

```
 GlobalKey<KeyboardInputState> kbInputKey;

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
          builder: (context) => SingleChildScrollView(...),
          unique: "<userId>",
          showContent: "<userName>",
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
        ));
  }
  
 Future<Map<String, dynamic>> triggerCallback(
      List<Map<String, dynamic>> routerParams) async {
      /// 跳转选择人员页面
    String ret = await Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => UserPickerPage()));
    if (ret != null) {
    /// 将关心的信息返回
      Map<String, dynamic> map = {"userName": ret};
      return map;
    }
  }

  Future<bool> doneInput(List<Rule> rules, String value) async {
  /// 这里的Rule.params 属性里 会将刚刚triggerCallback里返回的map带回来
    print("输入完成：  value - $value ,rules.length : ${rules.length}");
    return Future.value(true);
  }
```

详细使用可见demo，比较简单





## License

   	Copyright 2020 lwy

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
       http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
