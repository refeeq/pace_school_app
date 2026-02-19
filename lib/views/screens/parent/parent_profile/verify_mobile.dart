import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';

import '../../../../core/config/app_status.dart';
import '../../../components/custom_text_field.dart';

class VerifyMobile extends StatefulWidget {
  final String relation;

  const VerifyMobile({super.key, required this.relation});

  @override
  State<VerifyMobile> createState() => _VerifyMobileState();
}

class _VerifyMobileState extends State<VerifyMobile> {
  Timer? _timer;
  int _start = 60;
  TextEditingController mobileController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _disposed = false;

  /// Pre-populate mobile from parent profile (parentProfileTab API).
  void _prePopulateFromParentProfile() {
    final parentProvider = Provider.of<ParentProvider>(context, listen: false);
    final common = parentProvider.parentProfileListModel?.common;
    if (common == null) return;
    final isFather = widget.relation.toLowerCase() == 'father';
    final str = (isFather ? common.mobile : common.mmob).trim();
    if (str.isNotEmpty && str != 'null') {
      mobileController.text = str;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParentProvider>(context, listen: false).updateParentMobileOtpStatus();
      if (mounted) _prePopulateFromParentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Verify Mobile"),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Consumer<ParentProvider>(
                builder: (context, value, child) {
                switch (value.parentMobileOtpState) {
                  case AppStates.Unintialized:
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Icon(
                              Icons.phone_android,
                              size: 120,
                              color: ConstColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Enter new mobile number to update.",
                            style: GoogleFonts.nunitoSans(fontSize: 17),
                          ),
                          const SizedBox(height: 20),
                          CustomtextFormFieldBorder(
                            hintText: "Mobile Number",
                            keyboardType: TextInputType.phone,
                            textEditingController: mobileController,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? "Enter a valid mobile number"
                                : null,
                          ),
                        ],
                      ),
                    );
                  case AppStates.Initial_Fetching:
                    return Center(child: loader());
                  case AppStates.Fetched:
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FadeInRight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/email.svg',
                              height: 15,
                              width: 15,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                            ),
                            Text(
                              "We sent you a code to verify your mobile number",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .merge(
                                      const TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Enter the OTP sent to ",
                                  style: GoogleFonts.nunitoSans(),
                                ),
                                Text(
                                  mobileController.text,
                                  style: GoogleFonts.nunitoSans(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PinCodeTextField(
                                controller: otpController,
                                appContext: context,
                                autoDisposeControllers: false,
                                length: 5,
                                enableActiveFill: true,
                                blinkWhenObscuring: true,
                                animationType: AnimationType.fade,
                                textStyle: const TextStyle(color: Colors.white),
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(10),
                                  fieldHeight: 50,
                                  fieldWidth:
                                      MediaQuery.of(context).size.width * 0.13,
                                  activeColor: ConstColors.primary,
                                  activeFillColor: ConstColors.primary,
                                  inactiveFillColor: ConstColors.primary,
                                  inactiveColor: ConstColors.primary,
                                  selectedColor: ConstColors.primary,
                                  selectedFillColor: ConstColors.primary,
                                  borderWidth: 1,
                                ),
                                animationDuration: const Duration(
                                  milliseconds: 300,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {},
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            _start == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "I didn't receive a code!",
                                        style: GoogleFonts.nunitoSans(),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          showAlertLoader(context);
                                          startTimer();
                                        },
                                        child: Text(
                                          "RESEND CODE",
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(
                                                40,
                                                85,
                                                174,
                                                1,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text("Fetching OTP $_start"),
                          ],
                        ),
                      ),
                    );
                  case AppStates.NoInterNetConnectionState:
                    return NoInternetConnection(ontap: () {});
                  case AppStates.Error:
                    return const NoDataWidget(
                      imagePath: "assets/images/no_data.svg",
                      content: "Something went wrong. Please try again later.",
                    );
                }
              },
            ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: () {
            if (_formKey.currentState!.validate() &&
                Provider.of<ParentProvider>(
                      context,
                      listen: false,
                    ).parentMobileOtpState !=
                    AppStates.Fetched &&
                Provider.of<ParentProvider>(
                      context,
                      listen: false,
                    ).parentMobileOtpState !=
                    AppStates.Initial_Fetching) {
              Provider.of<ParentProvider>(context, listen: false).sendMobileOtp(
                relation: widget.relation,
                mobile: mobileController.text,
                context: context,
              );
              startTimer();
            } else if (Provider.of<ParentProvider>(
                  context,
                  listen: false,
                ).parentMobileOtpState ==
                AppStates.Fetched) {
              Provider.of<ParentProvider>(context, listen: false).verifyMobile(
                relation: widget.relation,
                mobile: mobileController.text,
                otp: otpController.text,
                context: context,
              );
            }
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ConstColors.primary,
            ),
            child: Center(
              child: Text(
                "UPDATE",
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    mobileController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel(); // Cancel existing timer if any
    const oneSec = Duration(seconds: 1);
    _start = 60;
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (!mounted || _disposed) {
        timer.cancel();
        _timer = null;
        return;
      }
      if (_start == 0) {
        timer.cancel();
        _timer = null;
        if (mounted && !_disposed) {
          setState(() {});
        }
      } else {
        if (mounted && !_disposed) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }
}
