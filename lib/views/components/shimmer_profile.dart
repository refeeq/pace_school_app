import 'package:flutter/material.dart';
import 'package:school_app/views/components/shimmer_container.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';

class ShimmerParnetProfile extends StatelessWidget {
  const ShimmerParnetProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          shrinkWrap: true,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                  isLoading: true,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 28,
                  ),
                ),
                SizedBox(width: 10),
                ShimmerLoading(
                  isLoading: true,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 28,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            ShimmerContainer(text: "", height: 400, radius: 5),
          ],
        ),
      ),
    );
  }
}

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(18.0),
      child: Column(
        children: [
          ShimmerContainer(text: '', height: 70, radius: 10),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ShimmerContainer(
                  text: "Student Admission No",
                  height: 30,
                  radius: 5,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: ShimmerContainer(text: "Gender", height: 30, radius: 5),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ShimmerContainer(text: "Class", height: 30, radius: 5),
              ),
              SizedBox(width: 15),
              Expanded(
                child: ShimmerContainer(
                  text: "Date of Birth",
                  height: 30,
                  radius: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ShimmerContainer(
                  text: "Date of Admission",
                  height: 30,
                  radius: 5,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: ShimmerContainer(
                  text: "Nationality",
                  height: 30,
                  radius: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          ShimmerContainer(text: "Passport No", height: 30, radius: 5),
          SizedBox(height: 5),
          ShimmerContainer(text: "Parent Email", height: 30, radius: 5),
          SizedBox(height: 5),
          ShimmerContainer(text: "Gender", height: 30, radius: 5),
        ],
      ),
    );
  }
}
