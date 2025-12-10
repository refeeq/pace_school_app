import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';

class EditEmiratesIdScreen extends StatefulWidget {
  const EditEmiratesIdScreen({super.key});

  @override
  State<EditEmiratesIdScreen> createState() => _EditEmiratesIdScreenState();
}

class _EditEmiratesIdScreenState extends State<EditEmiratesIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emiratesIdController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Edit Emirates ID"),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Consumer<StudentProvider>(
              builder: (context, value, child) {
                switch (value.updateStudentDocState) {
                  case AppStates.Unintialized:
                  case AppStates.Fetched:
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Icon(
                              Icons.edit_document,
                              size: 120,
                              color: ConstColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Enter Emirates ID and expiry date to update.",
                            style: GoogleFonts.nunitoSans(fontSize: 17),
                          ),
                          const SizedBox(height: 20),
                          CustomtextFormFieldBorder(
                            hintText: "Emirates ID",
                            keyboardType: TextInputType.number,
                            textEditingController: _emiratesIdController,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? "Please enter Emirates ID"
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomtextFormFieldBorder(
                            hintText: "Emirates ID Expiry date",
                            readOnly: true,
                            textEditingController: _expiryController,
                            onTap: _pickDate,
                            suffix: const Icon(Icons.calendar_today),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? "Please select expiry date"
                                : null,
                          ),
                        ],
                      ),
                    );
                  case AppStates.Initial_Fetching:
                    return Center(child: loader());
                  case AppStates.NoInterNetConnectionState:
                    return NoInternetConnection(ontap: () {});
                  case AppStates.Error:
                    return const NoDataWidget(
                      imagePath: "assets/images/error.svg",
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
            _onSubmit();
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
  void initState() {
    super.initState();
    // Reset without notifying during build to avoid setState-in-build assertion.
    Provider.of<StudentProvider>(
      context,
      listen: false,
    ).resetUpdateStudentDocState(notify: false);
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final data = provider.studentDetailModel?.data;
    if (data != null) {
      _emiratesIdController.text = data.emiratesId;
      _expiryController.text = data.emiratesIdExp;
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<StudentProvider>(context, listen: false);
    final data = provider.studentDetailModel?.data;

    if (data == null) {
      showToast("Student details not available", context);
      return;
    }

    final success = await provider.updateStudentDocumentDetails(
      studCode: data.studcode,
      emiratesId: _emiratesIdController.text.trim(),
      emiratesIdExp: _expiryController.text.trim(),
      context: context,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initialDate;
    try {
      initialDate = DateFormat.yMMMd().parse(_expiryController.text);
    } catch (_) {
      initialDate = now;
    }

    final pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: ConstColors.primary),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _expiryController.text = DateFormat.yMMMd().format(pickedDate);
      });
    }
  }
}
