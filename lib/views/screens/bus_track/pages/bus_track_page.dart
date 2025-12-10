import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/bus_track/components/bus_track_data.dart';
import 'package:school_app/views/screens/bus_track/cubit/bus_track_cubit.dart';

class BusTrackPage extends StatefulWidget {
  const BusTrackPage({super.key});

  @override
  State<BusTrackPage> createState() => _BusTrackPageState();
}

class UiWidget extends StatelessWidget {
  const UiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SelectStudentWidget(
            onchanged: (index) {
              locator<BusTrackCubit>().getTracking(
                admissionNo: Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).selectedStudentModel(context).studcode,
              );
            },
          ),
          Expanded(
            child: BlocConsumer<BusTrackCubit, BusTrackState>(
              builder: (context, state) {
                return state.when(
                  initial: () =>
                      const Center(child: CircularProgressIndicator()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  success: (busTrackDataModel) =>
                      BusTrackData(busTrackDataModel: busTrackDataModel),
                  failure: (error) => Center(child: Text(error)),
                  tracking: () =>
                      const Center(child: CircularProgressIndicator()),
                  trackingSuccess: () =>
                      const Center(child: CircularProgressIndicator()),
                  trackingFailure: (error) =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
              listener: (context, state) {},
            ),
          ),
        ],
      ),
    );
  }
}

class _BusTrackPageState extends State<BusTrackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(
        title: "Student Tracking",
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings_ethernet, color: Colors.white),
        //     tooltip: 'MQTT Test',
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => const MqttTestPage()),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: const UiWidget(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
