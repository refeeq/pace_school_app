// import 'package:animate_do/animate_do.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:school_app/core/provider/auth_provider.dart';
// import 'package:school_app/core/provider/guest_provider.dart';
// import 'package:school_app/core/themes/const_colors.dart';
// import 'package:school_app/core/utils/utils.dart';
// import 'package:school_app/views/components/custom_text_field.dart';
// import 'package:school_app/views/screens/guest/guest_menu_screen.dart';

// import '../../../../app.dart';

// class LoginScreen extends StatelessWidget {
//   //This key will be used to identify the state of the form.
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController admissionController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   LoginScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(builder: (context, provider, child) {
//       return LayoutBuilder(builder: (context, buildContext) {
//         return Scaffold(
//             backgroundColor: Colors.white,
//             body: Form(
//               key: _formKey,
//               child: Padding(
//                 padding: const EdgeInsets.all(25.0),
//                 child: SingleChildScrollView(
//                   child: FadeInRight(
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: buildContext.maxHeight * 0.05,
//                           ),
//                           Center(
//                               child: Image.asset(
//                             AppEnivrornment.appImageName,
//                             height: buildContext.maxHeight * 0.22,
//                           )),
//                           SizedBox(
//                             height: buildContext.maxHeight * 0.05,
//                           ),
//                           Text(
//                             AppEnivrornment.appFullName,
//                             textAlign: TextAlign.left,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineMedium!
//                                 .merge(TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w300,
//                                   //    fontFamily: 'SourceSansPro',
//                                 )),
//                           ),
//                           SizedBox(
//                             height: buildContext.maxHeight * 0.01,
//                           ),
//                           Text(
//                             'Sign in to continue',
//                             textAlign: TextAlign.left,
//                             style:
//                                 Theme.of(context).textTheme.titleLarge!.apply(
//                                       color: Color.fromARGB(255, 73, 72, 72),
//                                       fontFamily: 'SourceSansPro',
//                                     ),
//                           ),
//                           SizedBox(
//                             height: buildContext.maxHeight * 0.05,
//                           ),
//                           CustomtextFormFieldBorder(
//                             keyboardType: TextInputType.number,
//                             hintText: "Student Admission No",
//                             textEditingController: admissionController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please Enter Student Admission No';
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(
//                             height: buildContext.maxHeight * 0.02,
//                           ),
//                           CustomtextFormFieldBorder(
//                             hintText: "Phone No",
//                             keyboardType: TextInputType.number,
//                             textEditingController: phoneController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please Enter Phone No';
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(
//                             height: buildContext.maxHeight * 0.06,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               if (_formKey.currentState!.validate()) {
//                                 showAlertLoader(context);
//                                 Provider.of<AuthProvider>(context,
//                                         listen: false)
//                                     .login(
//                                         isResend: false,
//                                         admission: admissionController.text,
//                                         phone: phoneController.text,
//                                         context: context);
//                               }
//                             },
//                             child: Container(
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(5),
//                                     color: ConstColors.primary),
//                                 width: MediaQuery.of(context).size.width,
//                                 height: 55,
//                                 child: Center(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Text(
//                                         'SIGN IN',
//                                         textAlign: TextAlign.left,
//                                         style: TextStyle(
//                                           color:
//                                               Color.fromRGBO(255, 255, 255, 1),
//                                           fontFamily: 'SourceSansPro',
//                                           fontSize: 18,
//                                           letterSpacing: 0,
//                                           fontWeight: FontWeight.normal,
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         width: 30,
//                                       ),
//                                       SvgPicture.asset(
//                                         'assets/icons/right.svg',
//                                         height: 15,
//                                         width: 15,
//                                       ),
//                                     ],
//                                   ),
//                                 )),
//                           ),
//                           SizedBox(
//                             height: buildContext.maxHeight * 0.02,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Provider.of<GuestProvider>(context, listen: false)
//                                   .getGuestMenu();
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => GestMenuScreen(),
//                                   ));
//                             },
//                             child: Container(
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(5),
//                                     color: ConstColors.primary),
//                                 width: MediaQuery.of(context).size.width,
//                                 height: 55,
//                                 child: Center(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Text(
//                                         'GUEST',
//                                         textAlign: TextAlign.left,
//                                         style: TextStyle(
//                                           color:
//                                               Color.fromRGBO(255, 255, 255, 1),
//                                           fontFamily: 'SourceSansPro',
//                                           fontSize: 18,
//                                           letterSpacing: 0,
//                                           fontWeight: FontWeight.normal,
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         width: 30,
//                                       ),
//                                       SvgPicture.asset(
//                                         'assets/icons/right.svg',
//                                         height: 15,
//                                         width: 15,
//                                       ),
//                                     ],
//                                   ),
//                                 )),
//                           )
//                         ]),
//                   ),
//                 ),
//               ),
//             ));
//       });
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/bloc/bloc/login_bloc.dart';
import 'package:school_app/core/provider/guest_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/screens/guest/guest_menu_screen.dart';

import '../../../../app.dart';
import 'otp_verify_screen.dart';

class LoginScreen extends StatelessWidget {
  //This key will be used to identify the state of the form.
  final _formKey = GlobalKey<FormState>();
  final TextEditingController admissionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, buildContext) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: buildContext.maxHeight * 0.05),
                    Center(
                      child: Image.asset(
                        AppEnivrornment.appImageName,
                        height: buildContext.maxHeight * 0.22,
                      ),
                    ),
                    SizedBox(height: buildContext.maxHeight * 0.05),
                    Container(
                      height: MediaQuery.sizeOf(context).height,
                      decoration: BoxDecoration(
                        color: ConstColors.backgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppEnivrornment.appFullName,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.headlineMedium!
                                  .merge(
                                    const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      //    fontFamily: 'SourceSansPro',
                                    ),
                                  ),
                            ),
                            SizedBox(height: buildContext.maxHeight * 0.01),
                            Text(
                              'Sign in to continue',
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .apply(
                                    color: const Color.fromARGB(
                                      255,
                                      73,
                                      72,
                                      72,
                                    ),
                                  ),
                            ),
                            SizedBox(height: buildContext.maxHeight * 0.05),
                            CustomtextFormFieldBorder(
                              keyboardType: TextInputType.number,
                              hintText: "Student Admission No",
                              textEditingController: admissionController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Student Admission No';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: buildContext.maxHeight * 0.02),
                            CustomtextFormFieldBorder(
                              hintText: "Phone No",
                              keyboardType: TextInputType.number,
                              textEditingController: phoneController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Phone No';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: buildContext.maxHeight * 0.06),
                            BlocConsumer<LoginBloc, LoginState>(
                              listener: (context, state) {
                                if (state is LoginFailed) {
                                  showToast(state.message, context);
                                } else if (state is LoginSuccess) {
                                  showToast(state.message, context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OTpVerify(
                                        phoneNumber: state.number,
                                        admission: state.adm,
                                      ),
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                if (state is LoginLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      BlocProvider.of<LoginBloc>(context).add(
                                        LoginButtonPressEvent(
                                          number: phoneController.text,
                                          addmissionNumber:
                                              admissionController.text,
                                          context: context,
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
                                    height: 55,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'SIGN IN',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                255,
                                                255,
                                                255,
                                                1,
                                              ),
                                              fontFamily: 'SourceSansPro',
                                              fontSize: 18,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(width: 30),
                                          SvgPicture.asset(
                                            'assets/icons/right.svg',
                                            height: 15,
                                            width: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: buildContext.maxHeight * 0.02),
                            GestureDetector(
                              onTap: () {
                                Provider.of<GuestProvider>(
                                  context,
                                  listen: false,
                                ).getGuestMenu();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GestMenuScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: ConstColors.primary,
                                ),
                                width: MediaQuery.of(context).size.width,
                                height: 55,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'GUEST',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            1,
                                          ),
                                          fontFamily: 'SourceSansPro',
                                          fontSize: 18,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      SvgPicture.asset(
                                        'assets/icons/right.svg',
                                        height: 15,
                                        width: 15,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
