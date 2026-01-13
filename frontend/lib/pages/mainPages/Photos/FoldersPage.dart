import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      onPressed: (){},
                      child: const Row(
                          children: <Widget>[
                            Icon(Icons.favorite),
                            SizedBox(width: 4),
                            Text('Favourite')
                          ]
                      )
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                      onPressed: (){},
                      child: const Row(
                          children: <Widget>[
                            Icon(Icons.delete),
                            SizedBox(width: 4),
                            Text('Trash')
                          ]
                      )
                  )
                ],
              ),
          )
        )
      ),
    );
  }

}