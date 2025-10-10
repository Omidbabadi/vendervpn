
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/configs_list.dart';

class ConnectedConfigContainer extends ConsumerWidget {
  const ConnectedConfigContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(currentConfigProvider);
    return SizedBox(
      height: 60,
      child: InkWell(
        onTap: () {
          debugPrint('tap');
          context.push(ConfigsList.path);
        },
        child: Row(
          children: [
            if (config != null) CoreUtils.getCountryFlag(config.country!),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(config != null ? config.remark : 'United State'),
                  const SizedBox(height: 2),
                  Text(config != null ? config.address : 'United State'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colours.darkThemeSecondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
