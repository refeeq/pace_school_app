import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';

class AddressUpdateScreen extends StatefulWidget {
  const AddressUpdateScreen({super.key});

  @override
  State<AddressUpdateScreen> createState() => _AddressUpdateScreenState();
}

class _AddressUpdateScreenState extends State<AddressUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _flatNoController = TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _comNumberController = TextEditingController();
  final TextEditingController _communityIdController = TextEditingController();

  /// Pre-populate address fields from parent profile (parentProfileTab API).
  /// Matches the pattern used in verify_email, verify_mobile, and parent_eid_request screens.
  void _prePopulateFromParentProfile() {
    final parentProvider = Provider.of<ParentProvider>(context, listen: false);
    final common = parentProvider.parentProfileListModel?.common;
    if (common == null) return;

    _setController(
      _homeAddressController,
      common.homeadd,
    );
    _setController(
      _flatNoController,
      common.flatNo,
    );
    _setController(
      _buildingNameController,
      common.buildingName,
    );
    _setController(
      _comNumberController,
      common.comNumber,
    );
    _setController(
      _communityIdController,
      common.communityId,
    );
  }

  void _setController(TextEditingController ctrl, dynamic value) {
    final str = value == null
        ? ''
        : (value is String ? value : value.toString()).trim();
    if (str.isNotEmpty && str != 'null') {
      ctrl.text = str;
    }
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        child,
      ],
    );
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
    final isLoading =
        updateProvider.stateFor('address') == AppStates.Initial_Fetching;

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: 'Request Address Update'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Update your family address details. Changes will be applied after school approval.",
                style: GoogleFonts.nunitoSans(fontSize: 17),
              ),
              const SizedBox(height: 20),
              _buildLabeledField(
                label: "Home address / Area",
                child: CustomtextFormFieldBorder(
                  hintText: "Enter home address or area",
                  textEditingController: _homeAddressController,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildLabeledField(
                label: "Flat number",
                child: CustomtextFormFieldBorder(
                  hintText: "Enter flat number",
                  textEditingController: _flatNoController,
                ),
              ),
              const SizedBox(height: 12),
              _buildLabeledField(
                label: "Building name",
                child: CustomtextFormFieldBorder(
                  hintText: "Enter building name",
                  textEditingController: _buildingNameController,
                ),
              ),
              const SizedBox(height: 12),
              _buildLabeledField(
                label: "Community / Contact number",
                child: CustomtextFormFieldBorder(
                  hintText: "Enter contact number",
                  textEditingController: _comNumberController,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 12),
              _buildLabeledField(
                label: "Community ID (optional)",
                child: CustomtextFormFieldBorder(
                  hintText: "Enter community ID if applicable",
                  textEditingController: _communityIdController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You can leave fields empty if they don't need changes. "
                "At least one field should be updated.",
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

  Future<void> _onSubmit() async {
    if (_homeAddressController.text.trim().isEmpty &&
        _flatNoController.text.trim().isEmpty &&
        _buildingNameController.text.trim().isEmpty &&
        _comNumberController.text.trim().isEmpty &&
        _communityIdController.text.trim().isEmpty) {
      showToast("Please update at least one field", context, type: ToastType.error);
      return;
    }

    int? communityId;
    if (_communityIdController.text.trim().isNotEmpty) {
      communityId = int.tryParse(_communityIdController.text.trim());
      if (communityId == null) {
        showToast("Community ID must be a number", context, type: ToastType.error);
        return;
      }
    }

    final updateProvider =
        Provider.of<ParentUpdateProvider>(context, listen: false);
    final success = await updateProvider.submitAddressRequest(
      homeAddress: _homeAddressController.text.trim().isEmpty
          ? null
          : _homeAddressController.text.trim(),
      flatNo: _flatNoController.text.trim().isEmpty
          ? null
          : _flatNoController.text.trim(),
      buildingName: _buildingNameController.text.trim().isEmpty
          ? null
          : _buildingNameController.text.trim(),
      comNumber: _comNumberController.text.trim().isEmpty
          ? null
          : _comNumberController.text.trim(),
      communityId: communityId,
      context: context,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

