import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/themes/const_colors.dart';

import '../../core/models/fees_model.dart';
import '../../core/provider/student_fee_provider.dart';

class FeesTileNew extends StatefulWidget {
  final StudentFeeProvider feesProvider;
  final int index;
  final FeesModel feeModel;
  const FeesTileNew({
    super.key,
    required this.feeModel,
    required this.index,
    required this.feesProvider,
  });

  @override
  State<FeesTileNew> createState() => _FeesTileNewState();
}

class _FeesTileNewState extends State<FeesTileNew> {
  bool? checkboxListTileValue1;
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentFeeProvider>(
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
        child: Container(
          decoration: ShapeDecoration(
            color: ConstColors.filledColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: ConstColors.borderColor),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.grey),
                    child: CheckboxListTile(
                      enabled:
                          !widget.feesProvider.feeListModel!.chkboxReadOnly,
                      value: widget.feeModel.isSelected,
                      onChanged: (newValue) async {
                        if (newValue!) {
                          for (var i = 0; i < widget.index + 1; i++) {
                            log("message $i");
                            log("index ${widget.index}");
                            provider.updateValue(i, newValue);
                          }
                        } else {
                          for (
                            var i = widget.index;
                            i < widget.feesProvider.feeslistnew.length;
                            i++
                          ) {
                            log("message $i");
                            log("index ${widget.index}");
                            provider.updateValue(i, newValue);
                          }
                        }
                      },
                      title: Text(
                        widget.feeModel.description,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount: ${widget.feeModel.feeAmt}',
                              style: GoogleFonts.nunitoSans(
                                textStyle: Theme.of(
                                  context,
                                ).textTheme.bodyMedium,
                              ),
                            ),
                            widget.feeModel.vatStat == "1"
                                ? Text(
                                    'VAT: ${widget.feeModel.vatAmt}',
                                    style: GoogleFonts.nunitoSans(
                                      textStyle: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      tileColor: Colors.white,
                      activeColor: ConstColors.primary,
                      checkColor: Colors.white,
                      selectedTileColor: Colors.white,
                      dense: false,
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(
                        8,
                        0,
                        8,
                        0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
