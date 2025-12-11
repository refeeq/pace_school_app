import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/models/communication_student_model.dart';

class CommunicationMainMessage extends StatelessWidget {
  final CommunicationStudentModel model;

  const CommunicationMainMessage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 25, backgroundImage: NetworkImage(model.photo)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.nunitoSans(
                      textStyle: const TextStyle(
                        color: Color.fromRGBO(114, 134, 233, 1),
                        fontSize: 13,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                Text(
                  model.fullname,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.nunitoSans(
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(38, 41, 51, 1),
                      fontSize: 17,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            model.lastMessage.isEmpty
                                ? ""
                                : model.lastMessage.substring(
                                    0,
                                    model.lastMessage.length > 45
                                        ? 45
                                        : model.lastMessage.length,
                                  ),
                            textAlign: TextAlign.left,
                            style: GoogleFonts.nunitoSans(
                              textStyle: TextStyle(
                                color: model.unread == 0
                                    ? const Color.fromRGBO(138, 142, 155, 1)
                                    : const Color.fromRGBO(114, 134, 233, 1),
                                fontFamily: 'SF Pro Text',
                                fontSize: 15,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(231, 234, 242, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    model.unread == 0
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                              bottom: 15.0,
                              left: 15,
                            ),
                            child: CircleAvatar(
                              radius: 10,
                              child: Text(
                                model.unread.toString(),
                                style: GoogleFonts.nunitoSans(
                                  textStyle: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
