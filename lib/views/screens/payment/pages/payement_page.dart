import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';

class PayementPage extends StatefulWidget {
  final double totalAmount;
  const PayementPage({super.key, required this.totalAmount});

  @override
  PayementPageState createState() => PayementPageState();
}

class PayementPageState extends State<PayementPage> {
  int? selectedPaymentMethod;
  void onApplePayResult(dynamic paymentResult) {
    debugPrint(paymentResult.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    color: Color(0xFF646466),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${widget.totalAmount} د.إ ',
                  style: const TextStyle(
                    color: Color(0xFF262A40),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a payment method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              '*Banking fees may be charged depending on the selected payment method',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodOption(
              icon: Icons.credit_card_outlined,
              title: 'Pay with card',
              index: 0,
            ),

            // FutureBuilder<bool>(
            //   future: _payClient.userCanPay(PayProvider.apple_pay),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.done) {
            //       if (snapshot.data == true) {
            //         return _buildPaymentMethodOption(
            //           icon: FontAwesomeIcons.ccApplePay,
            //           title: 'Apple Pay',
            //           index: 1,
            //         );
            //       } else {
            //         return const SizedBox();
            //         // userCanPay returned false
            //         // Consider showing an alternative payment method
            //       }
            //     } else {
            //       return const SizedBox();
            //       // The operation hasn't finished loading
            //       // Consider showing a loading indicator
            //     }
            //   },
            // ),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedPaymentMethod == null
                  ? null
                  : () {
                      if (selectedPaymentMethod == 0) {
                        Provider.of<StudentFeeProvider>(
                          context,
                          listen: false,
                        ).postStudentFee(
                          context,
                          Provider.of<StudentProvider>(
                            context,
                            listen: false,
                          ).selectedStudentModel(context).studcode,
                        );
                      } else if (selectedPaymentMethod == 1) {}
                      // Handle payment logic here
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required IconData icon,
    required String title,
    String? subtitle,
    int? index,
    bool balanceWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFF2F3F7)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: balanceWarning ? Colors.red : Colors.black,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: balanceWarning ? Colors.red : Colors.black,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: balanceWarning ? Colors.red : Colors.grey,
                  ),
                )
              : null,
          trailing: RadioGroup<int>(
            groupValue: selectedPaymentMethod,
            onChanged: (int? value) {
              setState(() {
                selectedPaymentMethod = value;
              });
            },
            child: Radio<int>(value: index!),
          ),
          onTap: () {
            setState(() {
              selectedPaymentMethod = index;
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
