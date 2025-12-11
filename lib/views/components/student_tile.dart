// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:school_app/core/constants/db_constants.dart';
// import 'package:school_app/core/models/students_model.dart';
// import 'package:school_app/core/themes/const_colors.dart';

// class StudentTile extends StatelessWidget {
//   const StudentTile({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: Hive.box<StudentModel>(STUDENTDB).listenable(),
//       builder: (context, value, child) {
//         if (value.isEmpty) {
//           return const SizedBox();
//         } else {
//           log("data${value.values}");
//           // return Consumer<TileExpanderProvider>(
//           //   builder: (context, provider, child) => Padding(
//           //     padding: const EdgeInsets.all(8.0),
//           //     child: Container(
//           //       decoration: BoxDecoration(
//           //           borderRadius: BorderRadius.circular(15),
//           //           color:
//           //               provider.isExpand ? Colors.white : Colors.transparent),
//           //       child: Row(children: [
//           //         provider.isExpand
//           //             ? Row(
//           //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //               children: [
//           //                 SizedBox(
//           //                   width: 5,
//           //                 ),
//           //                 Text(
//           //                   value.get('current')!.studcode +
//           //                       " - " +
//           //                       value.get('current')!.fullname,
//           //                   style: TextStyle(
//           //                     color: ConstColors.primary,
//           //                   ),
//           //                 ),
//           //                 SizedBox(
//           //                   width: 5,
//           //                 ),
//           //               ],
//           //             )
//           //             : const SizedBox(),
//           //         GestureDetector(
//           //           onTap: () => provider.updateExpand(),
//           //           child: CircleAvatar(
//           //             backgroundImage:
//           //                 NetworkImage(value.get('current')!.photo),
//           //           ),
//           //         ),
//           //       ]),
//           //     ),
//           //   ),
//           // );
//           return Theme(
//             data: Theme.of(context).copyWith(
//               cardColor: ConstColors.primary,
//             ),
//             child: PopupMenuButton(
//               shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(15.0))),
//               // add icon, by default "3 dot" icon
//               // icon: Icon(Icons.book)
//               iconSize: 40,
//               icon: CircleAvatar(
//                 backgroundImage: NetworkImage(value.get('current')!.photo),
//               ),
//               itemBuilder: (context) {
//                 return [
//                   // PopupMenuItem<int>(
//                   //   value: 2,
//                   //   child: Center(
//                   //     child: CircleAvatar(
//                   //       backgroundImage:
//                   //           NetworkImage(value.get('current')!.photo),
//                   //     ),
//                   //   ),
//                   // ),
//                   PopupMenuItem<int>(
//                     value: 0,
//                     height: 20,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           value.get('current')!.studcode +
//                               " - " +
//                               value.get('current')!.fullname,
//                           style: TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         CircleAvatar(
//                           backgroundImage:
//                               NetworkImage(value.get('current')!.photo),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ];
//               },
//             ),
//           );

//           // GestureDetector(
//           //     onTap: () {
//           //       Navigator.push(
//           //           context,
//           //           MaterialPageRoute(
//           //             builder: (context) => ChooseStudent(type: type),
//           //           ));
//           //     },
//           //     child: Padding(
//           //       padding: const EdgeInsets.only(
//           //         top: 10.0,
//           //         bottom: 10.0,
//           //         left: 8.0,
//           //         right: 8.0,
//           //       ),
//           //       child: Container(
//           //         decoration: BoxDecoration(
//           //           color: Colors.white,
//           //           borderRadius: BorderRadius.circular(6),
//           //         ),
//           //         child: Padding(
//           //           padding: const EdgeInsets.all(8.0),
//           //           child: CircleAvatar(
//           //             radius: 13,
//           //             backgroundImage:
//           //                 NetworkImage(value.get('current')!.photo),
//           //           ),
//           //         ),
//           //       ),
//           //     ));
//         }
//       },
//     );
//   }
// }

// class TileExpanderProvider with ChangeNotifier {
//   bool isExpand = false;
//   updateExpand() {
//     isExpand = !isExpand;
//     notifyListeners();
//   }
// }
