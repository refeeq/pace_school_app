import 'package:flutter/material.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/notification/menu_deeplink_helper.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
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
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: subItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = subItems[index];
                return _FeeMenuItem(
                  item: item,
                  onTap: () async {
                    await _onTapSubMenu(context, item);
                  },
                );
              },
            ),
    );
  }

  Future<void> _onTapSubMenu(BuildContext context, StudentMenu item) async {
    final key = item.menuKey.trim();

    String? url;
    if (key == 'internalWeb' || key == 'externalWeb' || key == 'WhatsApp') {
      // For web submenu items, always prefer the URL directly provided
      // on that item (supports distinct pages like Activity Fee,
      // Re-Registration, WhatsApp web, etc.).
      url = item.weburl;
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

class _FeeMenuItem extends StatelessWidget {
  final StudentMenu item;
  final VoidCallback onTap;

  const _FeeMenuItem({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                _FeeMenuIcon(item: item),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    item.menuValue,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeeMenuIcon extends StatelessWidget {
  final StudentMenu item;

  const _FeeMenuIcon({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: ConstColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: item.iconUrl.isEmpty
          ? Icon(
              Icons.receipt_long_outlined,
              color: ConstColors.primary,
              size: 28,
            )
          : Image.network(
              item.iconUrl,
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.receipt_long_outlined,
                color: ConstColors.primary,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 24,
                  width: 24,
                  child: Center(
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

