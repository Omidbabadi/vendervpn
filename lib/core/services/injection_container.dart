import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/src/configs/data/datasrc/configs_datasrc.dart';
import 'package:vendervpn/src/configs/domain/repo/configs_repo.dart';
import 'package:vendervpn/src/configs/domain/usecases/get_configs.dart';
import 'package:vendervpn/src/connection/data/datasrc/connection_datasrc.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';
import 'package:vendervpn/src/connection/domain/usecase/connect.dart';
import 'package:appwrite/appwrite.dart';
import '../../src/configs/data/repo/configs_repo_impl.dart';
import '../../src/connection/data/repo/connection_repo_impl.dart';
import '../../src/connection/domain/usecase/disconnect.dart';
import '../../src/connection/domain/usecase/get_vpn_state.dart';
import '../../src/connection/domain/usecase/initialize_v2ay.dart';

part 'injection_container.main.dart';
