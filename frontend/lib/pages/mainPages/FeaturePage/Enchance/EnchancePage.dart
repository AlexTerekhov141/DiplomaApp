import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import '../../../../models/EnchanceModel.dart';
import 'Widgets/EnchanceView.dart';


@RoutePage()
class EnhancePage extends StatefulWidget {
  const EnhancePage({super.key});

  @override
  State<EnhancePage> createState() => _EnhancePageState();
}

class _EnhancePageState extends State<EnhancePage>
    with AutomaticKeepAliveClientMixin {
  EnhanceModel _model = EnhanceModel.empty();

  @override
  bool get wantKeepAlive => true;

  void _updateDraft(EnhanceModel value) {
    setState(() {
      _model = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: EnhanceView(
        model: _model,
        onDraftChanged: _updateDraft,
      ),
    );
  }
}