import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/submit_button.dart';
import 'package:school_app/views/screens/contact_us/cubit/contact_us_cubit.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  final TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Contact Us"),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocProvider(
          create: (context) => ContactUsCubit(),
          child: BlocConsumer<ContactUsCubit, ContactUsState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomtextFormFieldBorder(
                        hintText: "Your Name",
                        readOnly: true,
                        textEditingController: nameController,
                      ),
                      const SizedBox(height: 10),
                      CustomtextFormFieldBorder(
                        hintText: "Your Email",
                        readOnly: true,
                        textEditingController: emailController,
                      ),
                      const SizedBox(height: 10),
                      CustomtextFormFieldBorder(
                        hintText: "Your Phone Number",
                        readOnly: true,
                        textEditingController: phoneController,
                      ),
                      const SizedBox(height: 10),
                      CustomtextFormFieldBorder(
                        hintText: "Your Message/Enquiry",
                        textEditingController: messageController,
                        maxLines: 10,
                      ),
                      const SizedBox(height: 10),
                      state is ContactUsLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SubmitButton(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<ContactUsCubit>(
                                    context,
                                  ).submitContactUs(
                                    name: nameController.text,
                                    email: emailController.text,
                                    phone: phoneController.text,
                                    message: messageController.text,
                                  );
                                } else {
                                  showToast("Fill the details", context);
                                }
                              },
                              title: 'SUBMIT',
                            ),
                    ],
                  ),
                ),
              );
            },
            listener: (context, state) => {
              if (state is ContactUsSuccess)
                {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/checked.png',
                                height: 120,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Thank you for reaching out to us. We have received your message and will get back to you as soon as possible.",
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                }
              else if (state is ContactUsFailure)
                {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Icon(Icons.error_outline, size: 60.sp),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              state.message,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                },
            },
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    Provider.of<StudentProvider>(context, listen: false).getStudents();
    nameController = TextEditingController(
      text: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).studentsModel!.parent.name,
    );

    emailController = TextEditingController(
      text: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).studentsModel!.parent.email,
    );

    phoneController = TextEditingController(
      text: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).studentsModel!.parent.mobile,
    );

    super.didChangeDependencies();
  }
}
