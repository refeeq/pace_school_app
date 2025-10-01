import 'package:flutter/material.dart';

import '../../core/themes/const_colors.dart';

class PinBox extends StatelessWidget {
  final Function(String) onSaved;
  const PinBox({
    super.key,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 64,
        width: MediaQuery.of(context).size.width / 7,
        child: TextFormField(
          autofocus: true,
          //onSaved: onSaved,
          onChanged: (value) {
            // if (value.length == 1) {
            onSaved(value);
            //   FocusScope.of(context).nextFocus();
            // } else {
            //   FocusScope.of(context).previousFocus();
            // }
          },
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counterText: "",
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: ConstColors.primary,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
