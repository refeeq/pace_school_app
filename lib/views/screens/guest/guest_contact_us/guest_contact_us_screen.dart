import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/school_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/from_validators.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/submit_button.dart';
import 'package:school_app/views/screens/contact_us/cubit/contact_us_cubit.dart';

import '../../../components/information_tile.dart';

class GuestContactUsScreen extends StatefulWidget {
  const GuestContactUsScreen({super.key});

  @override
  State<GuestContactUsScreen> createState() => _GuestContactUsScreenState();
}

class _GuestContactUsScreenState extends State<GuestContactUsScreen> {
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
        child: BlocConsumer<ContactUsCubit, ContactUsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomtextFormFieldBorder(
                      hintText: "Your Name",
                      textEditingController: nameController,
                      validator: nameValidator,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 10),
                    CustomtextFormFieldBorder(
                      hintText: "Your Email",
                      textEditingController: emailController,
                      validator: emailValidator,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    CustomtextFormFieldBorder(
                      hintText: "Your Phone Number",
                      textEditingController: phoneController,
                      validator: phoneNumberValidator,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    CustomtextFormFieldBorder(
                      hintText: "Your Message/Enquiry",
                      textEditingController: messageController,
                      maxLines: 10,
                      validator: messageValidator,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 10),
                    state.submissionLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SubmitButton(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                BlocProvider.of<ContactUsCubit>(
                                  context,
                                ).submitContactUsGuest(
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
                    const SizedBox(height: 10),
                    Consumer<SchoolProvider>(
                      builder: (context, value, child) =>
                          value.schoolInfoModel == null
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    value.schoolInfoModel!.whatsapp != null
                                        ? Informationtile(
                                            image: 'assets/Icons/whatsapp.png',
                                            title:
                                                "https://api.whatsapp.com/send?phone=${value.schoolInfoModel!.whatsapp}",
                                            show: true,
                                            title2: "WhatsApp",
                                          )
                                        : const SizedBox(),
                                    value.schoolInfoModel!.facebook != null
                                        ? Informationtile(
                                            image: 'assets/Icons/facebook.png',
                                            title: value
                                                .schoolInfoModel!
                                                .facebook!,
                                            show: true,
                                            title2: "Facebook",
                                          )
                                        : const SizedBox(),
                                    value.schoolInfoModel!.instagram != null
                                        ? Informationtile(
                                            image: 'assets/Icons/instagram.png',
                                            title: value
                                                .schoolInfoModel!
                                                .instagram!,
                                            show: true,
                                            title2: "Instagram",
                                          )
                                        : const SizedBox(),
                                    value.schoolInfoModel!.youtube != null
                                        ? Informationtile(
                                            image: 'assets/Icons/youtube.png',
                                            title:
                                                value.schoolInfoModel!.youtube!,
                                            show: true,
                                            title2: "Youtube",
                                          )
                                        : const SizedBox(),
                                    value.schoolInfoModel!.contact != null
                                        ? Informationtile(
                                            image:
                                                'assets/Icons/phone-call.png',
                                            title:
                                                value.schoolInfoModel!.contact!,
                                          )
                                        : const SizedBox(),
                                    value.schoolInfoModel!.website != null
                                        ? Informationtile(
                                            image:
                                                'assets/Icons/world-wide-web.png',
                                            title:
                                                value.schoolInfoModel!.website!,
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                value.schoolInfoModel!.location_lat != null &&
                                        value.schoolInfoModel!.location_long !=
                                            null
                                    ? InkWell(
                                        onTap: () {
                                          MapsLauncher.launchCoordinates(
                                            double.parse(
                                              value
                                                  .schoolInfoModel!
                                                  .location_lat
                                                  .toString(),
                                            ),
                                            double.parse(
                                              value
                                                  .schoolInfoModel!
                                                  .location_long
                                                  .toString(),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 200,
                                          child: FlutterMap(
                                            options: MapOptions(
                                              initialCenter: LatLng(
                                                double.parse(
                                                  value
                                                      .schoolInfoModel!
                                                      .location_lat
                                                      .toString(),
                                                ),
                                                double.parse(
                                                  value
                                                      .schoolInfoModel!
                                                      .location_long
                                                      .toString(),
                                                ),
                                              ),
                                              initialZoom: 16,
                                            ),
                                            children: [
                                              TileLayer(
                                                urlTemplate:
                                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                userAgentPackageName:
                                                    'dev.fleaflet.flutter_map.example',
                                              ),
                                              MarkerLayer(
                                                markers: <Marker>[
                                                  Marker(
                                                    width: 80,
                                                    height: 80,
                                                    point: LatLng(
                                                      double.parse(
                                                        value
                                                            .schoolInfoModel!
                                                            .location_lat
                                                            .toString(),
                                                      ),
                                                      double.parse(
                                                        value
                                                            .schoolInfoModel!
                                                            .location_long
                                                            .toString(),
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.pin_drop_sharp,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(height: 20),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
          listener: (context, state) => {
            if (state.submissionSuccessMessage != null)
              {
                nameController.clear(),
                emailController.clear(),
                phoneController.clear(),
                messageController.clear(),
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
            else if (state.submissionFailureMessage != null)
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
                          Center(child: Icon(Icons.error_outline, size: 60.sp)),
                          const SizedBox(height: 20),
                          Text(
                            state.submissionFailureMessage!,
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
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
