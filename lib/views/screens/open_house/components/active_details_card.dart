import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/screens/open_house/components/appointment_details.dart';
import 'package:school_app/views/screens/open_house/model/active_open_house_model.dart';

class ActiveDetailsCard extends StatefulWidget {
  final ActiveOpenHouseModel activeOpenHouseModel;
  const ActiveDetailsCard({super.key, required this.activeOpenHouseModel});

  @override
  ActiveDetailsCardState createState() => ActiveDetailsCardState();
}

class ActiveDetailsCardState extends State<ActiveDetailsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Loop the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Function to display the dialog

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppointmentDetailsDialog(
              activeOpenHouseModel: widget.activeOpenHouseModel,
            );
          },
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Makes the height dynamic
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40, // Set the desired width
                                height: 40, // Set the desired height
                                decoration: BoxDecoration(
                                  shape: BoxShape
                                      .circle, // Make the container circular
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.activeOpenHouseModel.photo,
                                    ), // Load image from network
                                    fit: BoxFit
                                        .cover, // Ensure the image covers the entire circle
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  widget.activeOpenHouseModel.teacher,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.qr_code, size: 30),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.subject, size: 25, color: Colors.grey),
                        SizedBox(width: 5.w),
                        Text(
                          widget.activeOpenHouseModel.subject,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 25,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDateString(
                                widget.activeOpenHouseModel.ohDate.toString(),
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              widget.activeOpenHouseModel.from,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: RotatingBorderPainter(animation: _controller),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RotatingBorderPainter extends CustomPainter {
  final Animation<double> animation;
  RotatingBorderPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Create a gradient that rotates
    final gradient = SweepGradient(
      colors: const [Colors.grey, Colors.blue],
      stops: const [0.0, 1.0],
      transform: GradientRotation(
        animation.value * 2 * 3.14159265359,
      ), // Full rotation (2 * pi)
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    // Draw a rounded rectangle that matches the Container's border
    final rect = Rect.fromLTWH(
      2,
      2,
      size.width - 4,
      size.height - 4,
    ); // Adjust for stroke width
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(12),
      ), // Match the Container's corner radius
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
