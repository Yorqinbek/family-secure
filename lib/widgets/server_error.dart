import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServerErrorWidget extends StatefulWidget {
  const ServerErrorWidget({super.key});

  @override
  State<ServerErrorWidget> createState() => _ServerErrorWidgetState();
}

class _ServerErrorWidgetState extends State<ServerErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Text(AppLocalizations.of(context)!.server_error,style: TextStyle(fontSize: 16),),
    );
  }
}
