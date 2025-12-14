import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Helper function to parse date from various formats
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

  // Helper function to format date as DD/MM/YYYY for API
  String _formatDateForAPI(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper function to format date for display
  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

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
                            maxLength: 15,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Please enter Emirates ID";
                              }
                              if (val.trim().length != 15) {
                                return "Emirates ID must be 15 digits";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomtextFormFieldBorder(
                            hintText: "Emirates ID Expiry date",
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
                              if (selectedDate.isBefore(todayDate) ||
                                  selectedDate.isAtSameMomentAs(todayDate)) {
                                return "Expiry date must be in the future";
                              }
                              return null;
                            },
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
      // Parse and format the expiry date for display
      final parsedDate = _parseDate(data.emiratesIdExp);
      if (parsedDate != null) {
        final today = DateTime.now();
        final selectedDate = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );
        final todayDate = DateTime(today.year, today.month, today.day);
        // If the existing date is in the past, set it to tomorrow
        if (selectedDate.isBefore(todayDate) ||
            selectedDate.isAtSameMomentAs(todayDate)) {
          final tomorrow = todayDate.add(const Duration(days: 1));
          _expiryController.text = _formatDateForDisplay(tomorrow);
        } else {
          _expiryController.text = _formatDateForDisplay(parsedDate);
        }
      } else {
        // If date can't be parsed, set to tomorrow
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        _expiryController.text = _formatDateForDisplay(tomorrow);
      }
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

    // Parse the date from the controller and format it for API (DD/MM/YYYY)
    final parsedDate = _parseDate(_expiryController.text.trim());
    if (parsedDate == null) {
      showToast("Invalid date format. Please select a valid date.", context);
      return;
    }

    // Validate that the date is in the future
    final today = DateTime.now();
    final selectedDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    if (selectedDate.isBefore(todayDate) ||
        selectedDate.isAtSameMomentAs(todayDate)) {
      showToast("Expiry date must be in the future.", context);
      return;
    }

    final formattedDate = _formatDateForAPI(parsedDate);

    final success = await provider.updateStudentDocumentDetails(
      studCode: data.studcode,
      emiratesId: _emiratesIdController.text.trim(),
      emiratesIdExp: formattedDate,
      context: context,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    DateTime initialDate = tomorrow;

    // Try to parse the current date from the controller
    final parsedDate = _parseDate(_expiryController.text);
    if (parsedDate != null) {
      final selectedDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );
      // Only use parsed date if it's in the future
      if (selectedDate.isAfter(today)) {
        initialDate = parsedDate;
      }
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
      firstDate: tomorrow, // Start from tomorrow, not allowing past dates
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _expiryController.text = _formatDateForDisplay(pickedDate);
      });
    }
  }
}
