import 'package:agora_app/video_call.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with _MixinHomePage{
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Form(
          key: _globalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _controller,
                validator: (v) {
                  return !v!.contains('test') ? 'Not found Channel' : null ;
                } ,
                decoration: const InputDecoration(
                  labelText: 'Enter your Code'
                ),
              ),

              MaterialButton(
                minWidth: double.infinity,
                onPressed: () async {
                  if(_globalKey.currentState!.validate()){
                    if(await Permission.microphone.request().isGranted
                        &&
                        await Permission.camera.request().isGranted){

                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context)=>VideoCallPage(
                            channel: _controller.text ,
                            role: ClientRole.Broadcaster ,
                          )));

                  } else {
                      if(await Permission.microphone.request().isGranted
                          &&
                          await Permission.camera.request().isGranted){

                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context)=>VideoCallPage(
                              channel: _controller.text ,
                              role: ClientRole.Broadcaster ,
                            )));

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You Must Agree the Permissions')));
                      }
                    }
                  }
                }, child: const Text('Enter',
                style: TextStyle(fontSize: 24.0,color: Colors.white),
              ),
                color: Theme.of(context).primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}

mixin _MixinHomePage {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
}