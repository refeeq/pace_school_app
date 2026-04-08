import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/screens/family_fee/cubit/family_fee_cubit.dart';
import 'package:school_app/views/screens/family_fee/models/family_fee_item_fee_model.dart';
import 'package:school_app/views/screens/family_fee/models/family_fee_model.dart';

class FamilyTile extends StatefulWidget {
  final FamilyFeeModel family;
  final String studcode;

  final bool isMandatory;
  // final StudentFeeProvider feesProvider;
  final int index;
  final FamilyFeeItemFee feeModel;
  const FamilyTile({
    super.key,
    required this.feeModel,
    required this.index,
    required this.family,
    required this.isMandatory,
    required this.studcode,
    // required this.feesProvider
  });

  @override
  State<FamilyTile> createState() => _FamilyTileState();
}

class _FamilyTileState extends State<FamilyTile> {
  bool isCheckedBox = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEFF1F5)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.grey),
                child: CheckboxListTile(
                  enabled: !widget.isMandatory,
                  value: widget.feeModel.isSelected,
                  onChanged: (newValue) async {
                    BlocProvider.of<FamilyFeeCubit>(
                      context,
                    ).updateOrAddFeeAmount(
                      widget.family,
                      widget.studcode,
                      widget.feeModel,
                      newValue!,
                      widget.index,
                    );
                    // setState(() {
                    //   widget.feeModel.isSelected;
                    // });

                    // if (newValue!) {
                    //   for (var i = 0; i < widget.index + 1; i++) {
                    //     log("message $i");
                    //     log("index ${widget.index}");
                    //     provider.updateValue(i, newValue);
                    //   }
                    // } else {
                    //   for (var i = widget.index;
                    //       i < widget.feesProvider.feeslistnew.length;
                    //       i++) {
                    //     log("message $i");
                    //     log("index ${widget.index}");
                    //     provider.updateValue(i, newValue);
                    //   }
                    // }
                  },
                  title: Text(
                    widget.feeModel.description,
                    style: Theme.of(context).textTheme.titleSmall,
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
                            textStyle: Theme.of(context).textTheme.bodyMedium,
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
    );
  }
}
