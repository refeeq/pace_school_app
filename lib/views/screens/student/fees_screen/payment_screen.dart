import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/screens/family_fee/cubit/family_fee_cubit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SuccessScreen extends StatefulWidget {
  final bool isPayment;
  final String userId;
  final String reponseUrl;
  const SuccessScreen({
    super.key,
    required this.reponseUrl,
    required this.userId,
    required this.isPayment,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            const Center(child: CircularProgressIndicator());
          },
          onPageStarted: (String url) {
            const Center(child: CircularProgressIndicator());
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.reponseUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.userId.isEmpty) {
              BlocProvider.of<FamilyFeeCubit>(context).fetchfee();
            } else {
              Provider.of<StudentFeeProvider>(
                context,
                listen: false,
              ).getStudentFee(studentId: widget.userId);
            }
            if (widget.isPayment) {
              Navigator.pop(context);
            }

            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WebViewWidget(controller: _controller),
      ),
      //floatingActionButton: favoriteButton(),
    );
  }
}
