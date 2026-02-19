import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/border_with_text_widget.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/document_expiry_alerts_widget.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/screens/parent/parent_profile/verify_email.dart';
import 'package:school_app/views/screens/parent/parent_profile/verify_mobile.dart';
import 'package:school_app/core/bloc/AuthBloc/auth_listener_bloc.dart';
import 'package:school_app/core/services/logout_service.dart';
import 'package:school_app/views/screens/parent/parent_update/parent_update_hub_screen.dart';

import '../../../components/profile_tile.dart';
import '../../../components/shimmer_profile.dart';

class ParentProfileScreenView extends StatefulWidget {
  const ParentProfileScreenView({super.key});

  @override
  State<ParentProfileScreenView> createState() =>
      _ParentProfileScreenViewState();
}

class _ParentProfileScreenViewState extends State<ParentProfileScreenView> {
  PageController pageController = PageController(initialPage: 0);
  int _logoutTapCount = 0;
  DateTime? _lastLogoutTapTime;

  void _onFamilyCodeTap(BuildContext context) {
    const tapWindow = Duration(seconds: 2);
    final now = DateTime.now();
    if (_lastLogoutTapTime != null &&
        now.difference(_lastLogoutTapTime!) > tapWindow) {
      _logoutTapCount = 0;
    }
    _lastLogoutTapTime = now;
    _logoutTapCount++;
    if (_logoutTapCount >= 7) {
      _logoutTapCount = 0;
      _showLogoutConfirmation(context);
    }
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await clearAllUserDataOnLogout(context);
      if (context.mounted) {
        context.read<AuthListenerBloc>().add(AuthLoggedOutEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Profile"),
      body: Consumer<ParentProvider>(
        builder: (context, value, child) {
          switch (value.parentDetailListState) {
            case AppStates.Unintialized:
            case AppStates.Initial_Fetching:
              return Shimmer(
                linearGradient: ConstGradient.shimmerGradient,
                child: const ShimmerParnetProfile(),
              );
            case AppStates.Fetched:
              if (value.parentProfileListModel == null) {
                return const NoDataWidget(
                  imagePath: "assets/images/no_data.svg",
                  content: "Something went wrong",
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Center(
                            child: SizedBox(
                              height: 90.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    value.parentProfileListModel!.data.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => Padding(
                                  padding: EdgeInsets.all(8.0.h),
                                  child: InkWell(
                                    onTap: () {
                                      value.selectParent(index);
                                      pageController.jumpToPage(index);
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              value.parentSelected == index
                                                  ? Colors.blue
                                                  : Colors.white,
                                          radius: 30.r,
                                          child: CircleAvatar(
                                            radius: 28.5.r,
                                            child:
                                                value
                                                        .parentProfileListModel!
                                                        .data[index]
                                                        .photo ==
                                                    ""
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    radius: 28.r,
                                                    backgroundImage: AssetImage(
                                                      value
                                                                  .parentProfileListModel!
                                                                  .data[index]
                                                                  .relation ==
                                                              "Mother"
                                                          ? 'assets/Icons/mother.png'
                                                          : value
                                                                    .parentProfileListModel!
                                                                    .data[index]
                                                                    .relation ==
                                                                "Father"
                                                          ? 'assets/Icons/dad.png'
                                                          : 'assets/Icons/user.png',
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    radius: 28.r,
                                                    backgroundImage: NetworkImage(
                                                      value
                                                          .parentProfileListModel!
                                                          .data[index]
                                                          .photo,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Text(
                                          value
                                              .parentProfileListModel!
                                              .data[index]
                                              .relation,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                        ],
                      ),
                      Expanded(
                        child: PageView(
                          onPageChanged: (page) {
                            value.selectParent(page);
                            pageController.jumpToPage(page);
                          },
                          controller: pageController,
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BorderWithTextWidget(
                                    title:
                                        "${value.parentProfileListModel!.data[value.parentSelected].relation} Details",
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Name",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .name,
                                        ),
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Relation",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .relation,
                                        ),
                                        SizedBox(height: 6.h),
                                        GestureDetector(
                                          onTap: () =>
                                              _onFamilyCodeTap(context),
                                          behavior: HitTestBehavior.opaque,
                                          child: ProfileTile(
                                            label: "Family Code",
                                            value: value
                                                .parentProfileListModel!
                                                .data[value.parentSelected]
                                                .famcode,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VerifyMobile(
                                                  relation: value
                                                      .parentProfileListModel!
                                                      .data[value.parentSelected]
                                                      .relation,
                                                ),
                                              ),
                                            );
                                          },
                                          child: ProfileTile(
                                            canEdit: true,
                                            label: "Mobile Number",
                                            value: value
                                                .parentProfileListModel!
                                                .data[value.parentSelected]
                                                .mobile,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        InkWell(
                                          onTap: () {
                                             if (value
                                                .parentProfileListModel!
                                                .data[value.parentSelected]
                                                .email
                                                .isEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => VerifyEmail(
                                                    relation: value
                                                        .parentProfileListModel!
                                                        .data[value.parentSelected]
                                                        .relation,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: ProfileTile(
                                            canEdit: true,
                                            isRed: value
                                                .parentProfileListModel!
                                                .data[value.parentSelected]
                                                .email
                                                .isEmpty,
                                            label: "Email ID",
                                            value:
                                                value
                                                    .parentProfileListModel!
                                                    .data[value.parentSelected]
                                                    .email
                                                    .isEmpty
                                                ? "UPDATE EMAIL"
                                                : value
                                                      .parentProfileListModel!
                                                      .data[value.parentSelected]
                                                      .email,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Office City",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .offcity,
                                        ),
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Company",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .company,
                                        ),
                                        SizedBox(height: 6.h),
                                      ],
                                    ),
                                  ),
                                  const DocumentExpiryAlertsWidget(),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BorderWithTextWidget(
                                    title:
                                        "${value.parentProfileListModel!.data[value.parentSelected].relation} Details",
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Name",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .name,
                                        ),
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Relation",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .relation,
                                        ),
                                        SizedBox(height: 6.h),
                                        GestureDetector(
                                          onTap: () =>
                                              _onFamilyCodeTap(context),
                                          behavior: HitTestBehavior.opaque,
                                          child: ProfileTile(
                                            label: "Family Code",
                                            value: value
                                                .parentProfileListModel!
                                                .data[value.parentSelected]
                                                .famcode,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Mobile Number",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .mobile,
                                        ),
                                        SizedBox(height: 6.h),
                                        InkWell(
                                          onTap: () {
                                            if (value
                                                .parentProfileListModel!
                                                .data[value.parentSelected]
                                                .email
                                                .isEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => VerifyEmail(
                                                    relation: value
                                                        .parentProfileListModel!
                                                        .data[value.parentSelected]
                                                        .relation,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: ProfileTile(
                                            isRed: value
                                                .parentProfileListModel!
                                                .data[value.parentSelected]
                                                .email
                                                .isEmpty,
                                            label: "Email ID",
                                            value:
                                                value
                                                    .parentProfileListModel!
                                                    .data[value.parentSelected]
                                                    .email
                                                    .isEmpty
                                                ? "UPDATE EMAIL"
                                                : value
                                                      .parentProfileListModel!
                                                      .data[value.parentSelected]
                                                      .email,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Office City",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .offcity,
                                        ),
                                        SizedBox(height: 6.h),
                                        ProfileTile(
                                          label: "Company",
                                          value: value
                                              .parentProfileListModel!
                                              .data[value.parentSelected]
                                              .company,
                                        ),
                                        SizedBox(height: 6.h),
                                      ],
                                    ),
                                  ),
                                  const DocumentExpiryAlertsWidget(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ConstColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ParentUpdateHubScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Update Profile'),
                        ),
                      ),
                    ],
                  ),
                );
              }
            case AppStates.Error:
              return const Center(child: Text("Error"));
            case AppStates.NoInterNetConnectionState:
              return NoInternetConnection(
                ontap: () async {
                  bool hasInternet =
                      await InternetConnectivity().hasInternetConnection;
                  if (!hasInternet) {
                    showToast("No internet connection!", context);
                  } else {
                    Future(() {
                      value.getParentDetailsList();
                    });
                  }
                },
              );
          }
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    Future(() {
      Provider.of<ParentProvider>(context, listen: false).selectParent(0);
      Provider.of<ParentProvider>(
        context,
        listen: false,
      ).getParentDetailsList();
      Provider.of<StudentProvider>(context, listen: false)
          .fetchDocumentWarningsForAllStudents();
    });
    super.didChangeDependencies();
  }
}
