import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/open_house/bloc/open_house_bloc.dart';
import 'package:school_app/views/screens/open_house/components/active_details_card.dart';
import 'package:school_app/views/screens/open_house/cubit/open_house_cubit.dart';
import 'package:school_app/views/screens/open_house/screens/teachers_listing.dart';
import 'package:school_app/views/screens/student/fees_screen/fees_screen_view.dart';

class OpenHousePage extends StatefulWidget {
  const OpenHousePage({super.key});

  @override
  State<OpenHousePage> createState() => _OpenHousePageState();
}

class _OpenHousePageState extends State<OpenHousePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SlotSelectionCubit(),
      child: BlocConsumer<OpenHouseBloc, OpenHouseState>(
        bloc: BlocProvider.of<OpenHouseBloc>(context)
          ..add(
            OpenHouseLoadEvent(
              studeCode: Provider.of<StudentProvider>(
                context,
                listen: false,
              ).selectedStudentModel(context).studcode,
            ),
          ),
        listener: (context, state) {
          if (state is OpenHouseLoadingState) {
            context.read<SlotSelectionCubit>().clearData();
          }
          if (state is OpenHouseBookingSuccessState) {
            context.read<SlotSelectionCubit>().clearData();
            context.read<SlotSelectionCubit>().clearData();
            BlocProvider.of<OpenHouseBloc>(context).add(
              OpenHouseLoadEvent(
                studeCode: Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).selectedStudentModel(context).studcode,
              ),
            );
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: state.message,
              onConfirmBtnTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            );
            // showToast(state.message, context);
          } else if (state is OpenHouseBookingErrorState) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: state.message,
            );
          }
          // TODO: implement listener
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ConstColors.backgroundColor,
            appBar: const CommonAppBar(title: "Open House"),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: SelectStudentWidget(
                    onchanged: (index) {
                      BlocProvider.of<OpenHouseBloc>(context).add(
                        OpenHouseLoadEvent(
                          studeCode: Provider.of<StudentProvider>(
                            context,
                            listen: false,
                          ).selectedStudentModel(context).studcode,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state is OpenHouseLoadedState &&
                            state.activeOpenHouseList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 18.0,
                              top: 12.0,
                              right: 18.0,
                            ),
                            child: Text(
                              "Appointments",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .merge(
                                    const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 18.0,
                            top: 10.0,
                            right: 18.0,
                          ),
                          child: state is OpenHouseLoadedState
                              ? ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: state.activeOpenHouseList.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ActiveDetailsCard(
                                      activeOpenHouseModel:
                                          state.activeOpenHouseList[index],
                                    ),
                                  ),
                                )
                              : state is OpenHouseLoadingState
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 18.0,
                            top: 12.0,
                            right: 18.0,
                          ),
                          child: Text(
                            "Book Now",
                            style: Theme.of(context).textTheme.titleMedium!
                                .merge(
                                  const TextStyle(fontWeight: FontWeight.w500),
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 18.0,
                            top: 10.0,
                            right: 18.0,
                          ),
                          child: state is OpenHouseLoadedState
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: state.openHouseList.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ConstColors.filledColor,
                                        border: Border.all(
                                          color: ConstColors.borderColor,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.calendar_month,
                                          color: Colors.blue,
                                        ), // Leading icon with custom color
                                        title: Text(
                                          state.openHouseList[index].ohDate,
                                        ),
                                        subtitle: const Text('Appointment'),
                                        trailing: const Icon(
                                          Icons.arrow_forward,
                                        ), // Trailing arrow icon
                                        onTap: () {
                                          if (state
                                                  .openHouseList[index]
                                                  .ohStat ==
                                              "1") {
                                            context
                                                .read<SlotSelectionCubit>()
                                                .clearData();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BlocProvider(
                                                      create: (context) =>
                                                          SlotSelectionCubit(),
                                                      child: TeachersListing(
                                                        open_house_model: state
                                                            .openHouseList[index],
                                                      ),
                                                    ),
                                              ),
                                            );
                                          } else {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.error,
                                              showCancelBtn: true,
                                              title: state
                                                  .openHouseList[index]
                                                  .ohStstMsg,
                                              onConfirmBtnTap: () {
                                                Navigator.pop(context);
                                                Provider.of<StudentFeeProvider>(
                                                  context,
                                                  listen: false,
                                                ).getStudentFee(
                                                  studentId:
                                                      Provider.of<
                                                            StudentProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
                                                          .selectedStudentModel(
                                                            context,
                                                          )
                                                          .studcode,
                                                );
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const FeeScreenView(),
                                                  ),
                                                );
                                              },
                                              confirmBtnText: "Pay Now",
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : state is OpenHouseLoadingState
                              ? const Center(child: CircularProgressIndicator())
                              : Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      color: ConstColors.filledColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: ConstColors.borderColor,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            "assets/images/image.png",
                                            height:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).height *
                                                0.2,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "No open house found. Please come back later",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineMedium,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              MediaQuery.sizeOf(
                                                context,
                                              ).height *
                                              0.2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
