import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/inapp.png"), fit: BoxFit.cover, opacity: 0.5,),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const Expanded(
              child: Text("SHARE LOCATION BY MQTT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                   // fontFamily: 'DancingScript',
                    fontSize: 20,
                    // foreground: Paint()
                    //   ..style = PaintingStyle.stroke
                    //   ..strokeWidth = 1
                    //   ..color = Colors.black!,
                    shadows: [
                      Shadow(
                        color: Colors.blue,
                        blurRadius: 10.0,
                        offset: Offset(5.0, 5.0),
                      ),
                      Shadow(
                        color: Colors.red,
                        blurRadius: 10.0,
                        offset: Offset(-5.0, 5.0),
                      ),
                    ],
                  )),
            ),
            Expanded(
              child: Center(
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/icon.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//todo create userfriendly UI
