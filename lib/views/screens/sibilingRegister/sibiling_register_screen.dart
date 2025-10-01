import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/admission_det_model.dart';
import 'package:school_app/core/models/siblinf_register_model.dart';
import 'package:school_app/core/provider/admission_register_provider.dart';
import 'package:school_app/core/themes/const_box_decoration.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/search_alert_list_widget.dart';

class SibilingRegisterScreen extends StatefulWidget {
  const SibilingRegisterScreen({super.key});

  @override
  State<SibilingRegisterScreen> createState() => _SibilingRegisterScreenState();
}

class TitleBox extends StatelessWidget {
  final String title;
  const TitleBox({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: ConstColors.buttonColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.apply(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _SibilingRegisterScreenState extends State<SibilingRegisterScreen> {
  String? gender;
  Grade? language;
  Grade? ethnicity;
  Grade? nationality;
  Grade? grade;
  Grade? admission;
  final TextEditingController dobController = TextEditingController();
  TextEditingController parentNameController = TextEditingController();
  TextEditingController parentMobController = TextEditingController();
  TextEditingController parentEmailController = TextEditingController();
  TextEditingController parentPlaceController = TextEditingController();
  TextEditingController parentAltMobController = TextEditingController();
  TextEditingController prevoiusSchoolController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();
  TextEditingController prevoiusSchoolCurriculumController =
      TextEditingController();
  TextEditingController acadamicController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController secondLanguageController = TextEditingController();
  TextEditingController ethnicityController = TextEditingController();

  final boxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5.0),
    border: Border.all(color: ConstColors.secondary.withValues(alpha: 0.2)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Sibling Registration", actions: []),
      body: Container(
        decoration: ConstBoxDecoration.whiteDecoration,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12),
          child: Consumer<AdmissionRegisterProvider>(
            builder: (context, value, child) {
              if (value.submitAdmissionFormState == AppStates.Fetched) {
                admission = null;
                parentAltMobController.clear();
                language = null;
              } else if (value.submitAdmissionFormState == AppStates.Error) {}
              return value.submitAdmissionFormState == AppStates.Fetched
                  ? Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/checked.png',
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Thank you for your interest in our school.\nThe admission officer will contact you for further procedures depending upon the seat availability.",
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Consumer<AdmissionRegisterProvider>(
                      builder: (context, provider, child) {
                        switch (provider.admissionFormState) {
                          case AppStates.Unintialized:
                            Future(() => provider.getAdmissionData());
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          case AppStates.Initial_Fetching:
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          case AppStates.Fetched:
                            parentNameController = TextEditingController(
                              text: provider.admissionResModel!.family!.fname,
                            );
                            parentMobController = TextEditingController(
                              text: provider.admissionResModel!.family!.mobile,
                            );
                            parentEmailController = TextEditingController(
                              text: provider.admissionResModel!.family!.email,
                            );
                            parentPlaceController = TextEditingController(
                              text: provider.admissionResModel!.family!.homeadd,
                            );
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TitleBox(title: "Parent Info"),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      readOnly: true,
                                      textEditingController:
                                          parentNameController,
                                      hintText: "Name of Parent",
                                      // keyboardType: TextInputType.number,
                                      //  textEditingController: phoneController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      readOnly: true,
                                      textEditingController:
                                          parentEmailController,
                                      hintText: "Email of Parent",

                                      //  textEditingController: phoneController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      readOnly: true,
                                      textEditingController:
                                          parentMobController,
                                      hintText: "Phone Number of Parent",
                                      keyboardType: TextInputType.number,
                                      //  textEditingController: phoneController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      textEditingController:
                                          parentAltMobController,
                                      hintText:
                                          "Secondary Phone Number of Parent",
                                      keyboardType: TextInputType.number,
                                      //  textEditingController: phoneController,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      textEditingController:
                                          parentPlaceController,
                                      hintText: "Location",
                                      keyboardType: TextInputType.text,
                                      //  textEditingController: phoneController,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const TitleBox(title: "Student Info"),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: SearchAlertListWidget(
                                      showSearch: false,
                                      items: provider.admissionResModel!.acYear,
                                      callback: (p0) {
                                        setState(() {
                                          admission = p0;
                                        });
                                      },
                                      hintText: 'Academic Year',
                                      searchController: acadamicController,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      textEditingController:
                                          studentNameController,
                                      hintText: "Name of Student",
                                      //  keyboardType: TextInputType.number,
                                      //  textEditingController: phoneController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: SearchAlertListWidget(
                                      searchController: genderController,
                                      showSearch: false,
                                      items: [
                                        Grade(
                                          listKey: "Male",
                                          listValue: "Male",
                                        ),
                                        Grade(
                                          listKey: "Female",
                                          listValue: "Female",
                                        ),
                                      ],
                                      callback: (p0) {
                                        setState(() {
                                          gender = p0!.listValue;
                                        });
                                      },
                                      hintText: 'Select Gender',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      textEditingController: dobController,
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime?
                                        pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(
                                            2000,
                                          ), //DateTime.now() - not to allow to choose before today.
                                          lastDate: DateTime.now(),
                                        );

                                        if (pickedDate != null) {
                                          debugPrint(
                                            pickedDate.toString(),
                                          ); //pickedDate output format => 2021-03-10 00:00:00.000
                                          String formattedDate = DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(pickedDate);
                                          debugPrint(
                                            formattedDate,
                                          ); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement

                                          setState(() {
                                            dobController.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                        } else {
                                          debugPrint("Date is not selected");
                                        }
                                      },
                                      hintText: "Date of Birth",
                                      keyboardType: TextInputType.number,
                                      //  textEditingController: phoneController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: SearchAlertListWidget(
                                      items: provider
                                          .admissionResModel!
                                          .nationality,
                                      callback: (p0) {
                                        setState(() {
                                          nationality = p0;
                                        });
                                      },
                                      hintText: 'Select Nationality',
                                      searchController: nationalityController,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: Text(
                                      "Do you require school transportation	?",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: RadioGroup<String>(
                                      groupValue: provider.transportation,
                                      onChanged: (value) {
                                        provider.updateTransportation(value!);
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: RadioListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: const Text("YES"),
                                              value: "YES",
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: RadioListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: const Text("NO"),
                                              value: "NO",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const TitleBox(title: "Admission Sought for"),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: SearchAlertListWidget(
                                      items: provider.admissionResModel!.grades,
                                      callback: (p0) {
                                        setState(() {
                                          grade = p0;
                                        });
                                      },
                                      hintText: 'Select Class',
                                      searchController: gradeController,
                                    ),
                                  ),
                                  provider.admissionResModel!.sl.isNotEmpty
                                      ? const SizedBox(height: 10)
                                      : const SizedBox(),
                                  provider.admissionResModel!.sl.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                          ),
                                          child: SearchAlertListWidget(
                                            showSearch: false,
                                            items:
                                                provider.admissionResModel!.sl,
                                            callback: (p0) {
                                              setState(() {
                                                language = p0;
                                              });
                                            },
                                            hintText: 'Select Second Language',
                                            searchController:
                                                secondLanguageController,
                                          ),
                                        )
                                      : const SizedBox(),
                                  provider.admissionResModel!.sl.isNotEmpty
                                      ? const SizedBox(height: 10)
                                      : const SizedBox(),
                                  provider
                                          .admissionResModel!
                                          .ethnicity
                                          .isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                          ),
                                          child: SearchAlertListWidget(
                                            items: provider
                                                .admissionResModel!
                                                .ethnicity,
                                            callback: (p0) {
                                              setState(() {
                                                ethnicity = p0;
                                              });
                                            },
                                            hintText: 'Select Ethnicity',
                                            searchController:
                                                ethnicityController,
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(height: 10),
                                  const TitleBox(title: "Previous School"),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      hintText: "Previous School	",
                                      textEditingController:
                                          prevoiusSchoolController,
                                      //   keyboardType: TextInputType.number,
                                      //  textEditingController: phoneController,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: CustomtextFormFieldBorder(
                                      textEditingController:
                                          prevoiusSchoolCurriculumController,
                                      hintText: "Curriculum	",
                                      //  keyboardType: TextInputType.number,
                                      //  textEditingController: phoneController,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (admission == null) {
                                          showToast(
                                            "Select acadamic year",
                                            context,
                                          );
                                        } else if (provider.transportation ==
                                            null) {
                                          showToast(
                                            "Select transportation",
                                            context,
                                          );
                                        } else if (studentNameController
                                            .text
                                            .isEmpty) {
                                          showToast(
                                            "Student name can't be empty",
                                            context,
                                          );
                                        } else if (gender == null) {
                                          showToast(
                                            "Gender can't be empty",
                                            context,
                                          );
                                        } else if (dobController.text.isEmpty) {
                                          showToast(
                                            "Date Of Birth can't be empty",
                                            context,
                                          );
                                        } else if (nationality == null) {
                                          showToast(
                                            "Nationality can't be empty",
                                            context,
                                          );
                                        } else if (grade == null ||
                                            gradeController.text.isEmpty) {
                                          showToast(
                                            "Grade can't be empty",
                                            context,
                                          );
                                        } else {
                                          SiblingRegisterModel
                                          registerModel = SiblingRegisterModel(
                                            acYear: admission!.listKey,
                                            transport: provider.transportation!,
                                            prevSch:
                                                prevoiusSchoolController.text,
                                            syllabus:
                                                prevoiusSchoolCurriculumController
                                                    .text,
                                            emailAddress:
                                                parentEmailController.text,
                                            phone2: parentAltMobController.text,
                                            phone: parentMobController.text,
                                            fname: parentNameController.text,
                                            landmark: '',
                                            location:
                                                parentPlaceController.text,
                                            secondLang: language == null
                                                ? ""
                                                : language!.listKey,
                                            admGr: grade!.listKey,
                                            reside: '',
                                            dob: dobController.text,
                                            country: nationality!.listKey,
                                            sex: gender!,
                                            name: studentNameController.text,
                                            ethnicity: ethnicity == null
                                                ? ""
                                                : ethnicity!.listKey,
                                          );
                                          provider.admissionregister(
                                            registerModel,
                                            context,
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: ConstColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: 55,
                                        child: const Center(
                                          child: Text(
                                            'SUBMIT',
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
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            );

                          case AppStates.Error:
                            return const Center(child: Text("Error"));
                          case AppStates.NoInterNetConnectionState:
                            return NoInternetConnection(
                              ontap: () async {
                                bool hasInternet = await InternetConnectivity()
                                    .hasInternetConnection;
                                if (!hasInternet) {
                                  showToast("No internet connection!", context);
                                } else {
                                  provider.getAdmissionData();
                                  //   Navigator.pop(context);
                                }
                              },
                            );
                        }
                      },
                    );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    Future(
      () => Provider.of<AdmissionRegisterProvider>(
        context,
        listen: false,
      ).updateSate(),
    );
    super.initState();
  }
}
