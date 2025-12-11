import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/themes/const_box_decoration.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';

class ParentSettingsScreenView extends StatefulWidget {
  const ParentSettingsScreenView({super.key});

  @override
  State<ParentSettingsScreenView> createState() =>
      _ParentSettingsScreenViewState();
}

class _ParentSettingsScreenViewState extends State<ParentSettingsScreenView> {
  bool? switchListTileValue1;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Settings"),
        ),
        body: Container(
          decoration: ConstBoxDecoration.whiteDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ValueListenableBuilder(
                valueListenable: Hive.box("notification").listenable(),
                builder: (context, box, widget) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child: SwitchListTile.adaptive(
                      value: box.get("notification"),
                      onChanged: (newValue) async {
                        await Hive.box(
                          'notification',
                        ).put("notification", newValue);
                      },
                      title: Text(
                        'Push Notifications',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      activeThumbColor: ConstColors.primary,
                      activeTrackColor: ConstColors.primary.withValues(
                        alpha: 0.5,
                      ),
                      dense: false,
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(
                        24,
                        12,
                        24,
                        12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
