import 'package:school_app/views/screens/open_house/model/slot_model.dart';

class TeacherModel {
  final int empId;
  final String empName;
  final String photo;
  final String subjects;
  final List<SlotDetail> slotDetails;

  TeacherModel({
    required this.empId,
    required this.empName,
    required this.slotDetails,
    required this.photo,
    required this.subjects,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
    empId: json["emp_id"],
    empName: json["empName"],
    slotDetails: List<SlotDetail>.from(
      json["slotDetails"].map((x) => SlotDetail.fromJson(x)),
    ),
    photo: json['empPhoto'],
    subjects: json['subjects'],
  );

  Map<String, dynamic> toJson() => {
    "emp_id": empId,
    "empName": empName,
    "slotDetails": List<dynamic>.from(slotDetails.map((x) => x.toJson())),
  };
}
