import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/screens/sibilingRegister/cubit/sibiling_registration_cubit.dart';
import 'package:school_app/views/screens/sibilingRegister/sibiling_register_screen.dart';
import 'package:school_app/views/screens/sibilingRegister/utils/color_status.dart';

class SibilingRegistrationList extends StatelessWidget {
  const SibilingRegistrationList({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SibilingRegistrationCubit>().fetchUsers();
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: ConstColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SibilingRegisterScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      appBar: const CommonAppBar(title: 'Sibling Registration List'),
      body: BlocBuilder<SibilingRegistrationCubit, SibilingRegistrationState>(
        // bloc: context.read<SibilingRegistrationCubit>().fetchUsers(),
        builder: (context, state) {
          switch (state) {
            case SibilingRegistrationListError _:
              return Center(child: Text(state.message));
            case SibilingRegistrationListFetched _:
              return Padding(
                padding: const EdgeInsets.all(22.0),
                child: state.list.isEmpty
                    ? const Center(
                        child: NoDataWidget(
                          imagePath: "assets/images/no_circular.svg",
                          content: "No Sibilings Found!",
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.list.length,
                        itemBuilder: (context, index) {
                          final sibling = state.list[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        //                   <--- left side
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                      left: BorderSide(
                                        //                   <--- left side
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                      top: BorderSide(
                                        //                    <--- top side
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              sibling.name!,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.cake,
                                                      size: 17,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      sibling.dob!
                                                          .toLocal()
                                                          .toString()
                                                          .split(' ')[0],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.confirmation_number,
                                                      size: 17,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      sibling.refNo!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.school,
                                                      size: 17,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      sibling
                                                          .siblingRegisterModelClass!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 17,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      sibling.acYear!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: sibling.appStateNo == null
                                            ? Colors.black
                                            : AdmissionStatusColors.getColor(
                                                sibling.appStateNo!,
                                              ).withValues(alpha: 0.1),
                                        width: 1.0,
                                      ),
                                      left: BorderSide(
                                        color: sibling.appStateNo == null
                                            ? Colors.black
                                            : AdmissionStatusColors.getColor(
                                                sibling.appStateNo!,
                                              ).withValues(alpha: 0.1),
                                        width: 1.0,
                                      ),
                                      bottom: BorderSide(
                                        color: sibling.appStateNo == null
                                            ? Colors.black
                                            : AdmissionStatusColors.getColor(
                                                sibling.appStateNo!,
                                              ).withValues(alpha: 0.1),
                                        width: 1.0,
                                      ),
                                    ),
                                    color: sibling.appStateNo == null
                                        ? Colors.white
                                        : AdmissionStatusColors.getColor(
                                            sibling.appStateNo!,
                                          ),
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        sibling.appStateNo == null
                                            ? "Processing"
                                            : sibling.appStat!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .apply(
                                              color: sibling.appStateNo == null
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              );
            case SibilingRegistrationListLoading _:
              return const Center(child: CircularProgressIndicator());
            case SibilingRegistrationInitial _:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
