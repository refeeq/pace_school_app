import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/parent_update_request_model.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';

class ParentUpdateHistoryScreen extends StatefulWidget {
  const ParentUpdateHistoryScreen({super.key});

  @override
  State<ParentUpdateHistoryScreen> createState() =>
      _ParentUpdateHistoryScreenState();
}

class _ParentUpdateHistoryScreenState extends State<ParentUpdateHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future(() {
      Provider.of<ParentUpdateProvider>(context, listen: false)
          .fetchParentUpdateRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: 'Change Request History'),
      body: Consumer<ParentUpdateProvider>(
        builder: (context, value, child) {
          switch (value.historyState) {
            case AppStates.Unintialized:
            case AppStates.Initial_Fetching:
              return Center(
                child: CircularProgressIndicator(
                  color: ConstColors.primary,
                ),
              );
            case AppStates.NoInterNetConnectionState:
              return NoInternetConnection(
                ontap: () {
                  value.fetchParentUpdateRequests();
                },
              );
            case AppStates.Error:
              return const Center(
                child: NoDataWidget(
                  imagePath: 'assets/images/no_data.svg',
                  content: 'Something went wrong. Please try again later.',
                ),
              );
            case AppStates.Fetched:
              final model = value.historyModel;
              if (model == null || model.data.isEmpty) {
                return const Center(
                  child: NoDataWidget(
                    imagePath: 'assets/images/no_data.svg',
                    content: 'No requests found.',
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: model.data.length,
                itemBuilder: (context, index) {
                  final item = model.data[index];
                  return _HistoryCard(item: item);
                },
              );
          }
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ParentUpdateRequest item;

  const _HistoryCard({required this.item});

  Color _statusColor() {
    if (item.isApproved) return const Color(0xFF2E7D32);
    if (item.isRejected) return const Color(0xFFC62828);
    return const Color(0xFFE65100);
  }

  IconData _statusIcon() {
    if (item.isApproved) return Icons.check_circle_outline;
    if (item.isRejected) return Icons.cancel_outlined;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ConstColors.borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: (item.remark != null && item.remark!.isNotEmpty)
            ? () => _showRemarkDialog(context)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Request type + Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.requestTypeLabel,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ConstColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(), size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          item.approvalStatusLabel,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: ConstColors.borderColor),
              const SizedBox(height: 14),

              // Request ID
              _DetailRow(
                label: 'Request ID',
                value: '#${item.id}',
              ),
              if (item.studcode != null && item.studcode!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Student Code',
                  value: item.studcode!,
                ),
              ],
              if (item.newValue != null && item.newValue!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'New Value',
                  value: item.newValue!,
                ),
              ],
              if (item.expiryDate != null && item.expiryDate!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Expiry Date',
                  value: item.expiryDate!,
                ),
              ],
              if (item.dateRequested != null && item.dateRequested!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Date Requested',
                  value: item.dateRequested!,
                ),
              ],
              if (item.approvedAt != null && item.approvedAt!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Approved / Processed On',
                  value: item.approvedAt!,
                ),
              ],

              // Remark section
              if (item.remark != null && item.remark!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: ConstColors.borderColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: ConstColors.primary.withOpacity(0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Remarks',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ConstColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ConstColors.blueColorTwo.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ConstColors.borderColor,
                    ),
                  ),
                  child: Text(
                    item.remark!,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      height: 1.4,
                      color: const Color(0xFF37474F),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tap card to view full remark',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRemarkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.comment_outlined, color: ConstColors.primary),
            const SizedBox(width: 8),
            Text(
              'Remarks',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w700,
                color: ConstColors.primary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            item.remark ?? '',
            style: GoogleFonts.nunitoSans(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w600,
                color: ConstColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF263238),
            ),
          ),
        ),
      ],
    );
  }
}
