import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.blue), // 암시적 애니메이션?
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// 앱의 상태 정의?
// ChangeNotifier가 앱 상태 관리하는 가장 쉬운 방법이래
// MyAppState: 앱에 필요한 데이터 정의, 리액트의 useState같은 훅 개념인듯
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<
        MyAppState>(); // watch: 변경사항 추적. react-hook-form이랑 비슷. hook 개념으로 보면될듯
    var pair = appState.current;

    return Scaffold(
      body: Center( // wrap with center 사용
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // column 중앙 배치
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10), // 패딩 용도
            ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('new words'))
          ],
        ),
      ),
    );
  }
}

// 와 refactor 기능쓰면 이거 알아서 만들어줌
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith( // 글꼴테마에 접근
      color: theme.colorScheme.onPrimary,
      backgroundColor: theme.colorScheme.outline,
    );

    return Card(
      // wrap with widget 이용
      color: theme.colorScheme.primary,
      child: Padding(
        // wrap with padding 이용
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
