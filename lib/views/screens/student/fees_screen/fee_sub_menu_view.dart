import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/notification/menu_deeplink_helper.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/menu_item.dart';
import 'package:school_app/views/components/update_alert.dart';

class FeeSubMenuView extends StatelessWidget {
  final StudentMenu feeMenu;

  const FeeSubMenuView({
    super.key,
    required this.feeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final subItems = feeMenu.subMenu ?? const <StudentMenu>[];

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(
        title: feeMenu.menuValue.isNotEmpty ? feeMenu.menuValue : 'Fee',
      ),
      body: subItems.isEmpty
          ? const Center(
              child: Text('No fee options available'),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.7 / 3.6,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 4,
                ),
                itemCount: subItems.length,
                itemBuilder: (context, index) {
                  final item = subItems[index];
                  return StudentMenuItemWidget(
                    homeTile: item,
                    ontap: () async {
                      await _onTapSubMenu(context, item);
                    },
                  );
                },
              ),
            ),
    );
  }

  Future<void> _onTapSubMenu(BuildContext context, StudentMenu item) async {
    final key = item.menuKey.trim();

    String? url;
    if (key == 'internalWeb') {
      url = item.weburl;
      if (url == null || url.isEmpty) {
        final studentProvider =
            Provider.of<StudentProvider>(context, listen: false);
        final menuModel = studentProvider.studentMenuModel;
        if (menuModel != null) {
          StudentMenu? topInternalWeb;
          for (final menu in menuModel.data) {
            if (menu.menuKey == 'internalWeb' &&
                (menu.weburl != null && menu.weburl!.isNotEmpty)) {
              topInternalWeb = menu;
              break;
            }
          }
          url = topInternalWeb?.weburl;
        }
      }
    }

    final handled = await navigateToMenuScreen(
      menuKey: key,
      url: url,
    );

    if (!handled && context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => const UpdateAlertDialog(),
      );
    }
  }
}

