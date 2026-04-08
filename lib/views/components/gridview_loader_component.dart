import 'package:flutter/material.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';

class GridLoaderComponent extends StatelessWidget {
  const GridLoaderComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GridView.builder(
        primary: false,
        shrinkWrap: true,
        // primary: false,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 3.5,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 6,
        itemBuilder: (BuildContext ctx, index) {
          return ShimmerLoading(
            isLoading: true,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}
