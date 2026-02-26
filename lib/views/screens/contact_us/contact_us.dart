import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/models/contact_us_history_model.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/submit_button.dart';
import 'package:school_app/views/screens/contact_us/cubit/contact_us_cubit.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  final TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Contact Us"),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocProvider(
          create: (context) => ContactUsCubit(),
          child: BlocConsumer<ContactUsCubit, ContactUsState>(
            builder: (context, state) {
              _triggerHistoryLoad(context);
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
                      const SizedBox(height: 24),
                      Text(
                        'History',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildHistorySection(context, state),
                    ],
                  ),
                ),
              );
            },
            listener: (context, state) {
              if (state.submissionSuccessMessage != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Padding(
                      padding: const EdgeInsets.all(18.0),
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
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state.submissionFailureMessage != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Padding(
                      padding: const EdgeInsets.all(18.0),
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
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

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

  Widget _buildHistorySection(BuildContext context, ContactUsState state) {
    if (state.historyLoading && state.historyList == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'No messages yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _ContactUsHistoryTile(item: item);
      },
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ConstColors.filledColor,
          border: Border.all(color: ConstColors.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
            ),
            if (item.hasReply && item.reply.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                'Reply: ${item.reply}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (item.replyDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, y • HH:mm').format(item.replyDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
