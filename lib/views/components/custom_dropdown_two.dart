import 'package:flutter/material.dart';
import 'package:school_app/core/models/admission_det_model.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_text_style.dart';

class CustomDropdownTwo<T> extends StatefulWidget {
  final List<Grade?> modelList;
  final Grade? model;
  final Function(Grade?) callback;
  final String hint;
  const CustomDropdownTwo({
    super.key,
    required this.modelList,
    required this.model,
    required this.callback,
    required this.hint,
  });
  @override
  State<CustomDropdownTwo<T>> createState() => _CustomDropdownTwoState<T>();
}

class _CustomDropdownTwoState<T> extends State<CustomDropdownTwo<T>> {
  Grade? labour;

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.modelList.toString());
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: ConstColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Grade>(
            style: textStyleForm,
            underline: const SizedBox(),
            elevation: 0,
            isDense: true,
            hint: Text(
              labour == null ? widget.hint : labour!.listValue.toString(),
              style: labour == null
                  ? textStyleForm
                  : const TextStyle(color: Colors.black),
            ),
            // value: labour,
            items: widget.modelList.map((Grade? value) {
              return DropdownMenuItem<Grade>(
                value: value,
                child: Text(value!.listValue.toString()),
              );
            }).toList(),
            onChanged: (val) {
              widget.callback(val);
              setState(() {
                labour = val;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    labour = widget.model;
  }
}
