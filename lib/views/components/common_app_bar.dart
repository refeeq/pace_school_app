import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Function()? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    bool canPop = ModalRoute.of(context)?.canPop ??
        false; // Check if there's a parent route

    return AppBar(
      bottom: bottom,
      automaticallyImplyLeading:
          canPop, // Automatically show or hide the back button
      title: title == null || title!.isEmpty
          ? const Text("")
          : FittedBox(
              child: Text(
                title ?? "",
                style: const TextStyle(color: Colors.white), // Title style
              ),
            ),
      leading: canPop
          ? IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                ),
              ), // Default back button
              onPressed: () {
                if (leading != null) {
                  leading!(); // If a custom function is provided, call it
                } else {
                  Navigator.of(context).pop(); // Default behavior: Go back
                }
              },
            )
          : const SizedBox(), // If can't pop, hide the leading widget
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Default AppBar height
}
