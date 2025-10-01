import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';

class CommunicationSubMessage extends StatelessWidget {
  const CommunicationSubMessage({super.key, required this.model});

  final CommunicationTileModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  left: 0,
                  child: CircleAvatar(
                    backgroundColor: ConstColors.primary.withValues(alpha: 0.1),
                    radius: 25,
                    backgroundImage: NetworkImage(model.iconUrl),
                  ),
                ),
                // Positioned(
                //     top: 37,
                //     left: 36,
                //     child: Container(
                //         width: 10,
                //         height: 10,
                //         decoration: BoxDecoration(
                //           color: Color.fromRGBO(144, 218, 125, 1),
                //           border: Border.all(
                //             color: Color.fromRGBO(255, 255, 255, 1),
                //             width: 2,
                //           ),
                //           borderRadius:
                //               BorderRadius.all(Radius.elliptical(10, 10)),
                //         ))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    model.dateAdded.isEmpty
                        ? ""
                        : formatDateTime(
                            DateFormat(
                              'dd-MM-yyyy hh:mm:ss a',
                            ).parse(model.dateAdded),
                          ),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color.fromRGBO(114, 134, 233, 1),
                      fontFamily: 'SF Pro Text',
                      fontSize: 13,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1,
                    ),
                  ),
                ),
                Text(
                  model.type,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color.fromRGBO(38, 41, 51, 1),
                    fontSize: 17,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1,
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
                            style: TextStyle(
                              color: model.cnt == 0
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
                    model.cnt == 0
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                              bottom: 15.0,
                              left: 15,
                            ),
                            child: CircleAvatar(
                              radius: 10,
                              child: Text(
                                model.cnt.toString(),
                                style: const TextStyle(fontSize: 10),
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
