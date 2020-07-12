import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:quickthink/model/new_questions_model.dart';
import 'package:quickthink/screens/create_game.dart';
import 'package:quickthink/screens/dashboard.dart';
import 'package:quickthink/screens/quiz_page.dart';
import 'package:quickthink/utils/responsiveness.dart';
import 'package:http/http.dart' as http;
import 'package:quickthink/widgets/no_internet.dart';

const String url = 'http://mohammedadel.pythonanywhere.com/game/play';

class JoinGame extends StatefulWidget {
  @override
  _JoinGameState createState() => _JoinGameState();
}

class _JoinGameState extends State<JoinGame> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  bool _connection = false;

  String username = '';
  String gameCode = '';

  final _formKey = GlobalKey<FormState>();

  ProgressDialog progressDialog;

  @override
  void initState() {
    connectivity = new Connectivity();
    subscription = connectivity.onConnectivityChanged.listen(
      (ConnectivityResult connectivityResult) {
        _connectionStatus = connectivityResult.toString();
        print(_connectionStatus);

        if (connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile) {
          setState(() {
            if (!mounted) return;
            startTime();
            _connection = false;
          });
        } else {
          setState(() {
            if (!mounted) return;
            _connection = true;
          });
        }
      },
    );
    super.initState();
  }

  startTime() async {
    return new Timer(
      Duration(milliseconds: 500),
      () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => JoinGame()));
      },
    );
  }

  void _showInSnackBar(String value, color) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      backgroundColor: color,
      duration: new Duration(seconds: 3),
    ));
  }

  // void _showToast(String value, color) {
  //   _scaffoldKey.currentState.showSnackBar(new SnackBar(
  //     content: new Text(value),
  //     backgroundColor: color,
  //     duration: new Duration(seconds: 3),
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);

    progressDialog.style(
      message: 'Joining Game',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitThreeBounce(color: Color(0xFF18C5D9), size: 25),
      elevation: 10.0,
      insetAnimCurve: Curves.easeOut,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    return _connection
        ? NoInternet()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Theme.of(context).primaryColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _logoText(),
                    SizedBox(
                      height: SizeConfig().yMargin(context, 10),
                    ),
                    _prompt(),
                    _form(),
                    _loginBtn(),
                    _or(),
                    _createGameLink(),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _or() {
    return Padding(
      padding: EdgeInsets.only(
        top: SizeConfig().xMargin(context, 10.0),
        //right: SizeConfig().xMargin(context, 3.0),
      ),
      child: Text(
        'or',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
          fontSize: SizeConfig().textSize(context, 3),
        ),
      ),
    );
  }

  Widget _createGameLink() {
    return Padding(
      padding: EdgeInsets.only(
        top: SizeConfig().xMargin(context, 6.0),
        //right: SizeConfig().xMargin(context, 3.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateGame()));
        },
        child: Text('Create a game',
            style: GoogleFonts.poppins(
              fontSize: SizeConfig().textSize(context, 3),
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            )),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: SizeConfig().yMargin(context, 3.0),
          ),
          _quizCode(),
          SizedBox(
            height: SizeConfig().yMargin(context, 4),
          ),
          _username(),
          SizedBox(
            height: SizeConfig().yMargin(context, 7),
          ),
        ],
      ),
    );
  }

  Widget _prompt() {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig().xMargin(context, 5.0),
        right: SizeConfig().xMargin(context, 3.0),
      ),
      child: Text(
        'Enter invite code to join the game',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: SizeConfig().textSize(context, 3.7),
        ),
      ),
    );
  }

  Widget _logoText() {
    return RichText(
      text: TextSpan(children: <TextSpan>[
        TextSpan(
            text: 'Quick',
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: SizeConfig().textSize(context, 3),
                color: Colors.white)),
        TextSpan(
            text: 'Think',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
              fontSize: SizeConfig().textSize(context, 3),
              color: Color.fromRGBO(24, 197, 217, 1),
            ))
      ]),
    );
  }

  Widget _username() {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig().xMargin(context, 5.0),
        right: SizeConfig().xMargin(context, 3.0),
      ),
      child: TextFormField(
        style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig().textSize(context, 3),
            color: Colors.white),
        onChanged: (val) {},
        validator: (val) {
          if (val.length == 0) {
            return 'Username Should Not Be Empty';
          }
          if (val.length <= 2) {
            return 'should be 3 or more characters';
          }
          if (!RegExp(r"^[a-z0-9A-Z_-]{3,16}$").hasMatch(val)) {
            return "can only include _ or -";
          }
          return null;
        },
        onSaved: (val) => username = val,
        decoration: InputDecoration(
          hintText: 'Enter Username',
          hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: SizeConfig().textSize(context, 2),
              color: Colors.white),
          contentPadding: EdgeInsets.fromLTRB(14.0, 12.0, 0.0, 12.0),
          fillColor: Color.fromRGBO(87, 78, 118, 1),
          filled: true,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromRGBO(24, 197, 217, 1), width: 1.0),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  Widget _quizCode() {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig().xMargin(context, 5.0),
        right: SizeConfig().xMargin(context, 3.0),
      ),
      child: TextFormField(
        keyboardType: TextInputType.number,
        style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig().textSize(context, 3),
            color: Colors.white),
        onChanged: (val) {},
        validator: (val) {
          if (val.length == 0) {
            return 'Quiz Code Should Not Be Empty';
          }
          if (val.length <= 2) {
            return 'should be 3 or more characters';
          }
          return null;
        },
        onSaved: (val) => gameCode = val,
        decoration: InputDecoration(
          hintText: 'Enter Game Code',
          hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: SizeConfig().textSize(context, 2),
              color: Colors.white),
          contentPadding: EdgeInsets.fromLTRB(14.0, 12.0, 0.0, 12.0),
          fillColor: Color.fromRGBO(87, 78, 118, 1),
          filled: true,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromRGBO(24, 197, 217, 1), width: 1.0),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  Widget _loginBtn() {
    return RaisedButton(
      padding: EdgeInsets.fromLTRB(70, 20, 70, 20),
      onPressed: () {
        print('URL: $url');
        onPressed();
      },
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      color: Color.fromRGBO(24, 197, 217, 1),
      highlightColor: Color.fromRGBO(24, 197, 217, 1),
      child: Text('Join Game',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              color: Colors.white)),
    );
  }

  void onPressed() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _joinGame(gameCode, username);
      //    handleRegistration(nick, password);
    }
  }

  Future<List<Question>> _joinGame(code, user) async {
    setState(() {
      progressDialog.show();
    });
    // url = Constants().urlJoinGame;
    http.Response response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {"game_code": code, "user_name": user},
    );
    if (response.statusCode == 200) {
      String data = response.body;
      List decodedQuestions = jsonDecode(data)['data']['questions'];

      print(decodedQuestions);
      setState(() {
        progressDialog.hide();
      });
      _showInSnackBar('Game Coming Soon', Colors.green);
      return decodedQuestions
          .map((questions) => Question.fromJson(questions))
          .toList();
    } else {
      String data = response.body;
      setState(() {
        progressDialog.hide();
      });
      _showInSnackBar(jsonDecode(data)['error'], Colors.red);
    }
    return null;
  }
}
