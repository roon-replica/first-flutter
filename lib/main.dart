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

// 여기가 비즈니스 로직 처리하는 부분?
// 앱의 상태 정의?
// ChangeNotifier가 앱 상태 관리하는 가장 쉬운 방법이래
// MyAppState: 앱에 필요한 데이터 정의, 리액트의 useState같은 훅 개념인듯
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // 비즈니스 로직 추가: 좋아요?
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}


// 여기가 UI 처리하는 부분
// StatefulWidget으로 변경 - Convert to StatefulWidget 이용
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // selectedIndex에 따라 페이지 렌더링!
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = GeneratorPage2();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder( // wrap with builder 사용, Nav Rail의 label 표시 여부를 화면 크기에 따라 자동으로 결정할 수 있도록
        builder: (context, constraints) {
          return Scaffold(
              body: Row(
                children: [
                  SafeArea(
                    child: NavigationRail( // = 사이드 바
                      extended: constraints.maxWidth >= 600,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite),
                          label: Text('Favorites'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() { // 리액트랑 비슷하네
                          selectedIndex = value;
                        });

                        print('selected: $value');
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primaryContainer,
                      child: page, // selectedIndex에 따라 다른 페이지 렌더링
                    ),
                  ),
                ],
              )
          );
        }
    );
  }
}

// MyHomePage 내용이 여기로 추출됨
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GeneratorPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    print(appState.favorites);

    // 이런식으로도 됨
    // var items = appState.favorites;
    // return ListView.builder(
    //   itemCount: items.length,
    //   itemBuilder: (context, index) {
    //     return BigCard(pair: items[index]);
    //   },
    // );


    if (appState.favorites.isEmpty) { // 예외 처리
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
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
