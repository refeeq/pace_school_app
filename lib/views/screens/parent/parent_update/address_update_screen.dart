import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
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
              CustomtextFormFieldBorder(
                hintText: "Home address / Area",
                textEditingController: _homeAddressController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              CustomtextFormFieldBorder(
                hintText: "Flat number",
                textEditingController: _flatNoController,
              ),
              const SizedBox(height: 12),
              CustomtextFormFieldBorder(
                hintText: "Building name",
                textEditingController: _buildingNameController,
              ),
              const SizedBox(height: 12),
              CustomtextFormFieldBorder(
                hintText: "Community / Contact number",
                textEditingController: _comNumberController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomtextFormFieldBorder(
                hintText: "Community ID (optional)",
                textEditingController: _communityIdController,
                keyboardType: TextInputType.number,
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

