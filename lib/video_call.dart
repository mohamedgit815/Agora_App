// ignore_for_file: library_prefixes
import 'package:agora_app/conditional_builder.dart';
import 'package:agora_app/custom_snack_bar.dart';
import 'package:agora_app/main.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;


class VideoCallPage extends ConsumerStatefulWidget {
  final ClientRole role;
  final String channel;
  const VideoCallPage({Key? key,required this.role,required this.channel}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends ConsumerState<VideoCallPage> with _MixinVideoCall {
  @override
  void initState() {
    super.initState();
      _initAgora(role: widget.role, channel: widget.channel,ref: ref,context: context);
  }

  @override
  void dispose() {
    super.dispose();
    _clearDataDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text(users.length.toString()),),
      body: Stack(

        alignment: Alignment.bottomCenter ,

        children: [

          _agoraViews( widget.role , ref ) ,


          Consumer(
            builder:(context,prov,_)=> Visibility(
                visible: !prov.watch(_showDataProv).switchMute,
                child: _informationDataUser()),
          ) ,


          _toolBar( role: widget.role , context: context ) ,

        ],
      ),
    );
  }
}


mixin _MixinVideoCall {
  final _dataProv = ChangeNotifierProvider<VideoCallState>((ref)=>VideoCallState());
  final _voiceProv = ChangeNotifierProvider<VideoCallState>((ref)=>VideoCallState());
  final _showDataProv = ChangeNotifierProvider<VideoCallState>((ref)=>VideoCallState());
  late final RtcEngine _engine;

  Future<void> _initAgora({
    required ClientRole role,
    required String channel ,
    required WidgetRef ref ,
    required BuildContext context
  }) async {
    try {
      _engine = await RtcEngine.create(appId);
      await _engine.enableVideo();
      await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
      await _engine.setClientRole(role);
      await _engine.joinChannel(token, channel, null, 0);
      _engine.setEventHandler(ref.read(_dataProv).evenHandler(context));
    }on PlatformException catch(e){
      return;
    }
  }

  Future<void> _clearDataDispose() async {
    try {
      await _engine.destroy();
      await _engine.leaveChannel();
      await _engine.clearVideoWatermarks();
      await _engine.disableVideo();
      await _engine.disableAudio();
      await _engine.disableLastmileTest();
    }on PlatformException catch(e){
      return;
    }
  }

  List<Widget> _renderViews(ClientRole role,WidgetRef ref){
    final List<StatefulWidget> _list = <StatefulWidget>[];

    if(role == ClientRole.Broadcaster){
      _list.add(RtcLocalView.SurfaceView());
    }

    ref.watch(_dataProv).users.map((e) => _list.add(RtcRemoteView.SurfaceView(uid: e,))).toList();

    return _list;
  }

  Widget _agoraViews(ClientRole role,WidgetRef ref){
    final List<Widget> _views = _renderViews(role,ref);
    switch(_views.length){
      case 1 :
        return Column(
          children: [
            Expanded(child: _views[0])
          ],
        );

      case 2 :
        return Column(
          children: [
            Expanded(child: _views[1]),
            Expanded(child: _views[0]),
          ],
        );

      case 3 :
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: _views[1]
                  ),
                  Expanded(
                      flex: 1,
                      child: _views[2]
                  )
                ],
              ),
            ),

            Expanded(
                flex: 1,
                child: _views[0])
          ],
        );

      case 4 :
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: _views[3]
                  ),
                  Expanded(
                      flex: 1,
                      child: _views[2]
                  )
                ],
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: _views[1]
                  ),
                  Expanded(
                      flex: 1,
                      child: _views[0]
                  )
                ],
              ),
            ),
          ],
        );

      default: return Container(color: Colors.red,);
    }

  }

  Consumer _informationDataUser(){
    return Consumer(
      builder:(context,prov,_) {
        final List<String> _data = prov.watch(_dataProv).infoListUsers;
        return LayoutBuilder(
          builder:(context , constraints) => SizedBox(
            height: constraints.maxHeight * 0.4,
            width: double.infinity ,
            child: ListView.builder(
              itemCount: _data.length ,
              itemBuilder: ( BuildContext context , int i ) {

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _data.elementAt(i) ,
                    style: const TextStyle(
                      fontSize: 15.0 ,
                      color: Colors.white
                    ),
                  ),
                );
              }),
          ),
        );
      },
    );
  }

  Widget _toolBar({required ClientRole role,required BuildContext context}){
    return Visibility(
        visible: role == ClientRole.Audience ? false : true,
        child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Consumer(
                builder:(context,prov,_)=> RawMaterialButton(
                  child: Icon(
                    prov.watch(_voiceProv).switchMute ? Icons.mic_off : Icons.mic,
                    color: prov.read(_voiceProv).switchMute ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  onPressed: (){
                    prov.read(_voiceProv).muteSwitch();
                    _engine.muteLocalAudioStream(prov.read(_voiceProv).switchMute);
                  },
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: prov.read(_voiceProv).switchMute ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: (){
                  _engine.switchCamera();
                },
                child: const Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              Consumer(
                builder:(context,prov,_)=> RawMaterialButton(
                  onPressed: () async {
                    prov.read(_showDataProv).muteSwitch();
                  },
                  child: AnimatedConditionalBuilder(
                    duration: const Duration(milliseconds: 200),
                    condition: prov.watch(_showDataProv).switchMute,
                    builder: (BuildContext context)=>const Icon(
                      Icons.visibility,
                      color: Colors.blueAccent,
                      size: 20.0,
                    ),
                    fallback: (context)=>const Icon(
                      Icons.visibility_off,
                      color: Colors.blueAccent,
                      size: 20.0,
                    ),

                  ) ,
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class VideoCallState extends ChangeNotifier {
  bool switchMute = false;
  final List<int> users = <int>[];
  final List<String> infoListUsers = <String>[];


  RtcEngineEventHandler evenHandler(BuildContext context){
    notifyListeners();
    return RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid ,int elapsed){
        final String _info = 'onJoinChannel: $channel , uid: $uid';
        infoListUsers.add(_info);
        notifyListeners();
      },
      userJoined: (int uid, int elapsed){
        customSnackBar(text: '$uid Join a Channel', context: context);

        final String _info = 'UserJoined: $uid';

        infoListUsers.add(_info);

        users.add(uid);
        notifyListeners();
      },
      userOffline: (int uid, UserOfflineReason reason){
        final String _info = 'UserOffline: $uid';

        infoListUsers.add(_info);

        customSnackBar(text: '$uid Offline', context: context);

        users.remove(uid);
        notifyListeners();
      },
      leaveChannel: ( state ){
        infoListUsers.add('OnLeaveChannel');
        users.clear();
        notifyListeners();
      },
      rejoinChannelSuccess: (String channel, int uid ,int elapsed){
        final String _info = 'RejoinChannelSuccess: $channel , uid: $uid';

        infoListUsers.add(_info);

        notifyListeners();
      },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {
          final String _info = 'FirstRemoteVideo: $uid ${width}x $height';

          infoListUsers.add(_info);

          notifyListeners();
      });
  }

  bool muteSwitch() {
    notifyListeners();
    return switchMute = !switchMute;
  }
}