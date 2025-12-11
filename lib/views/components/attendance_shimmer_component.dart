import 'package:flutter/material.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';

class AttendenceShimmerComponent extends StatelessWidget {
  const AttendenceShimmerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      linearGradient: ConstGradient.shimmerGradient,
      child: ShimmerLoading(
        isLoading: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: ConstGradient.shimmerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: ConstGradient.shimmerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: ConstGradient.shimmerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: ConstGradient.shimmerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: ConstGradient.shimmerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: ConstGradient.shimmerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
