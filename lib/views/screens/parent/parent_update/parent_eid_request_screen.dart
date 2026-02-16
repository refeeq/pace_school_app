import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';

class ParentEidRequestScreen extends StatefulWidget {
  final String relation; // "Father" or "Mother"

  const ParentEidRequestScreen({super.key, required this.relation});

  @override
  State<ParentEidRequestScreen> createState() => _ParentEidRequestScreenState();
}

class _ParentEidRequestScreenState extends State<ParentEidRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emiratesIdController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  String? _documentPath;

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

  /// Pre-populate Emirates ID and expiry from parent profile (parentProfileTab API).
  /// Matches logic used on student EID update screen.
  void _prePopulateFromParentProfile() {
    final parentProvider = Provider.of<ParentProvider>(context, listen: false);
    final common = parentProvider.parentProfileListModel?.common;
    if (common == null) return;

    final isMother = widget.relation.toLowerCase() == 'mother';

    // EID number
    final eidValue = isMother ? common.mEid : common.fEid;
    final eidStr = eidValue == null
        ? ''
        : (eidValue is String ? eidValue : eidValue.toString()).trim();
    if (eidStr.isNotEmpty && eidStr != 'null') {
      _emiratesIdController.text = eidStr;
    }

    // Expiry date (same behaviour as student EID screen)
    final expValue = isMother ? common.mEidExp : common.fEidExp;
    final expStr = expValue == null
        ? ''
        : (expValue is String ? expValue : expValue.toString()).trim();
    final parsedDate = _parseDate(expStr.isEmpty || expStr == 'null' ? null : expStr);
    if (parsedDate != null) {
      final today = DateTime.now();
      final selectedDate =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      if (!selectedDate.isAfter(todayDate)) {
        final tomorrow = todayDate.add(const Duration(days: 1));
        _expiryController.text = _formatDateForDisplay(tomorrow);
      } else {
        _expiryController.text = _formatDateForDisplay(parsedDate);
      }
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _expiryController.text = _formatDateForDisplay(tomorrow);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _prePopulateFromParentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<ParentUpdateProvider>(context);
    final key =
        widget.relation.toLowerCase() == 'mother' ? 'mother_eid' : 'father_eid';
    final isLoading = updateProvider.stateFor(key) == AppStates.Initial_Fetching;

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar:
          CommonAppBar(title: 'Request ${widget.relation} Emirates ID Update'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Enter Emirates ID and expiry date, then attach the Emirates ID document.",
                style: GoogleFonts.nunitoSans(fontSize: 17),
              ),
              const SizedBox(height: 20),
              CustomtextFormFieldBorder(
                enabled: true,
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
                  if (!selectedDate.isAfter(todayDate)) {
                    return "Expiry date must be in the future";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                "Emirates ID document (PDF or image)",
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
    if (!_formKey.currentState!.validate()) return;
    if (_documentPath == null || _documentPath!.isEmpty) {
      showToast("Please attach Emirates ID document", context, type: ToastType.error);
      return;
    }

    final parsedDate = _parseDate(_expiryController.text.trim());
    if (parsedDate == null) {
      showToast("Invalid date format. Please select a valid date.", context, type: ToastType.error);
      return;
    }

    final today = DateTime.now();
    final selectedDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    if (!selectedDate.isAfter(todayDate)) {
      showToast("Expiry date must be in the future.", context, type: ToastType.error);
      return;
    }

    final formattedDate = _formatDateForAPI(parsedDate);

    final updateProvider =
        Provider.of<ParentUpdateProvider>(context, listen: false);

    final bool success;
    if (widget.relation.toLowerCase() == 'mother') {
      success = await updateProvider.submitMotherEidRequest(
        emiratesId: _emiratesIdController.text.trim(),
        expiryDate: formattedDate,
        documentPath: _documentPath!,
        context: context,
      );
    } else {
      success = await updateProvider.submitFatherEidRequest(
        emiratesId: _emiratesIdController.text.trim(),
        expiryDate: formattedDate,
        documentPath: _documentPath!,
        context: context,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

