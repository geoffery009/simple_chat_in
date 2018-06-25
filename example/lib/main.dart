import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_chat_in/simple_chat_in.dart';
import 'package:simple_chat_in/chat_tile_bean.dart';
import 'package:simple_chat_in/chat_tile_widget.dart';
import 'package:simple_chat_in/constant.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  String _platformVersion = 'Unknown';
  List<ChatTileWidget> data = new List<ChatTileWidget>();

  @override
  initState() {
    super.initState();
    initData();
  }

  initData() {
    textEditingController.clear();

    String testMP3 = "http://www.rxlabz.com/labz/audio.mp3";
    String testText = "和大连房价爱上了打案例";
    String testTextMore = "和大连房fasdfasdfasdf楼上价爱上了打飞机啊的房间案例";
    data.add(new ChatTileWidget(
        new ChatTileBean("fddddddd", Content.TYPE_TEXT, testText)));
    data.add(new ChatTileWidget(
        new ChatTileBean("ddddcddd", Content.TYPE_TEXT, testTextMore)));
    data.add(new ChatTileWidget(
        new ChatTileBean("zddddzddd", Content.TYPE_TEXT, testTextMore)));
    data.add(new ChatTileWidget(
        new ChatTileBean("tdddddcdd", Content.TYPE_TEXT, testTextMore)));
    data.add(new ChatTileWidget(
        new ChatTileBean(Test.LOGIN_UID, Content.TYPE_TEXT, testTextMore)));
    data.add(new ChatTileWidget(
        new ChatTileBean("vddddbddd", Content.TYPE_AUDIO, testMP3)));
    data.add(new ChatTileWidget(new ChatTileBean("nddddddd", 1, testMP3)));
  }

  ScrollController scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Container(
          color: Colors.grey[200],
          child: new Column(
            children: <Widget>[
              new Flexible(
                  child: new ListView.builder(
                controller: scrollController,
                reverse: true,
                itemBuilder: (BuildContext c, int index) {
                  return data[index];
                },
                itemCount: data.length,
              )),
              _getEditBottom(),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController textEditingController = new TextEditingController();

  Widget _getEditBottom() {
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      height: 48.0,
      color: Theme.of(context).primaryColor,
      child: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            controller: textEditingController,
          )),
          new Container(
            child: new Icon(Icons.add),
            padding: const EdgeInsets.all(8.0),
          ),
          new IconButton(
              icon: new Icon(Icons.send),
              onPressed: () {
                return (textEditingController.text.trim().toString() != null &&
                        textEditingController.text.trim().toString().length > 0)
                    ? _startSendMsg()
                    : null;
              })
        ],
      ),
    );
  }

  _startSendMsg() {
    String msg = textEditingController.text.trim().toString();
    ChatTileWidget widget = new ChatTileWidget(
        new ChatTileBean(Test.LOGIN_UID, Content.TYPE_TEXT, msg));
    setState(() {
      data.insert(0, widget);
      scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
    textEditingController.clear();
  }
}
