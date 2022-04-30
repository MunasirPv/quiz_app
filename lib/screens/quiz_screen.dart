import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/model/questions.dart';
import 'package:quiz_app/provider/quiz_provider.dart';
import 'package:quiz_app/screens/score_card.dart';

class QuizScreen extends StatelessWidget {
  QuizScreen({Key? key}) : super(key: key);

  final PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    Provider.of<QuizProvider>(context, listen: false).getQuestions();
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 10),
          const IndexIndicator(),
          Expanded(
            child: Consumer<QuizProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!provider.isLoading && provider.questionsList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Questions found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  );
                }
                return PageView.builder(
                  controller: pageController,
                  itemCount: provider.questionsList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => provider.selectedIndex = index,
                  itemBuilder: (context, index) {
                    Questions question =
                        provider.questionsList.elementAt(index);
                    return Card(
                      margin: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Question ${index + 1}/${provider.questionsList.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              question.question.toString(),
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 16,
                              ),
                            ),
                            AnswersWidget(
                              answers: question.answerList ?? [],
                              index: index,
                              provider: provider,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SubmitButton(pageController),
        ],
      ),
    );
  }
}

class AnswersWidget extends StatelessWidget {
  final List<Answers> answers;
  final int index;
  final QuizProvider provider;
  const AnswersWidget(
      {required this.index,
      required this.provider,
      required this.answers,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: answers.map(
        (e) {
          if (e.answer == null) {
            return Container();
          }
          String option = e.title!.split('_').last.toUpperCase();
          String answer = '';
          if (provider.selectedAnswers.length > index) {
            answer = provider.selectedAnswers.elementAt(index);
          }
          bool isSelected = answer == e.title;
          return GestureDetector(
            onTap: () => provider.updatesAnswers(
                index: index, answer: e.title.toString()),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepPurple,
                ),
                borderRadius: BorderRadius.circular(30),
                color: isSelected ? Colors.deepPurple : null,
              ),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 10),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: option + '. ',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: e.answer,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class IndexIndicator extends StatelessWidget {
  const IndexIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(builder: (context, provider, _) {
      if (provider.isLoading || provider.questionsList.isEmpty) {
        return Container();
      }
      return SizedBox(
        height: 50,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            Widget widget = Text(
              (provider.indexList[index].index + 1).toString(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            );
            if (index < provider.selectedIndex) {
              widget = provider.indexList[index].isCorrect
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.close,
                      color: Colors.red,
                    );
            }
            if (index == provider.selectedIndex) {
              widget = Text(
                (provider.indexList[index].index + 1).toString(),
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            bool isCurrentIndex = index == provider.selectedIndex;
            return Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                shape: BoxShape.circle,
                color: isCurrentIndex ? Colors.white : null,
              ),
              alignment: Alignment.center,
              child: widget,
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 10);
          },
          itemCount: provider.indexList.length,
        ),
      );
    });
  }
}

class SubmitButton extends StatelessWidget {
  final PageController pageController;
  const SubmitButton(this.pageController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(builder: (context, provider, _) {
      if (provider.isLoading || provider.questionsList.isEmpty) {
        return Container();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
        child: ElevatedButton(
          onPressed: () async {
            if (provider.selectedAnswers[provider.selectedIndex].isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select answer'),
                ),
              );
            } else {
              await provider.submitAnswer();
              if (provider.questionsList.length == provider.selectedIndex + 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScoreCard()),
                );
              } else {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeIn,
                );
              }
            }
          },
          child: const Text('Submit'),
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 15,
            ),
          ),
        ),
      );
    });
  }
}
