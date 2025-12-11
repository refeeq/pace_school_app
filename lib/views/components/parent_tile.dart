import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/models/parent_model.dart';

import '../../app.dart';

class ParentTile extends StatelessWidget {
  final GlobalKey<ScaffoldState> fkey;
  final int type;

  final ParentModel parentModel;
  final bool isSlect;
  const ParentTile({
    super.key,
    this.isSlect = false,
    required this.parentModel,
    required this.type,
    required this.fkey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            //                    <--- top side
            color: Colors.white,
            width: 0.08,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (fkey.currentState!.isDrawerOpen == false) {
                  fkey.currentState!.openDrawer();
                } else {
                  fkey.currentState!.openEndDrawer();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/Icons/menus.png",
                  height: 28,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FittedBox(
                    child: Text(
                      AppEnivrornment.appFullName,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.nunitoSans(
                        textStyle: Theme.of(context).textTheme.titleLarge!
                            .apply(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontWeightDelta: 2,
                              fontFamily: 'SourceSansPro',
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(AppEnivrornment.appImageName),
            ),
          ],
        ),
      ),
    );
  }
}
