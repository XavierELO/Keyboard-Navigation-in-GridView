import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Xavier Keyboard Navigation in GridView'),
        ),
        body: MyGridView(),
      ),
    );
  }
}

class MyGridView extends StatefulWidget {
  @override
  _MyGridViewState createState() => _MyGridViewState();
}

class _MyGridViewState extends State<MyGridView> {
  int _crossAxisCount = 5;
  int _focusedIndex = 0;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes =
        List.generate(50, (index) => FocusNode(onKey: _handleKeyEvent));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[_focusedIndex].requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      int newIndex = _focusedIndex;
      int numRows = (_focusNodes.length / _crossAxisCount).ceil();
      int currentRow = _focusedIndex ~/ _crossAxisCount;
      int currentColumn = _focusedIndex % _crossAxisCount;

      if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          currentRow < numRows - 1) {
        newIndex += _crossAxisCount;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          currentRow > 0) {
        newIndex -= _crossAxisCount;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          currentColumn > 0) {
        newIndex -= 1;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          currentColumn < _crossAxisCount - 1) {
        newIndex += 1;
      }

      if (newIndex >= 0 && newIndex < _focusNodes.length) {
        setState(() {
          _focusNodes[_focusedIndex].unfocus();
          _focusedIndex = newIndex;
          _focusNodes[_focusedIndex].requestFocus();
        });
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 50,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
      ),
      itemBuilder: (context, index) {
        return Focus(
          focusNode: _focusNodes[index],
          child: Container(
            alignment: Alignment.center,
            color: _focusNodes[index].hasPrimaryFocus
                ? Colors.blue[(index % 9 + 1) * 100]
                : Colors.grey,
            child: Text('$index'),
          ),
        );
      },
    );
  }
}
