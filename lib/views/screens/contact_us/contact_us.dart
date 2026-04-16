import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/models/contact_us_history_model.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/components/submit_button.dart';
import 'package:school_app/views/screens/contact_us/cubit/contact_us_cubit.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  bool _historyLoadTriggered = false;

  void _triggerHistoryLoad(BuildContext context) {
    if (_historyLoadTriggered) return;
    _historyLoadTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ContactUsCubit>().loadContactUsHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactUsCubit(),
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (fabContext) => CircleAvatar(
            backgroundColor: ConstColors.primary,
            child: IconButton(
              onPressed: () async {
                final contactUsCubit = fabContext.read<ContactUsCubit>();
                final shouldRefresh = await Navigator.push<bool>(
                  fabContext,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: contactUsCubit,
                      child: const ContactUsFormScreen(),
                    ),
                  ),
                );
                if (shouldRefresh == true && fabContext.mounted) {
                  fabContext.read<ContactUsCubit>().loadContactUsHistory();
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
        backgroundColor: ConstColors.backgroundColor,
        appBar: const CommonAppBar(title: "Contact Us"),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: BlocBuilder<ContactUsCubit, ContactUsState>(
            builder: (context, state) {
              _triggerHistoryLoad(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildHistorySection(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, ContactUsState state) {
    if (state.historyLoading && state.historyList == null) {
      return Shimmer(
        linearGradient: ConstGradient.shimmerGradient,
        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, index) => ShimmerLoading(
            isLoading: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: ConstGradient.shimmerGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (state.historyError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          state.historyError!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }
    final list = state.historyList ?? [];
    if (list.isEmpty) {
      return const Center(
        child: NoDataWidget(
          imagePath: "assets/images/no_messages.svg",
          content:
              "You haven't submitted any contact messages yet. Once you send one, it will appear here.",
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _ContactUsHistoryTile(item: item);
        },
      ),
    );
  }
}

class ContactUsFormScreen extends StatefulWidget {
  const ContactUsFormScreen({super.key});

  @override
  State<ContactUsFormScreen> createState() => _ContactUsFormScreenState();
}

class _ContactUsFormScreenState extends State<ContactUsFormScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    Provider.of<StudentProvider>(context, listen: false).getStudents();
    nameController = TextEditingController(
      text: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).studentsModel!.parent.name,
    );
    emailController = TextEditingController(
      text: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).studentsModel!.parent.email,
    );
    phoneController = TextEditingController(
      text: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).studentsModel!.parent.mobile,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Contact Us Form"),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: BlocConsumer<ContactUsCubit, ContactUsState>(
          listener: (context, state) async {
            if (state.submissionSuccessMessage != null) {
              await showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/checked.png',
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Thank you for reaching out to us. We have received your message and will get back to you as soon as possible.",
                          style: Theme.of(dialogContext).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            } else if (state.submissionFailureMessage != null) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Icon(Icons.error_outline, size: 60.sp),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          state.submissionFailureMessage!,
                          style: Theme.of(dialogContext).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomtextFormFieldBorder(
                      hintText: "Your Name",
                      readOnly: true,
                      textEditingController: nameController,
                    ),
                    const SizedBox(height: 10),
                    CustomtextFormFieldBorder(
                      hintText: "Your Email",
                      readOnly: true,
                      textEditingController: emailController,
                    ),
                    const SizedBox(height: 10),
                    CustomtextFormFieldBorder(
                      hintText: "Your Phone Number",
                      readOnly: true,
                      textEditingController: phoneController,
                    ),
                    const SizedBox(height: 10),
                    CustomtextFormFieldBorder(
                      hintText: "Your Message/Enquiry",
                      textEditingController: messageController,
                      maxLines: 10,
                    ),
                    const SizedBox(height: 10),
                    state.submissionLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SubmitButton(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ContactUsCubit>().submitContactUs(
                                      name: nameController.text,
                                      email: emailController.text,
                                      phone: phoneController.text,
                                      message: messageController.text,
                                    );
                              } else {
                                showToast("Fill the details", context);
                              }
                            },
                            title: 'SUBMIT',
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContactUsHistoryTile extends StatelessWidget {
  final ContactUsHistoryItem item;

  const _ContactUsHistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateStr = item.dateAdded != null
        ? DateFormat('MMM d, y • HH:mm').format(item.dateAdded!)
        : '—';
    final replyDateStr = item.replyDate != null
        ? DateFormat('MMM d, y • HH:mm').format(item.replyDate!)
        : null;
    final statusLabel = item.hasReply && item.reply.isNotEmpty ? 'Replied' : 'Pending';
    final statusColor = item.hasReply && item.reply.isNotEmpty
        ? const Color(0xff2e7d32)
        : const Color(0xffbe8700);
    final statusBg = item.hasReply && item.reply.isNotEmpty
        ? const Color(0xffe8f5e9)
        : const Color(0xffffefc5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ConstColors.filledColor,
                border: Border.all(color: ConstColors.borderColor, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Message",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sent On : $dateStr",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Text(
                          item.hasReply && item.reply.isNotEmpty
                              ? "Reply : ${item.reply}"
                              : "Reply : Pending",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (replyDateStr != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Replied On : $replyDateStr",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 38,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        statusLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                statusLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
