import 'package:flutter/material.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';

class ShimmerContainer extends StatelessWidget {
  final String text;
  final double radius;
  final double height;
  const ShimmerContainer({
    super.key,
    required this.height,
    required this.radius,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'SourceSansPro',
              fontWeight: FontWeight.normal,
            ),
          ),
          Container(
            height: height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: ConstGradient.shimmerGradient,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ],
      ),
    );
  }
}
