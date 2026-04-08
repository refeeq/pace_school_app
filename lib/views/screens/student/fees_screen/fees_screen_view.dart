import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/payment_button.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/family_fee/cubit/family_fee_cubit.dart';
import 'package:school_app/views/screens/family_fee/pages/family_fee_screen.dart';
import 'package:school_app/views/screens/payment/pages/payement_page.dart';

import '../../../../core/provider/student_provider.dart';
import '../../../components/fee_tile_view.dart';
import '../../../components/shimmer_student_profile.dart';

class FeeScreenView extends StatefulWidget {
  const FeeScreenView({super.key});

  @override
  State<FeeScreenView> createState() => _FeeScreenViewState();
}

class _FeeScreenViewState extends State<FeeScreenView> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "",
      child: Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: CommonAppBar(
          title: "Fees",
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  BlocProvider.of<FamilyFeeCubit>(context).fetchfee();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FamilyFeeScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18.0,
                      left: 18,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Text(
                      "Family Fee",
                      style: GoogleFonts.nunitoSans(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SelectStudentWidget(
              onchanged: (index) {
                getStudentFeeProvider();
              },
            ),
            Expanded(
              child: Consumer<StudentFeeProvider>(
                builder: (context, value, child) {
                  switch (value.feeListState) {
                    case AppStates.Unintialized:
                      Future(
                        () => value.getStudentFee(
                          studentId: Provider.of<StudentProvider>(
                            context,
                            listen: false,
                          ).selectedStudentModel(context).studcode,
                        ),
                      );
                      return Shimmer(
                        linearGradient: ConstGradient.shimmerGradient,
                        child: ShimmerLoading(
                          isLoading: true,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 20,
                              itemBuilder: (context, index) => Column(
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xfff1efef),
                                          Color(0xfff8f7f7),
                                          Color(0xffe7e5e5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                    case AppStates.Initial_Fetching:
                      return Shimmer(
                        linearGradient: ConstGradient.shimmerGradient,
                        child: ShimmerLoading(
                          isLoading: true,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 20,
                              itemBuilder: (context, index) => Column(
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xfff1efef),
                                          Color(0xfff8f7f7),
                                          Color(0xffe7e5e5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                    case AppStates.Fetched:
                      if (value.feeslistnew.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: SvgPicture.asset(
                                "assets/images/no_pending_fee.svg",
                                alignment: Alignment.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Great news! Your account shows that you have no pending fees at this time.",
                              style: GoogleFonts.nunitoSans(
                                textStyle: Theme.of(
                                  context,
                                ).textTheme.titleLarge,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: value.feeslistnew.length,
                              itemBuilder: (context, index) => FeesTileNew(
                                feeModel: value.feeslistnew[index],
                                feesProvider: value,
                                index: index,
                              ),
                            ),
                          ),
                        );
                      }

                    case AppStates.Error:
                      return const Text("error");
                    case AppStates.NoInterNetConnectionState:
                      return NoInternetConnection(
                        ontap: () async {
                          bool hasInternet = await InternetConnectivity()
                              .hasInternetConnection;
                          if (!hasInternet) {
                            showToast("No internet connection!", context);
                          } else {
                            value.getStudentFee(
                              studentId: Provider.of<StudentProvider>(
                                context,
                                listen: false,
                              ).selectedStudentModel(context).studcode,
                            );
                            //  Navigator.pop(context);
                          }
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            Provider.of<StudentFeeProvider>(
              context,
            ).feeslistnew.any((element) => element.isSelected == true)
            ? PaymentButton(
                ontap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayementPage(
                        totalAmount: Provider.of<StudentFeeProvider>(
                          context,
                        ).totalAmount,
                      ),
                    ),
                  );
                  // TODO: PAYMENT
                  // Provider.of<StudentFeeProvider>(context, listen: false)
                  //     .postStudentFee(
                  //   context,
                  //   Provider.of<StudentProvider>(context, listen: false)
                  //       .selectedStudentModel(context)
                  //       .studcode,
                  // );
                },
                totalAmount: Provider.of<StudentFeeProvider>(
                  context,
                ).totalAmount,
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void getStudentFeeProvider() {
    Provider.of<StudentFeeProvider>(context, listen: false).getStudentFee(
      studentId: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).selectedStudentModel(context).studcode,
    );
  }
}
