import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/payment_button.dart';
import 'package:school_app/views/components/profile_tile.dart';
import 'package:school_app/views/screens/family_fee/components/family_tile.dart';
import 'package:school_app/views/screens/family_fee/cubit/family_fee_cubit.dart';
import 'package:school_app/views/screens/student/fees_screen/payment_screen.dart';

class FamilyFeeScreen extends StatelessWidget {
  const FamilyFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Family Fee"),
      body: SafeArea(
        child: BlocConsumer<FamilyFeeCubit, FamilyFeeState>(
          builder: (context, state) {
            if (state is FamilyFeeFetchError) {
              return const Center(child: Text("Error"));
            } else if (state is FamilyFeeFetchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.family!.data.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8.0,
                        left: 16,
                        right: 16,
                      ),
                      child: Container(
                        decoration: ShapeDecoration(
                          shadows: const [
                            BoxShadow(
                              color: Color(0x214D4D52),
                              blurRadius: 16,
                              offset: Offset(0, 2),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Color(0x1EFFFFFF),
                              blurRadius: 1,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            ),
                          ],
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        radius: 40,
                                        child: CircleAvatar(
                                          radius: 38,
                                          backgroundImage: NetworkImage(
                                            state.family!.data[index].photo,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              state
                                                  .family!
                                                  .data[index]
                                                  .fullname,
                                              style: GoogleFonts.nunitoSans(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .apply(fontWeightDelta: 1),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ProfileTile(
                                              label: "Admission Number",
                                              value: state
                                                  .family!
                                                  .data[index]
                                                  .studcode,
                                            ),
                                            const SizedBox(height: 2),
                                            ProfileTile(
                                              label: "Grade & Section",
                                              value:
                                                  "${state.family!.data[index].datumClass} - ${state.family!.data[index].section}",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  state.family!.data[index].fee.isEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          itemCount: state
                                              .family!
                                              .data[index]
                                              .fee
                                              .length,
                                          itemBuilder: (context, ind) =>
                                              FamilyTile(
                                                isMandatory: state
                                                    .family!
                                                    .data[index]
                                                    .chkboxReadOnly,
                                                feeModel: state
                                                    .family!
                                                    .data[index]
                                                    .fee[ind],
                                                family: state.family!,
                                                studcode: state
                                                    .family!
                                                    .data[index]
                                                    .studcode,
                                                index: ind,
                                              ),
                                        ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                            Row(
                              children: List.generate(
                                150 ~/ 4,
                                (index) => Expanded(
                                  child: Container(
                                    color: index % 2 == 0
                                        ? Colors.transparent
                                        : const Color(0xFFEFF1F5),
                                    height: 2,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Total Amount ${state.family!.data[index].amount}",
                                  style: GoogleFonts.nunitoSans(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .merge(
                                          const TextStyle(color: Colors.black),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          listener: (context, state) {
            if (state is FamilyFeePaySuccess) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuccessScreen(
                    isPayment: false,
                    reponseUrl: state.data,
                    userId: "",
                  ),
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar:
          BlocProvider.of<FamilyFeeCubit>(context, listen: true).state.family !=
                  null &&
              BlocProvider.of<FamilyFeeCubit>(
                    context,
                    listen: true,
                  ).state.family!.totalAmount !=
                  0
          ? PaymentButton(
              ontap: () {
                BlocProvider.of<FamilyFeeCubit>(context).submitFee();
              },
              totalAmount: BlocProvider.of<FamilyFeeCubit>(
                context,
                listen: true,
              ).state.family!.totalAmount,
            )
          : const SizedBox(),
    );
  }
}
