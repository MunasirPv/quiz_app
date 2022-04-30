import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/model/index_model.dart';
import 'package:quiz_app/model/questions.dart';

class QuizProvider extends ChangeNotifier {
  String _apiURL =
      'https://quizapi.io/api/v1/questions?apiKey=miKa0AK6KcwHjHIFwG6AVZd4fmyOM05lenRRO78f&category=linux&difficulty=Hard&limit=20';

  List<Questions> questionsList = [];

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<IndexModel> indexList = [];

  getQuestions() async {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      isLoading = true;
    });
    var response = await http.get(Uri.parse(_apiURL));
    if (response.statusCode == 200) {
      List responseList = jsonDecode(response.body);
      questionsList = responseList.map((e) => Questions.fromJson(e)).toList();
      selectedAnswers = List.generate(questionsList.length, (index) => '');
      indexList = List.generate(
        questionsList.length,
        (index) => IndexModel(index: index),
      );
      notifyListeners();
    }
    isLoading = false;
  }

  List<String> selectedAnswers = [];

  updatesAnswers({required int index, required String answer}) {
    selectedAnswers.removeAt(index);
    selectedAnswers.insert(index, answer);
    notifyListeners();
  }

  Future<void> submitAnswer() async {
    String correctAnswer = questionsList[selectedIndex].correctAnswer ?? '';
    String userSelected = selectedAnswers[selectedIndex];
    indexList[selectedIndex].isCorrect = correctAnswer == userSelected;
    notifyListeners();
  }

  int getCorrectAnswers() {
    int correctAnswers =
        indexList.where((element) => element.isCorrect).toList().length;
    return correctAnswers;
  }

  clearAll() {
    questionsList.clear();
    indexList.clear();
    selectedAnswers.clear();
    selectedIndex = 0;
    notifyListeners();
  }
}
