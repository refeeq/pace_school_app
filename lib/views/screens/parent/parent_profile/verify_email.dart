import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';

import '../../../../core/config/app_status.dart';
import '../../../components/custom_text_field.dart';

class VerifyEmail extends StatefulWidget {
  final String relation;

  const VerifyEmail({super.key, required this.relation});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  late Timer _timer;
  int _start = 60;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// Pre-populate email from parent profile (parentProfileTab API).
  void _prePopulateFromParentProfile() {
    final parentProvider = Provider.of<ParentProvider>(context, listen: false);
    final common = parentProvider.parentProfileListModel?.common;
    if (common == null) return;
    final isFather = widget.relation.toLowerCase() == 'father';
    final str = (isFather ? common.email : common.memail).trim();
    if (str.isNotEmpty && str != 'null') {
      emailcontroller.text = str;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParentProvider>(
        context,
        listen: false,
      ).updateParentOtpStatus();
      if (mounted) _prePopulateFromParentProfile();
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Consumer<ParentProvider>(
              builder: (context, value, child) {
                switch (value.parentOtpState) {
                  case AppStates.Unintialized:
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Image.asset(
                              'assets/images/email.png',
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Enter new email address to update.",
                            style: GoogleFonts.nunitoSans(fontSize: 17),
                          ),
                          const SizedBox(height: 20),
                          CustomtextFormFieldBorder(
                            hintText: "Email Id",
                            keyboardType: TextInputType.emailAddress,
                            textEditingController: emailcontroller,
                            validator: (val) =>
                                val!.isEmpty || !val.contains("@")
                                ? "enter a valid eamil"
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
                            //  Image.asset('assets/images/otp.png'),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                            ),
                            Text(
                              "We sent you a code to verify your email address",
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
                                  emailcontroller.text,
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
                                controller: controller,
                                appContext: context,

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

                                //  errorAnimationController: errorController,
                                //  controller: textEditingController,
                                keyboardType: TextInputType.number,
                                onSubmitted: (value) {
                                  // Provider.of<AuthProvider>(
                                  //   context,
                                  //   listen: false,
                                  // ).otpVerify(
                                  //     otpCode: controller.text,
                                  //     phoneNo: widget.email,
                                  //     context: context);
                                },
                                onCompleted: (v) {},
                                // onTap: () {
                                //   print("Pressed");
                                // },
                                onChanged: (value) {
                                  debugPrint(value);
                                  // setState(() {
                                  //   currentText = value;
                                  // });
                                },
                                beforeTextPaste: (text) {
                                  debugPrint("Allowing to paste $text");
                                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                  return true;
                                },
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: () {
            if (_formKey.currentState!.validate() &&
                Provider.of<ParentProvider>(
                      context,
                      listen: false,
                    ).parentOtpState !=
                    AppStates.Fetched &&
                Provider.of<ParentProvider>(
                      context,
                      listen: false,
                    ).parentOtpState !=
                    AppStates.Initial_Fetching) {
              Provider.of<ParentProvider>(context, listen: false).sendEmailOtp(
                relation: widget.relation,
                email: emailcontroller.text,
                context: context,
              );
            } else if (Provider.of<ParentProvider>(
                  context,
                  listen: false,
                ).parentOtpState ==
                AppStates.Fetched) {
              Provider.of<ParentProvider>(context, listen: false)
                  .verifyEmailOtp(
                    relation: widget.relation,
                    email: emailcontroller.text,
                    otp: controller.text,
                    context: context,
                  )
                  .then((_) async {
                    // After successful OTP verification, also create a request entry
                    final parentUpdateProvider =
                        Provider.of<ParentUpdateProvider>(
                      context,
                      listen: false,
                    );
                    await parentUpdateProvider.submitFatherEmailRequest(
                      email: emailcontroller.text,
                      context: context,
                    );
                    emailcontroller.clear();

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: ConstColors.primary,
            ),
            width: MediaQuery.of(context).size.width,
            height: 44,
            child: Center(
              child: Text(
                'Continue',
                textAlign: TextAlign.left,
                style: GoogleFonts.nunitoSans(
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'SourceSansPro',
                    fontSize: 16,
                    letterSpacing: 0,
                    fontWeight: FontWeight.normal,
                  ),
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
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _start = 60;
      const oneSec = Duration(seconds: 1);
      _timer = Timer.periodic(oneSec, (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      });
    });
  }
}
