import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/views/components/custom_text_field.dart';

class ReasonSelectWidget extends StatefulWidget {
  final String hintText;

  final TextEditingController searchController;
  const ReasonSelectWidget({
    super.key,
    required this.hintText,
    required this.searchController,
  });

  @override
  _ReasonSelectWidgetState createState() => _ReasonSelectWidgetState();
}

class _ReasonSelectWidgetState extends State<ReasonSelectWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomtextFormFieldBorder(
      readOnly: true,
      hintText: widget.hintText,
      textEditingController: widget.searchController,
      onTap: () {
        Provider.of<LeaveProvider>(context, listen: false).getLeaveReaonsList();
        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => Center(
              child: Dialog(
                child: Consumer<LeaveProvider>(
                  builder: (context, value, child) =>
                      value.leaveReasonFetchState == AppStates.Initial_Fetching
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: value.leaveReasonList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Provider.of<LeaveProvider>(
                                  context,
                                  listen: false,
                                ).updateLeaveReson(
                                  value.leaveReasonList[index],
                                );
                                setState(() {
                                  widget.searchController.text =
                                      value.leaveReasonList[index].listValue;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      //                    <--- top side
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    value.leaveReasonList[index].listValue,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        );
        // showSearch(
        //   context: context,
        //   delegate:
        //       DataSearch(widget.items, widget.searchController, _filteredItems),
        //  );
      },
    );
  }
}
