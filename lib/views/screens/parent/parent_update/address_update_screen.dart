import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/parent_profile_list_model.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_text_style.dart';
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

  List<Emirate> _emirates = [];
  List<Community> _communities = [];
  Emirate? _selectedEmirate;
  Community? _selectedCommunity;

  List<Community> get _filteredCommunities {
    if (_selectedEmirate == null) return [];
    return _communities
        .where((c) => c.emirateId == _selectedEmirate!.id)
        .toList();
  }

  /// Pre-populate address fields from parent profile (parentProfileTab API).
  /// Matches the pattern used in verify_email, verify_mobile, and parent_eid_request screens.
  void _prePopulateFromParentProfile() {
    final parentProvider = Provider.of<ParentProvider>(context, listen: false);
    final model = parentProvider.parentProfileListModel;
    final common = model?.common;
    if (common != null) {
      _setController(_homeAddressController, common.homeadd);
      _setController(_flatNoController, common.flatNo);
      _setController(_buildingNameController, common.buildingName);
      _setController(_comNumberController, common.comNumber);
    }

    if (model == null) {
      setState(() {
        _emirates = [];
        _communities = [];
        _selectedEmirate = null;
        _selectedCommunity = null;
      });
      return;
    }

    final emirates = model.emirate;
    final communities = model.community;

    Emirate? preEmirate;
    Community? preCommunity;

    final rawCommunityId = common?.communityId;
    if (rawCommunityId != null) {
      final str = rawCommunityId.toString().trim();
      if (str.isNotEmpty &&
          str.toUpperCase() != 'NIL' &&
          str.toLowerCase() != 'null') {
        final communityIdInt = int.tryParse(str);
        if (communityIdInt != null) {
          try {
            preCommunity = communities.firstWhere(
              (c) => c.id == communityIdInt,
            );
          } catch (_) {
            preCommunity = null;
          }
          if (preCommunity != null) {
            try {
              preEmirate = emirates.firstWhere(
                (e) => e.id == preCommunity!.emirateId,
              );
            } catch (_) {
              preEmirate = null;
            }
          }
        }
      }
    }

    setState(() {
      _emirates = emirates;
      _communities = communities;
      _selectedEmirate = preEmirate;
      _selectedCommunity = preCommunity;
    });
  }

  void _setController(TextEditingController ctrl, dynamic value) {
    final str = value == null
        ? ''
        : (value is String ? value : value.toString()).trim();
    if (str.isNotEmpty && str != 'null') {
      ctrl.text = str;
    }
  }

  void _onEmirateChanged(Emirate? value) {
    setState(() {
      _selectedEmirate = value;
      _selectedCommunity = null;
    });
  }

  void _onCommunityChanged(Community? value) {
    setState(() {
      _selectedCommunity = value;
    });
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

  static const double _kDropdownRadius = 6.0;
  static const double _kDropdownPadding = 14.0;
  static const double _kListItemExtent = 52.0;

  /// Reused for list items to avoid rebuilding TextStyle on every scroll.
  static final _listItemTextStyle = GoogleFonts.nunitoSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  InputDecoration _dropdownDecoration(String hintText, {bool enabled = true}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kDropdownRadius),
      borderSide: BorderSide(color: ConstColors.borderColor),
    );
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: enabled ? ConstColors.filledColor : ConstColors.filledColor.withValues(alpha: 0.6),
      hintText: hintText,
      hintStyle: textStyleForm.copyWith(color: Colors.black45, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: _kDropdownPadding, vertical: _kDropdownPadding),
      focusedBorder: border,
      enabledBorder: border,
      disabledBorder: border.copyWith(borderSide: BorderSide(color: ConstColors.borderColor)),
      errorBorder: border,
      focusedErrorBorder: border,
    );
  }

  PopupProps<Emirate> _emiratePopupProps() {
    return PopupProps.menu(
      showSearchBox: true,
      searchDelay: Duration.zero,
      cacheItems: true,
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: ConstColors.filledColor,
          hintText: 'Search emirate...',
          hintStyle: textStyleForm.copyWith(fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ConstColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ConstColors.primary, width: 1.5),
          ),
        ),
      ),
      menuProps: MenuProps(
        borderRadius: BorderRadius.circular(_kDropdownRadius),
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: ConstColors.filledColor,
      ),
      listViewProps: const ListViewProps(
        itemExtent: _kListItemExtent,
        cacheExtent: 250,
        physics: ClampingScrollPhysics(),
      ),
      itemBuilder: (context, item, isDisabled, isSelected) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: _kDropdownPadding, vertical: 4),
        title: Text(item.emirate, style: _listItemTextStyle),
      ),
      emptyBuilder: (context, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No emirate found',
          style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.black54),
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 320),
    );
  }

  PopupProps<Community> _communityPopupProps() {
    return PopupProps.menu(
      showSearchBox: true,
      searchDelay: Duration.zero,
      cacheItems: true,
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: ConstColors.filledColor,
          hintText: 'Search community...',
          hintStyle: textStyleForm.copyWith(fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ConstColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ConstColors.primary, width: 1.5),
          ),
        ),
      ),
      menuProps: MenuProps(
        borderRadius: BorderRadius.circular(_kDropdownRadius),
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: ConstColors.filledColor,
      ),
      listViewProps: const ListViewProps(
        itemExtent: _kListItemExtent,
        cacheExtent: 250,
        physics: ClampingScrollPhysics(),
      ),
      itemBuilder: (context, item, isDisabled, isSelected) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: _kDropdownPadding, vertical: 4),
        title: Text(item.communityName, style: _listItemTextStyle),
      ),
      emptyBuilder: (context, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          _selectedEmirate == null ? 'Select emirate first' : 'No communities for this emirate',
          style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.black54),
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 320),
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
  void dispose() {
    _homeAddressController.dispose();
    _flatNoController.dispose();
    _buildingNameController.dispose();
    _comNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<ParentUpdateProvider>(context);
    final isLoading =
        updateProvider.stateFor('address') == AppStates.Initial_Fetching;
    final filteredCommunities = _filteredCommunities;

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
                label: "Emirate",
                child: DropdownSearch<Emirate>(
                  selectedItem: _selectedEmirate,
                  itemAsString: (e) => e.emirate,
                  items: (filter, loadProps) => _emirates,
                  compareFn: (a, b) => a.id == b.id,
                  onChanged: _onEmirateChanged,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: _dropdownDecoration("Select emirate"),
                  ),
                  suffixProps: const DropdownSuffixProps(
                    clearButtonProps: ClearButtonProps(isVisible: true),
                  ),
                  popupProps: _emiratePopupProps(),
                  dropdownBuilder: (context, selectedItem) => Text(
                    selectedItem?.emirate ?? "",
                    style: GoogleFonts.nunitoSans(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildLabeledField(
                label: "Community",
                child: DropdownSearch<Community>(
                  selectedItem: _selectedCommunity,
                  itemAsString: (c) => c.communityName,
                  items: (filter, loadProps) => filteredCommunities,
                  compareFn: (a, b) => a.id == b.id,
                  onChanged: _onCommunityChanged,
                  enabled: _selectedEmirate != null,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: _dropdownDecoration(
                      _selectedEmirate == null
                          ? "Select emirate first"
                          : "Select community",
                      enabled: _selectedEmirate != null,
                    ),
                  ),
                  suffixProps: const DropdownSuffixProps(
                    clearButtonProps: ClearButtonProps(isVisible: true),
                  ),
                  popupProps: _communityPopupProps(),
                  dropdownBuilder: (context, selectedItem) => Text(
                    selectedItem?.communityName ?? "",
                    style: GoogleFonts.nunitoSans(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
    final hasTextUpdate =
        _homeAddressController.text.trim().isNotEmpty ||
        _flatNoController.text.trim().isNotEmpty ||
        _buildingNameController.text.trim().isNotEmpty ||
        _comNumberController.text.trim().isNotEmpty;
    final hasCommunitySelection = _selectedCommunity != null;

    if (!hasTextUpdate && !hasCommunitySelection) {
      showToast(
        "Please update at least one field",
        context,
        type: ToastType.error,
      );
      return;
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
      communityId: _selectedCommunity?.id,
      context: context,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
