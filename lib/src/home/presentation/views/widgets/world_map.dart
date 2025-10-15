import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/connection_line_painter.dart';

class BackgroundWorldMap extends ConsumerWidget {
  const BackgroundWorldMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionAdapterProvider().notifier).status;
    final String? country = ref.watch(currentConfigProvider)?.country;

    final SMapWorldColors connectedCountry = SMapWorldColors.fromMap({
      country!: Colours.connectedColor,
      'ir': Colours.daarkModeListTileColor,
    });

    final userPos = CoreUtils.countryCenter('ir');
    final serverPos = CoreUtils.countryCenter(country);
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 50),
          child: SimpleMap(
            instructions: SMapWorld.instructions,
            callback: (_, __, ___) {},
            fit: BoxFit.fill,
            countryBorder: CountryBorder(
              width: 5,
              color: Colours.grayColor,
            ),
            colors: connectedCountry.toMap(),
          ),
        ),
        if (userPos != null && serverPos != null)
          CustomPaint(
            size: Size.infinite,
            painter: ConnectionLinePainter(
              from: Offset(userPos['lon']!, userPos['lat']!),
              to: Offset(serverPos['lon']!, serverPos['lat']!),
              serverColor: Colours.connectedColor,
              userCountry: Colours.daarkModeListTileColor,
            ),
          ),
      ],
    );
  }
}
