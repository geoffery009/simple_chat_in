import 'package:flutter/material.dart';
import 'package:simple_chat_in/chat_tile_bean.dart';
import 'package:simple_chat_in/constant.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:fluttie/fluttie.dart';

//这是一条消息的布局，包括头像及消息内容
class ChatTileWidget extends StatefulWidget {
  final ChatTileBean bean;

  ChatTileWidget(this.bean);

  @override
  _ChatTileWidgetState createState() => new _ChatTileWidgetState();
}

class _ChatTileWidgetState extends State<ChatTileWidget> {
  ChatTileBean mBean;
  var textColor = Colors.black;

  //音频
  Duration duration; //总时间
  Duration position; //已播放时间
  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';
  AudioPlayer audioPlayer; //播放器
  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  //lottie播放动画
  var instance = new Fluttie();
  var emojiComposition;

  FluttieAnimationController shockedEmoji;
  bool ready = false;

  @override
  Widget build(BuildContext context) {
    return _getTileContentWidget();
  }

  @override
  void initState() {
    super.initState();
    mBean = widget.bean;
//    _initLoadingAnimation();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer?.stop();
  }

  //Tile内容布局
  Widget _getTileContentWidget() {
    return new Container(
      margin: _isLoginUser()
          ? const EdgeInsets.only(
          left: 42.0, right: 16.0, bottom: 12.0, top: 12.0)
          : const EdgeInsets.only(
          left: 16.0, right: 42.0, bottom: 12.0, top: 12.0),
      child: new Row(
        children: _isLoginUser()
            ? [_getContentWidget(), _getUserWidget()]
            : [_getUserWidget(), _getContentWidget()],
      ),
    );
  }

  //头像布局
  Widget _getUserWidget() {
    return new Container(
      margin: _isLoginUser()
          ? const EdgeInsets.only(left: 18.0)
          : const EdgeInsets.only(right: 18.0),
      child: new CircleAvatar(
        child: new Text(
            _isLoginUser() ? "Me" : mBean.uid.substring(0, 1).toUpperCase()),
      ),
    );
  }

  //消息内容布局
  // 根据type判断显示什么布局
  Widget _getContentWidget() {
    if (mBean != null && mBean.type > 0) {
      if (mBean.type == Content.TYPE_TEXT) {
        return _getTextWidget();
      } else if (mBean.type == Content.TYPE_AUDIO) {
        initAudioPlayer();
        return _getAudioWidget();
      }

      return _getEmptyWidget();
    } else {
      return _getEmptyWidget();
    }
  }

  //空布局
  Widget _getEmptyWidget() {
    return new Container(
      child: new FluttieAnimation(emojiComposition),
    );
  }

  //文字布局
  Widget _getTextWidget() {
    return new Expanded(
        child: new Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 26.0),
      decoration: roundCorner,
      child: new Text(
        mBean.content,
        softWrap: true,
        style: new TextStyle(color: textColor),
      ),
    ));
  }

  //音频布局
  //播放及播放动画
  Widget _getAudioWidget() {
    return new GestureDetector(
      child: new Container(
        padding: const EdgeInsets.only(
            left: 8.0, top: 8.0, bottom: 8.0, right: 24.0),
        decoration: roundCorner,
        child: new Row(
          children: <Widget>[
            new Container(
              child: new Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Theme.of(context).primaryColor,
              ),
              padding: const EdgeInsets.only(right: 10.0),
            ),
            new Container(
              padding: const EdgeInsets.only(right: 10.0),
              child: new Text(
                isPlaying
                    ? ((duration?.inSeconds?.toInt() ?? 0) -
                                (position?.inSeconds?.toInt() ?? 0))
                            .toString() +
                        "s"
                    : duration == null
                        ? ""
                        : duration?.inSeconds.toString() + "s",
                style: new TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        return mBean.content == null || mBean.content.length == 0
            ? null
            : (isPlaying ? _stopPlayAudio() : _startPlayAudio());
      },
    );
  }

  //圆角背景修饰
  var roundCorner = new BoxDecoration(
    boxShadow: <BoxShadow>[
      new BoxShadow(
        color: Colors.grey[300],
        offset: new Offset(0.0, 2.0),
        blurRadius: 6.0,
      ),
    ],
    color: Colors.white,
    borderRadius: new BorderRadius.all(
      const Radius.circular(28.0),
    ),
  );

  _startPlayAudio() async {
    debugPrint("Start Play Audio---" + mBean.content);

    int result = await audioPlayer.play(mBean.content);
    if (result == 1) {
      setState(() {
        debugPrint('_AudioAppState.play... PlayerState.playing');
        playerState = PlayerState.playing;
        debugPrint(duration.toString());
      });
    }
  }

  _stopPlayAudio() async {
    debugPrint("Stop Play Audio---" + mBean.content);

    int result = await audioPlayer.stop();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
    }
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    audioPlayer.setDurationHandler((d) => setState(() {
          duration = d;
        }));

    audioPlayer.setPositionHandler((p) => setState(() {
          position = p;
        }));

    audioPlayer.setCompletionHandler(() {
      setState(() {
        playerState = PlayerState.stopped;
        position = duration;
      });
    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });

//    _initLoadingAnimation();
  }

  _initLoadingAnimation() async {
    bool canBeUsed = await Fluttie.isAvailable();
    if (!canBeUsed) {
      print("Animations are not supported on this platform");
      return;
    }
    emojiComposition = await instance.loadAnimationFromResource(
        "assets/voice.json",
        bundle: DefaultAssetBundle.of(context));
    shockedEmoji = await instance.prepareAnimation(emojiComposition,
        duration: const Duration(seconds: 2),
        preferredSize: Fluttie.kDefaultSize,
        repeatCount: const RepeatCount.infinite(),
        repeatMode: RepeatMode.START_OVER);
    if (mounted) {
      setState(() {
        ready = true; // The animations have been loaded, we're ready
        shockedEmoji.start(); //start our looped emoji animation
      });
    }
  }

  bool _isLoginUser() {
    return mBean.uid == Test.LOGIN_UID;
  }
}

//播放状态
enum PlayerState { stopped, playing, paused }
