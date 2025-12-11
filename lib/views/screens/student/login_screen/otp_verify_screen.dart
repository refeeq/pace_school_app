// import 'dart:async';

// import 'package:animate_do/animate_do.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:school_app/core/provider/auth_provider.dart';
// import 'package:school_app/core/themes/const_box_decoration.dart';
// import 'package:school_app/core/themes/const_colors.dart';
// import 'package:school_app/core/themes/const_gradient.dart';
// import 'package:school_app/core/utils/utils.dart';

// class OTpVerify extends StatefulWidget {
//   final String admission;
//   final String phoneNumber;
//   const OTpVerify(
//       {super.key, required this.phoneNumber, required this.admission});

//   @override
//   State<OTpVerify> createState() => _OTpVerifyState();
// }

// class _OTpVerifyState extends State<OTpVerify> {
//   late Timer _timer;
//   int _start = 60;

//   TextEditingController controller = TextEditingController();

//   final List<TextEditingController> _controllers =
//       List.generate(5, (index) => TextEditingController());
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) => Container(
//         decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             elevation: 0.0,
//             backgroundColor: Colors.transparent,
//           ),
//           body: Container(
//             height: MediaQuery.of(context).size.height,
//             decoration: ConstBoxDecoration.whiteDecoration,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: SingleChildScrollView(
//                 child: FadeInRight(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // SvgPicture.asset(
//                       //   'assets/images/splashscreen.svg',
//                       //   height: 15,
//                       //   width: 15,
//                       // ),
//                       //  Image.asset('assets/images/otp.png'),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.2,
//                       ),
//                       Text(
//                         "We sent you a code to verify your mobile number",
//                         textAlign: TextAlign.center,
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleLarge!
//                             .merge(TextStyle(
//                               fontWeight: FontWeight.w400,
//                             )),
//                       ),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.05,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Enter the OTP sent to "),
//                           Text(
//                             widget.phoneNumber,
//                             style: const TextStyle(fontWeight: FontWeight.w800),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.01,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(5.0),
//                         child: Form(
//                             child: FittedBox(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: List.generate(
//                               5,
//                               (index) => _buildOTPTextField(index),
//                             ),
//                           ),
//                         )),
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.03,
//                       ),
//                       _start == 0
//                           ? Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text("I didn't receive a code!"),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 GestureDetector(
//                                     onTap: () {
//                                       showAlertLoader(context);
//                                       authProvider.login(
//                                           isResend: true,
//                                           admission: widget.admission,
//                                           phone: widget.phoneNumber,
//                                           context: context);
//                                       startTimer();
//                                     },
//                                     child: const Text(
//                                       "RESEND CODE",
//                                       style: TextStyle(
//                                           color: Color.fromRGBO(40, 85, 174, 1),
//                                           fontWeight: FontWeight.w500),
//                                     ))
//                               ],
//                             )
//                           : Text("Fetching OTP $_start"),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.05,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           String otp = "";
//                           for (var controller in _controllers) {
//                             otp += controller.text;
//                           }
//                           if (otp.length < 5 || otp.isEmpty) {
//                             showToast("Enter the Otp", context);
//                           } else {
//                             showAlertLoader(context);

//                             authProvider.otpVerify(
//                                 otpCode: otp,
//                                 phoneNo: widget.phoneNumber,
//                                 context: context);
//                           }
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(5),
//                               color: ConstColors.primary),
//                           width: MediaQuery.of(context).size.width,
//                           height: 45,
//                           child: const Center(
//                             child: Text(
//                               'VERIFY & PROCEED',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: Color.fromRGBO(255, 255, 255, 1),
//                                 fontFamily: 'SourceSansPro',
//                                 fontSize: 16,
//                                 letterSpacing: 0,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.05,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     startTimer();
//     // TODO: implement initState
//     super.initState();
//   }

//   void startTimer() {
//     setState(() {
//       _start = 60;
//       const oneSec = const Duration(seconds: 1);
//       _timer = Timer.periodic(
//         oneSec,
//         (Timer timer) {
//           if (_start == 0) {
//             setState(() {
//               timer.cancel();
//             });
//           } else {
//             setState(() {
//               _start--;
//             });
//           }
//         },
//       );
//     });
//   }

//   Widget _buildOTPTextField(int index) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         height: 64,
//         width: MediaQuery.of(context).size.width / 7,
//         child: TextFormField(
//           autofocus: true,
//           controller: _controllers[index],
//           onChanged: (value) {
//             if (value.length == 1 && index < 4) {
//               FocusScope.of(context).nextFocus();
//             } else if (value.isEmpty && index > 0) {
//               FocusScope.of(context).previousFocus();
//             }
//           },
//           keyboardType: TextInputType.number,
//           maxLength: 1,
//           decoration: InputDecoration(
//             counterText: "",
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:school_app/core/bloc/AuthBloc/auth_listener_bloc.dart';
import 'package:school_app/core/bloc/bloc/login_bloc.dart';
import 'package:school_app/core/themes/const_box_decoration.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';

class OTpVerify extends StatefulWidget {
  final String admission;
  final String phoneNumber;
  const OTpVerify({
    super.key,
    required this.phoneNumber,
    required this.admission,
  });

  @override
  State<OTpVerify> createState() => _OTpVerifyState();
}

class _OTpVerifyState extends State<OTpVerify> {
  late Timer _timer;
  int _start = 60;

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: const CommonAppBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: ConstBoxDecoration.whiteDecoration,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: FadeInRight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SvgPicture.asset(
                    //   'assets/images/splashscreen.svg',
                    //   height: 15,
                    //   width: 15,
                    // ),
                    //  Image.asset('assets/images/otp.png'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Text(
                      "We sent you a code to verify your mobile number",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.merge(
                        const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Enter the OTP sent to "),
                        Text(
                          widget.phoneNumber,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                    BlocConsumer<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is OtpSuccess) {
                          //    showToast(state.message, context);
                          Navigator.pop(context);
                        } else if (state is OtpFailed) {
                          showToast(state.message, context);
                        } else if (state is OtpResendSuccessState) {
                          showToast(state.message, context);
                        }
                      },
                      builder: (context, state) {
                        if (state is OtpSuccess) {
                          BlocProvider.of<AuthListenerBloc>(
                            context,
                          ).add(AuthLoggedInEvent());
                        }
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Form(
                                child: state == OtpResendState
                                    ? const CircularProgressIndicator()
                                    : PinCodeTextField(
                                        controller: controller,
                                        appContext: context,

                                        length: 5,
                                        enableActiveFill: true,

                                        blinkWhenObscuring: true,

                                        animationType: AnimationType.fade,

                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        pinTheme: PinTheme(
                                          shape: PinCodeFieldShape.box,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          fieldHeight: 50,
                                          fieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.13,
                                          activeColor: ConstColors.primary,
                                          activeFillColor: Colors.white,
                                          errorBorderColor: Colors.red,
                                          inactiveFillColor: Colors.white,
                                          inactiveColor: ConstColors.primary,
                                          selectedColor: ConstColors.primary,
                                          selectedFillColor: Colors.white,
                                          borderWidth: 1,
                                        ),

                                        animationDuration: const Duration(
                                          milliseconds: 300,
                                        ),

                                        //  errorAnimationController: errorController,
                                        //  controller: textEditingController,
                                        keyboardType: TextInputType.number,
                                        onSubmitted: (value) {
                                          BlocProvider.of<LoginBloc>(
                                            context,
                                          ).add(
                                            OtpVerifyingEvent(
                                              otpNumber: value,
                                              phonenumber: widget.phoneNumber,
                                              buildContext: context,
                                            ),
                                          );
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
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            _start == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("I didn't receive a code!"),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          BlocProvider.of<LoginBloc>(
                                            context,
                                          ).add(
                                            OtpResendEvent(
                                              number: widget.phoneNumber,
                                              addmissionNumber:
                                                  widget.admission,
                                              context: context,
                                            ),
                                          );

                                          startTimer();
                                        },
                                        child: const Text(
                                          "RESEND CODE",
                                          style: TextStyle(
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
                                    ],
                                  )
                                : Text("Fetching OTP $_start"),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            if (state is OtpLoading)
                              const CircularProgressIndicator()
                            else
                              GestureDetector(
                                onTap: () {
                                  String otp = controller.text;

                                  if (otp.length < 5 || otp.isEmpty) {
                                    showToast("Enter the Otp", context);
                                  } else {
                                    BlocProvider.of<LoginBloc>(context).add(
                                      OtpVerifyingEvent(
                                        otpNumber: otp,
                                        phonenumber: widget.phoneNumber,
                                        buildContext: context,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: ConstColors.primary,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  height: 45,
                                  child: const Center(
                                    child: Text(
                                      'VERIFY & PROCEED',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
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
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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

  @override
  void initState() {
    startTimer();
    // TODO: implement initState
    super.initState();
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
