import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/student_detail_model.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/slect_student.dart';

class StudentPassportRequestScreen extends StatefulWidget {
  const StudentPassportRequestScreen({super.key});

  @override
  State<StudentPassportRequestScreen> createState() =>
      _StudentPassportRequestScreenState();
}

class _StudentPassportRequestScreenState
    extends State<StudentPassportRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passportNumberController =
      TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  String? _documentPath;
  String? _lastFilledStudcode;
  bool _initialLoadDone = false;

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final formats = [
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat.yMMMd(),
    ];
    for (final f in formats) {
      try {
        return f.parse(dateStr);
      } catch (_) {}
    }
    return null;
  }

  String _formatDateForAPI(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _fillFormFromStudentData(Data data) {
    _passportNumberController.text = data.passno;
    final parsedDate = _parseDate(data.ppExpDate);
    if (parsedDate != null) {
      // Show actual expiry from API (even if past) so user sees current record
      _expiryController.text = _formatDateForDisplay(parsedDate);
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _expiryController.text = _formatDateForDisplay(tomorrow);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<ParentUpdateProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final isLoading =
        updateProvider.stateFor('student_passport') == AppStates.Initial_Fetching;

    // Ensure we load the selected student's details when screen opens or student changes
    if (!_initialLoadDone &&
        studentProvider.studentsModel != null &&
        studentProvider.studentsModel!.data.isNotEmpty) {
      _initialLoadDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final sp = Provider.of<StudentProvider>(context, listen: false);
        final selected = sp.selectedStudentModel(context);
        final currentDetail = sp.studentDetailModel?.data;
        if (currentDetail == null || currentDetail.studcode != selected.studcode) {
          sp.getStudentDetail(studCode: selected.studcode);
        } else if (_lastFilledStudcode != currentDetail.studcode) {
          _fillFormFromStudentData(currentDetail);
          setState(() => _lastFilledStudcode = currentDetail.studcode);
        }
      });
    }

    final data = studentProvider.studentDetailModel?.data;
    if (data != null && data.studcode != _lastFilledStudcode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fillFormFromStudentData(data);
          setState(() => _lastFilledStudcode = data.studcode);
        }
      });
    }

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: 'Request Passport Update'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            child: SelectStudentWidget(
              onchanged: (index) {
                final sp = Provider.of<StudentProvider>(context, listen: false);
                sp.getStudentDetail(
                  studCode: sp.studentsModel!.data[index].studcode,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, sp, _) {
                switch (sp.studentDetail) {
                  case AppStates.Initial_Fetching:
                    return const Center(child: CircularProgressIndicator());
                  case AppStates.Fetched:
                    if (sp.studentDetailModel?.data == null) {
                      return const Center(
                          child: Text('No student details available'));
                    }
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "Update passport number or expiry date and attach the passport document.",
                              style: GoogleFonts.nunitoSans(fontSize: 17),
                            ),
                            const SizedBox(height: 20),
                            CustomtextFormFieldBorder(
                              enabled: true,
                              hintText: "Passport Number",
                              keyboardType: TextInputType.text,
                              textEditingController: _passportNumberController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                              ],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Please enter passport number";
                                }
                                if (val.trim().length < 4) {
                                  return "Passport number must be at least 4 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomtextFormFieldBorder(
                              hintText: "Passport Expiry Date",
                              readOnly: true,
                              textEditingController: _expiryController,
                              onTap: _pickDate,
                              suffix: const Icon(Icons.calendar_today),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Please select expiry date";
                                }
                                final parsedDate = _parseDate(val.trim());
                                if (parsedDate == null) {
                                  return "Invalid date format";
                                }
                                final today = DateTime.now();
                                final selectedDate = DateTime(
                                  parsedDate.year,
                                  parsedDate.month,
                                  parsedDate.day,
                                );
                                final todayDate = DateTime(
                                  today.year,
                                  today.month,
                                  today.day,
                                );
                                if (!selectedDate.isAfter(todayDate)) {
                                  return "Expiry date must be in the future";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Passport document (PDF or image)",
                              style: GoogleFonts.nunitoSans(),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _pickDocument,
                              icon: const Icon(Icons.attach_file),
                              label: Text(
                                _documentPath == null
                                    ? 'Choose file'
                                    : File(_documentPath!).path.split('/').last,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Allowed formats: PDF, JPG, JPEG, PNG",
                              style: GoogleFonts.nunitoSans(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: isLoading ? null : _onSubmit,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isLoading ? Colors.grey : ConstColors.primary,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "SUBMIT REQUEST",
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    DateTime initialDate = tomorrow;

    final parsedDate = _parseDate(_expiryController.text);
    if (parsedDate != null && parsedDate.isAfter(today)) {
      initialDate = parsedDate;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tomorrow,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: ConstColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _expiryController.text = _formatDateForDisplay(pickedDate);
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _documentPath = result.files.single.path!;
        });
      }
    } catch (e) {
      showToast("Failed to pick file", context, type: ToastType.error);
    }
  }

  Future<void> _onSubmit() async {
    final passportNumber = _passportNumberController.text.trim();
    if (passportNumber.isEmpty) {
      showToast("Please enter passport number", context, type: ToastType.error);
      return;
    }
    if (passportNumber.length < 4) {
      showToast("Passport number must be at least 4 characters", context, type: ToastType.error);
      return;
    }
    final expiryText = _expiryController.text.trim();
    if (expiryText.isEmpty) {
      showToast("Please select passport expiry date", context, type: ToastType.error);
      return;
    }
    final parsedDate = _parseDate(expiryText);
    if (parsedDate == null) {
      showToast("Invalid expiry date format", context, type: ToastType.error);
      return;
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    if (!selectedDate.isAfter(todayDate)) {
      showToast("Expiry date must be in the future", context, type: ToastType.error);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_documentPath == null || _documentPath!.isEmpty) {
      showToast("Please attach passport document", context, type: ToastType.error);
      return;
    }

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final data = studentProvider.studentDetailModel?.data;

    if (data == null) {
      showToast("Student details not available", context, type: ToastType.error);
      return;
    }

    final formattedDate = _formatDateForAPI(parsedDate);

    final updateProvider =
        Provider.of<ParentUpdateProvider>(context, listen: false);
    final success = await updateProvider.submitStudentPassportRequest(
      admissionNo: data.studcode,
      passportNumber: passportNumber,
      expiryDate: formattedDate,
      documentPath: _documentPath!,
      context: context,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

