import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/provider/contactus_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/web_view_screen.dart';
import 'package:school_app/views/screens/contact_us/contact_us.dart';
import 'package:school_app/views/screens/family_fee/cubit/family_fee_cubit.dart';
import 'package:school_app/views/screens/family_fee/pages/family_fee_screen.dart';
import 'package:school_app/views/screens/home_screen/home_screen_shimmer.dart';
import 'package:school_app/views/screens/parent/parent_settings_screen/parent_settings_screen_view.dart';
import 'package:school_app/views/screens/school_information_screen/school_information_screen_view.dart';
import 'package:school_app/views/screens/sibilingRegister/page/sibiling_registration_list.dart';

import '../../core/bloc/AuthBloc/auth_listener_bloc.dart';
import '../../core/provider/student_provider.dart';
import 'shimmer_student_profile.dart';

class DrawerTile extends StatelessWidget {
  final String text;
  final String name;
  final void Function() onTap;
  const DrawerTile({
    super.key,
    required this.text,
    required this.onTap,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              const SizedBox(width: 5),
              Image.network(
                name,
                height: 24,
                width: 24,
                color: ConstColors.primary,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
              const SizedBox(width: 16),
              Text(
                text,
                style: GoogleFonts.nunitoSans(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          onTap: onTap,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 18,
          ),
        ),
        // Divider(
        //   thickness: 2,
        //   color: Color.fromARGB(255, 255, 255, 255),
        // )
      ],
    );
  }
}

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  PackageInfo? packageInfo;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ConstColors.backgroundColor,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Provider.of<StudentProvider>(context).studentsModel == null
          ? Shimmer(
              linearGradient: ConstGradient.shimmerGradient,
              child: const HomeShimmerView(),
            )
          : Column(
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Provider.of<StudentProvider>(
                      context,
                    ).studentsModel!.menu.length,
                    itemBuilder: (context, index) => DrawerTile(
                      name: Provider.of<StudentProvider>(
                        context,
                      ).studentsModel!.menu[index].iconUrl,
                      text: Provider.of<StudentProvider>(
                        context,
                      ).studentsModel!.menu[index].menuValue,
                      onTap: () {
                        log(
                          Provider.of<StudentProvider>(
                            context,
                            listen: false,
                          ).studentsModel!.menu[index].menuKey,
                        );
                        if (Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).studentsModel!.menu[index].menuKey ==
                            "SchoolInfo") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SchoolInformationScreenView(),
                            ),
                          );
                        } else if (Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).studentsModel!.menu[index].menuKey ==
                            "SiblingRegistration") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SibilingRegistrationList(),
                            ),
                          );
                        } else if (Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).studentsModel!.menu[index].menuKey ==
                            "ContactUs") {
                          Provider.of<ContactUsProvider>(
                            context,
                            listen: false,
                          ).updatesubmitContactUs();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactUsScreen(),
                            ),
                          );
                        } else if (Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).studentsModel!.menu[index].menuKey ==
                            "Settings") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ParentSettingsScreenView(),
                            ),
                          );
                        } else if (Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).studentsModel!.menu[index].webUrl !=
                            '') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewScreen(
                                reponseUrl: Provider.of<StudentProvider>(
                                  context,
                                  listen: false,
                                ).studentsModel!.menu[index].webUrl,
                                title: Provider.of<StudentProvider>(
                                  context,
                                  listen: false,
                                ).studentsModel!.menu[index].menuValue,
                              ),
                            ),
                          );
                        } else if (Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).studentsModel!.menu[index].menuKey ==
                            "familyFee") {
                          BlocProvider.of<FamilyFeeCubit>(context).fetchfee();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FamilyFeeScreen(),
                            ),
                          );
                        } else {
                          showToast("Coming soon..", context);
                        }
                      },
                    ),
                  ),
                ),

                // Text(
                //   "About",
                //   style: Theme.of(context)
                //       .textTheme
                //       .headline6!
                //       .apply(color: Colors.white),
                // ),
                if (kDebugMode)
                  ListTile(
                    title: const Text(
                      "Log out",
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      context.read<AuthListenerBloc>().add(
                        AuthLoggedOutEvent(),
                      );
                    },
                  ),
                // DrawerTile(name: icons[5], text: "FAQ", onTap: () {}),
                // DrawerTile(name: icons[6], text: "Contact us", onTap: () {}),
                // DrawerTile(
                //     name: icons[7], text: "Privacy policy", onTap: () {}),
                // DrawerTile(
                //     name: icons[8], text: "Terms & conditions", onTap: () {}),
                Text(
                  "${packageInfo?.appName} ${packageInfo?.version}",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.copyright, color: Colors.black, size: 15),
                    Text(
                      AppEnivrornment.appName == "Springfield"
                          ? " Springfield"
                          : " PACE Education",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  Future<void> init() async {
    await PackageInfo.fromPlatform().then((value) {
      setState(() {
        packageInfo = value;
      });
    });
  }

  @override
  void initState() {
    init();
    // TODO: implement initState
    super.initState();
  }
}
