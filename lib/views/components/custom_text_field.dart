import 'package:flutter/material.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_text_style.dart';

class CustomtextFormField extends StatefulWidget {
  final bool readOnly;
  final bool? enabled;
  final Widget? suffix;
  final TextEditingController? textEditingController;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  const CustomtextFormField({
    super.key,
    required this.hintText,
    this.textEditingController,
    this.suffix,
    this.readOnly = false,
    this.enabled,
    this.validator,
    this.onTap,
    this.keyboardType,
  });

  @override
  State<CustomtextFormField> createState() => _CustomtextFormFieldState();
}

class CustomtextFormFieldBorder extends StatelessWidget {
  final bool readOnly;
  final bool? enabled;
  final Widget? suffix;
  final TextEditingController? textEditingController;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final void Function()? onTap;
  final Function(String)? onChanged;
  const CustomtextFormFieldBorder({
    super.key,
    required this.hintText,
    this.textEditingController,
    this.suffix,
    this.readOnly = false,
    this.enabled,
    this.validator,
    this.maxLength,
    this.maxLines,
    this.onTap,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      onTap: onTap,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      controller: textEditingController,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: ConstColors.filledColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: ConstColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: ConstColors.borderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: ConstColors.borderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: ConstColors.borderColor),
        ),
        suffix: suffix,
        hintText: hintText,
        hintStyle: textStyleForm,
      ),
    );
  }
}

class _CustomtextFormFieldState extends State<CustomtextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      controller: widget.textEditingController,
      decoration: InputDecoration(
        suffix: widget.suffix,
        labelText: widget.hintText,
        hintStyle: textStyleForm,
      ),
    );
  }
}
