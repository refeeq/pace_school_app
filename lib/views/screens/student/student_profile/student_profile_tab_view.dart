import 'package:flutter/material.dart';
import 'package:school_app/core/models/student_detail_model.dart';
import 'package:school_app/views/components/basic_details_widget.dart';
import 'package:school_app/views/components/document_details_widget.dart';

import '../../../components/contact_details_widget.dart';

class StudentProfileTabView extends StatefulWidget {
  final StudentDetailModel studentDetailModel;
  const StudentProfileTabView({super.key, required this.studentDetailModel});

  @override
  StudentProfileTabViewState createState() => StudentProfileTabViewState();
}

class StudentProfileTabViewState extends State<StudentProfileTabView> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      //   mainAxisSize: MainAxisSize.min,
      children: [
        BasicDetailWidget(),
        ContactDetailsWidget(),
        DocumentDetailWidget(),
      ],
    );
  }
}
