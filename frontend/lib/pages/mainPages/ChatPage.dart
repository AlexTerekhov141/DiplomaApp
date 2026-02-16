import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Scaffold(
      body: ResponsiveFrame(
        maxWidth: 900,
        child: Center(child: Text('Chat is coming soon')),
      ),
    );
  }
}
