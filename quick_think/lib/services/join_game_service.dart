import 'package:flutter/material.dart';
import 'package:quickthink/model/new_question_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quickthink/services/snackbar_service.dart';

enum JoinStatus { Authenticating, Authenticated, Error }

class JoinGameService extends ChangeNotifier {
  List<Question> _questions = [];
  List<Question> get questionList => _questions;

  JoinStatus status;
  final String url = 'http://mohammedadel.pythonanywhere.com/game/play';
  Future<List<Question>> joinGame(code, user) async {
    status = JoinStatus.Authenticating;
    http.Response response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {"game_code": code, "user_name": user},
    );
    if (response.statusCode == 200) {
      status = JoinStatus.Authenticated;

//      SnackBarService.instance.showSnackBarSuccess('Loading Questions');

      String data = response.body;

      List decodedQuestions = jsonDecode(data)['data']['questions'];

      print(decodedQuestions);

      decodedQuestions = decodedQuestions
          .map((questions) => Question.fromJson(questions))
          .toList();

      _questions = decodedQuestions;
      notifyListeners();

     // return decodedQuestions;

      //TODO Navigate to game screen
      ///QuizPage still accepts old parameters. After it's changed to accept new game design navigate to the page

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (o) => QuizPage(
      //               numberOfQuestions: numberOfQuestions,
      //               difficultyLevel: option,
      //               userName: widget.username,
      //             )));

    } else {
      String data = response.body;
      status = JoinStatus.Authenticating;
      SnackBarService.instance.showSnackBarError(jsonDecode(data)['error']);

      return null;
    }
  }
}
