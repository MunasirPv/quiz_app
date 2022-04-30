class Questions {
  int? id;
  String? question;
  Answers? answers;
  String? multipleCorrectAnswers;
  CorrectAnswers? correctAnswers;
  String? correctAnswer;
  List<Answers>? answerList;

  Questions({
    this.id,
    this.question,
    this.answers,
    this.multipleCorrectAnswers,
    this.correctAnswers,
    this.correctAnswer,
  });

  Questions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    // answers =
    //     json['answers'] != null ? Answers.fromJson(json['answers']) : null;
    if (json['answers'] != null) {
      Map<String, dynamic> answerJson = json['answers'];
      answerList = answerJson.entries
          .map((e) => Answers.fromJson(e.key, e.value))
          .toList();
    }
    multipleCorrectAnswers = json['multiple_correct_answers'];
    correctAnswers = json['correct_answers'] != null
        ? CorrectAnswers.fromJson(json['correct_answers'])
        : null;
    correctAnswer = json['correct_answer'];
  }
}

class Answers {
  String? title;
  String? answer;
  String? answerA;
  String? answerB;
  String? answerC;
  String? answerD;
  String? answerE;
  String? answerF;

  Answers(
      {this.answerA,
      this.answerB,
      this.answerC,
      this.answerD,
      this.answerE,
      this.answerF});

  Answers.fromJson(this.title, this.answer);

  // Answers.fromJson(Map<String, dynamic> json) {
  //   answerA = json['answer_a'];
  //   answerB = json['answer_b'];
  //   answerC = json['answer_c'];
  //   answerD = json['answer_d'];
  //   answerE = json['answer_e'];
  //   answerF = json['answer_f'];
  // }
}

class CorrectAnswers {
  String? answerACorrect;
  String? answerBCorrect;
  String? answerCCorrect;
  String? answerDCorrect;
  String? answerECorrect;
  String? answerFCorrect;

  CorrectAnswers(
      {this.answerACorrect,
      this.answerBCorrect,
      this.answerCCorrect,
      this.answerDCorrect,
      this.answerECorrect,
      this.answerFCorrect});

  CorrectAnswers.fromJson(Map<String, dynamic> json) {
    answerACorrect = json['answer_a_correct'];
    answerBCorrect = json['answer_b_correct'];
    answerCCorrect = json['answer_c_correct'];
    answerDCorrect = json['answer_d_correct'];
    answerECorrect = json['answer_e_correct'];
    answerFCorrect = json['answer_f_correct'];
  }
}
