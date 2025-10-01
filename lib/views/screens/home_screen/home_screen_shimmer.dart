import 'package:flutter/material.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';

class HomeShimmerView extends StatelessWidget {
  const HomeShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size(
            double.infinity,
            MediaQuery.of(context).size.height * 0.1,
          ),
          child: SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: ShimmerLoading(
                    isLoading: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const ShimmerLoading(
                  isLoading: true,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 28,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/icons/mother.png'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(40),
                //   topRight: Radius.circular(40),
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: ShimmerLoading(
                          isLoading: true,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const SizedBox(height: 15),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GridView.builder(
                          primary: false,
                          shrinkWrap: true,
                          // primary: false,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
