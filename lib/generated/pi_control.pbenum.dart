// This is a generated file - do not edit.
//
// Generated from pi_control.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ServiceAction extends $pb.ProtobufEnum {
  static const ServiceAction START =
      ServiceAction._(0, _omitEnumNames ? '' : 'START');
  static const ServiceAction STOP =
      ServiceAction._(1, _omitEnumNames ? '' : 'STOP');
  static const ServiceAction RESTART =
      ServiceAction._(2, _omitEnumNames ? '' : 'RESTART');
  static const ServiceAction ENABLE =
      ServiceAction._(3, _omitEnumNames ? '' : 'ENABLE');
  static const ServiceAction DISABLE =
      ServiceAction._(4, _omitEnumNames ? '' : 'DISABLE');
  static const ServiceAction RELOAD =
      ServiceAction._(5, _omitEnumNames ? '' : 'RELOAD');

  static const $core.List<ServiceAction> values = <ServiceAction>[
    START,
    STOP,
    RESTART,
    ENABLE,
    DISABLE,
    RELOAD,
  ];

  static final $core.List<ServiceAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ServiceAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ServiceAction._(super.value, super.name);
}

class ContainerOp extends $pb.ProtobufEnum {
  static const ContainerOp CONTAINER_PAUSE =
      ContainerOp._(0, _omitEnumNames ? '' : 'CONTAINER_PAUSE');
  static const ContainerOp CONTAINER_UNPAUSE =
      ContainerOp._(1, _omitEnumNames ? '' : 'CONTAINER_UNPAUSE');
  static const ContainerOp CONTAINER_KILL =
      ContainerOp._(2, _omitEnumNames ? '' : 'CONTAINER_KILL');
  static const ContainerOp CONTAINER_REMOVE =
      ContainerOp._(3, _omitEnumNames ? '' : 'CONTAINER_REMOVE');

  static const $core.List<ContainerOp> values = <ContainerOp>[
    CONTAINER_PAUSE,
    CONTAINER_UNPAUSE,
    CONTAINER_KILL,
    CONTAINER_REMOVE,
  ];

  static final $core.List<ContainerOp?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ContainerOp? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ContainerOp._(super.value, super.name);
}

class PruneTarget extends $pb.ProtobufEnum {
  static const PruneTarget PRUNE_CONTAINERS =
      PruneTarget._(0, _omitEnumNames ? '' : 'PRUNE_CONTAINERS');
  static const PruneTarget PRUNE_IMAGES =
      PruneTarget._(1, _omitEnumNames ? '' : 'PRUNE_IMAGES');
  static const PruneTarget PRUNE_ALL_IMAGES =
      PruneTarget._(2, _omitEnumNames ? '' : 'PRUNE_ALL_IMAGES');
  static const PruneTarget PRUNE_VOLUMES =
      PruneTarget._(3, _omitEnumNames ? '' : 'PRUNE_VOLUMES');
  static const PruneTarget PRUNE_NETWORKS =
      PruneTarget._(4, _omitEnumNames ? '' : 'PRUNE_NETWORKS');
  static const PruneTarget PRUNE_BUILD_CACHE =
      PruneTarget._(5, _omitEnumNames ? '' : 'PRUNE_BUILD_CACHE');

  static const $core.List<PruneTarget> values = <PruneTarget>[
    PRUNE_CONTAINERS,
    PRUNE_IMAGES,
    PRUNE_ALL_IMAGES,
    PRUNE_VOLUMES,
    PRUNE_NETWORKS,
    PRUNE_BUILD_CACHE,
  ];

  static final $core.List<PruneTarget?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static PruneTarget? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PruneTarget._(super.value, super.name);
}

class Pm2StartMode extends $pb.ProtobufEnum {
  static const Pm2StartMode PM2_START_SCRIPT =
      Pm2StartMode._(0, _omitEnumNames ? '' : 'PM2_START_SCRIPT');
  static const Pm2StartMode PM2_START_ECOSYSTEM =
      Pm2StartMode._(1, _omitEnumNames ? '' : 'PM2_START_ECOSYSTEM');
  static const Pm2StartMode PM2_START_SERVE =
      Pm2StartMode._(2, _omitEnumNames ? '' : 'PM2_START_SERVE');

  static const $core.List<Pm2StartMode> values = <Pm2StartMode>[
    PM2_START_SCRIPT,
    PM2_START_ECOSYSTEM,
    PM2_START_SERVE,
  ];

  static final $core.List<Pm2StartMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Pm2StartMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Pm2StartMode._(super.value, super.name);
}

class Pm2Action extends $pb.ProtobufEnum {
  static const Pm2Action PM2_ACTION_START =
      Pm2Action._(0, _omitEnumNames ? '' : 'PM2_ACTION_START');
  static const Pm2Action PM2_ACTION_RESTART =
      Pm2Action._(1, _omitEnumNames ? '' : 'PM2_ACTION_RESTART');
  static const Pm2Action PM2_ACTION_RELOAD =
      Pm2Action._(2, _omitEnumNames ? '' : 'PM2_ACTION_RELOAD');
  static const Pm2Action PM2_ACTION_STOP =
      Pm2Action._(3, _omitEnumNames ? '' : 'PM2_ACTION_STOP');
  static const Pm2Action PM2_ACTION_DELETE =
      Pm2Action._(4, _omitEnumNames ? '' : 'PM2_ACTION_DELETE');
  static const Pm2Action PM2_ACTION_RESET =
      Pm2Action._(5, _omitEnumNames ? '' : 'PM2_ACTION_RESET');
  static const Pm2Action PM2_ACTION_SCALE =
      Pm2Action._(6, _omitEnumNames ? '' : 'PM2_ACTION_SCALE');
  static const Pm2Action PM2_ACTION_SEND_SIGNAL =
      Pm2Action._(7, _omitEnumNames ? '' : 'PM2_ACTION_SEND_SIGNAL');
  static const Pm2Action PM2_ACTION_TRIGGER =
      Pm2Action._(8, _omitEnumNames ? '' : 'PM2_ACTION_TRIGGER');
  static const Pm2Action PM2_ACTION_FLUSH =
      Pm2Action._(9, _omitEnumNames ? '' : 'PM2_ACTION_FLUSH');
  static const Pm2Action PM2_ACTION_SEND_STDIN =
      Pm2Action._(10, _omitEnumNames ? '' : 'PM2_ACTION_SEND_STDIN');
  static const Pm2Action PM2_ACTION_TOGGLE_WATCH =
      Pm2Action._(11, _omitEnumNames ? '' : 'PM2_ACTION_TOGGLE_WATCH');
  static const Pm2Action PM2_ACTION_PULL =
      Pm2Action._(12, _omitEnumNames ? '' : 'PM2_ACTION_PULL');
  static const Pm2Action PM2_ACTION_FORWARD =
      Pm2Action._(13, _omitEnumNames ? '' : 'PM2_ACTION_FORWARD');
  static const Pm2Action PM2_ACTION_BACKWARD =
      Pm2Action._(14, _omitEnumNames ? '' : 'PM2_ACTION_BACKWARD');

  static const $core.List<Pm2Action> values = <Pm2Action>[
    PM2_ACTION_START,
    PM2_ACTION_RESTART,
    PM2_ACTION_RELOAD,
    PM2_ACTION_STOP,
    PM2_ACTION_DELETE,
    PM2_ACTION_RESET,
    PM2_ACTION_SCALE,
    PM2_ACTION_SEND_SIGNAL,
    PM2_ACTION_TRIGGER,
    PM2_ACTION_FLUSH,
    PM2_ACTION_SEND_STDIN,
    PM2_ACTION_TOGGLE_WATCH,
    PM2_ACTION_PULL,
    PM2_ACTION_FORWARD,
    PM2_ACTION_BACKWARD,
  ];

  static final $core.List<Pm2Action?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 14);
  static Pm2Action? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Pm2Action._(super.value, super.name);
}

class Pm2Operation extends $pb.ProtobufEnum {
  static const Pm2Operation PM2_OP_SAVE =
      Pm2Operation._(0, _omitEnumNames ? '' : 'PM2_OP_SAVE');
  static const Pm2Operation PM2_OP_RESURRECT =
      Pm2Operation._(1, _omitEnumNames ? '' : 'PM2_OP_RESURRECT');
  static const Pm2Operation PM2_OP_CLEAR_DUMP =
      Pm2Operation._(2, _omitEnumNames ? '' : 'PM2_OP_CLEAR_DUMP');
  static const Pm2Operation PM2_OP_UPDATE =
      Pm2Operation._(3, _omitEnumNames ? '' : 'PM2_OP_UPDATE');
  static const Pm2Operation PM2_OP_KILL =
      Pm2Operation._(4, _omitEnumNames ? '' : 'PM2_OP_KILL');
  static const Pm2Operation PM2_OP_PING =
      Pm2Operation._(5, _omitEnumNames ? '' : 'PM2_OP_PING');
  static const Pm2Operation PM2_OP_FLUSH_ALL =
      Pm2Operation._(6, _omitEnumNames ? '' : 'PM2_OP_FLUSH_ALL');
  static const Pm2Operation PM2_OP_RELOAD_LOGS =
      Pm2Operation._(7, _omitEnumNames ? '' : 'PM2_OP_RELOAD_LOGS');
  static const Pm2Operation PM2_OP_STARTUP =
      Pm2Operation._(8, _omitEnumNames ? '' : 'PM2_OP_STARTUP');
  static const Pm2Operation PM2_OP_UNSTARTUP =
      Pm2Operation._(9, _omitEnumNames ? '' : 'PM2_OP_UNSTARTUP');
  static const Pm2Operation PM2_OP_INSTALL_MODULE =
      Pm2Operation._(10, _omitEnumNames ? '' : 'PM2_OP_INSTALL_MODULE');
  static const Pm2Operation PM2_OP_UPDATE_MODULE =
      Pm2Operation._(11, _omitEnumNames ? '' : 'PM2_OP_UPDATE_MODULE');
  static const Pm2Operation PM2_OP_UNINSTALL_MODULE =
      Pm2Operation._(12, _omitEnumNames ? '' : 'PM2_OP_UNINSTALL_MODULE');
  static const Pm2Operation PM2_OP_SET_CONFIG =
      Pm2Operation._(13, _omitEnumNames ? '' : 'PM2_OP_SET_CONFIG');
  static const Pm2Operation PM2_OP_UNSET_CONFIG =
      Pm2Operation._(14, _omitEnumNames ? '' : 'PM2_OP_UNSET_CONFIG');
  static const Pm2Operation PM2_OP_DEPLOY =
      Pm2Operation._(15, _omitEnumNames ? '' : 'PM2_OP_DEPLOY');
  static const Pm2Operation PM2_OP_REPORT =
      Pm2Operation._(16, _omitEnumNames ? '' : 'PM2_OP_REPORT');
  static const Pm2Operation PM2_OP_INIT_ECOSYSTEM =
      Pm2Operation._(17, _omitEnumNames ? '' : 'PM2_OP_INIT_ECOSYSTEM');
  static const Pm2Operation PM2_OP_INSTALL_PM2 =
      Pm2Operation._(18, _omitEnumNames ? '' : 'PM2_OP_INSTALL_PM2');
  static const Pm2Operation PM2_OP_PROFILE_CPU =
      Pm2Operation._(19, _omitEnumNames ? '' : 'PM2_OP_PROFILE_CPU');
  static const Pm2Operation PM2_OP_PROFILE_MEM =
      Pm2Operation._(20, _omitEnumNames ? '' : 'PM2_OP_PROFILE_MEM');
  static const Pm2Operation PM2_OP_LOGROTATE =
      Pm2Operation._(21, _omitEnumNames ? '' : 'PM2_OP_LOGROTATE');

  static const $core.List<Pm2Operation> values = <Pm2Operation>[
    PM2_OP_SAVE,
    PM2_OP_RESURRECT,
    PM2_OP_CLEAR_DUMP,
    PM2_OP_UPDATE,
    PM2_OP_KILL,
    PM2_OP_PING,
    PM2_OP_FLUSH_ALL,
    PM2_OP_RELOAD_LOGS,
    PM2_OP_STARTUP,
    PM2_OP_UNSTARTUP,
    PM2_OP_INSTALL_MODULE,
    PM2_OP_UPDATE_MODULE,
    PM2_OP_UNINSTALL_MODULE,
    PM2_OP_SET_CONFIG,
    PM2_OP_UNSET_CONFIG,
    PM2_OP_DEPLOY,
    PM2_OP_REPORT,
    PM2_OP_INIT_ECOSYSTEM,
    PM2_OP_INSTALL_PM2,
    PM2_OP_PROFILE_CPU,
    PM2_OP_PROFILE_MEM,
    PM2_OP_LOGROTATE,
  ];

  static final $core.List<Pm2Operation?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 21);
  static Pm2Operation? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Pm2Operation._(super.value, super.name);
}

class FirewallOp extends $pb.ProtobufEnum {
  static const FirewallOp FW_ENABLE =
      FirewallOp._(0, _omitEnumNames ? '' : 'FW_ENABLE');
  static const FirewallOp FW_DISABLE =
      FirewallOp._(1, _omitEnumNames ? '' : 'FW_DISABLE');
  static const FirewallOp FW_RELOAD =
      FirewallOp._(2, _omitEnumNames ? '' : 'FW_RELOAD');
  static const FirewallOp FW_RESET =
      FirewallOp._(3, _omitEnumNames ? '' : 'FW_RESET');
  static const FirewallOp FW_ADD_RULE =
      FirewallOp._(4, _omitEnumNames ? '' : 'FW_ADD_RULE');
  static const FirewallOp FW_DELETE_RULE =
      FirewallOp._(5, _omitEnumNames ? '' : 'FW_DELETE_RULE');
  static const FirewallOp FW_SET_DEFAULT =
      FirewallOp._(6, _omitEnumNames ? '' : 'FW_SET_DEFAULT');
  static const FirewallOp FW_SET_LOGGING =
      FirewallOp._(7, _omitEnumNames ? '' : 'FW_SET_LOGGING');
  static const FirewallOp FW_INSTALL =
      FirewallOp._(8, _omitEnumNames ? '' : 'FW_INSTALL');

  static const $core.List<FirewallOp> values = <FirewallOp>[
    FW_ENABLE,
    FW_DISABLE,
    FW_RELOAD,
    FW_RESET,
    FW_ADD_RULE,
    FW_DELETE_RULE,
    FW_SET_DEFAULT,
    FW_SET_LOGGING,
    FW_INSTALL,
  ];

  static final $core.List<FirewallOp?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static FirewallOp? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FirewallOp._(super.value, super.name);
}

class UserOp extends $pb.ProtobufEnum {
  static const UserOp USER_CREATE =
      UserOp._(0, _omitEnumNames ? '' : 'USER_CREATE');
  static const UserOp USER_DELETE =
      UserOp._(1, _omitEnumNames ? '' : 'USER_DELETE');
  static const UserOp USER_SET_PASSWORD =
      UserOp._(2, _omitEnumNames ? '' : 'USER_SET_PASSWORD');
  static const UserOp USER_LOCK =
      UserOp._(3, _omitEnumNames ? '' : 'USER_LOCK');
  static const UserOp USER_UNLOCK =
      UserOp._(4, _omitEnumNames ? '' : 'USER_UNLOCK');
  static const UserOp USER_ADD_GROUP =
      UserOp._(5, _omitEnumNames ? '' : 'USER_ADD_GROUP');
  static const UserOp USER_REMOVE_GROUP =
      UserOp._(6, _omitEnumNames ? '' : 'USER_REMOVE_GROUP');
  static const UserOp USER_SET_SHELL =
      UserOp._(7, _omitEnumNames ? '' : 'USER_SET_SHELL');
  static const UserOp USER_SET_FULL_NAME =
      UserOp._(8, _omitEnumNames ? '' : 'USER_SET_FULL_NAME');
  static const UserOp GROUP_CREATE =
      UserOp._(9, _omitEnumNames ? '' : 'GROUP_CREATE');
  static const UserOp GROUP_DELETE =
      UserOp._(10, _omitEnumNames ? '' : 'GROUP_DELETE');

  static const $core.List<UserOp> values = <UserOp>[
    USER_CREATE,
    USER_DELETE,
    USER_SET_PASSWORD,
    USER_LOCK,
    USER_UNLOCK,
    USER_ADD_GROUP,
    USER_REMOVE_GROUP,
    USER_SET_SHELL,
    USER_SET_FULL_NAME,
    GROUP_CREATE,
    GROUP_DELETE,
  ];

  static final $core.List<UserOp?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static UserOp? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserOp._(super.value, super.name);
}

class PowerOp extends $pb.ProtobufEnum {
  static const PowerOp POWER_REBOOT =
      PowerOp._(0, _omitEnumNames ? '' : 'POWER_REBOOT');
  static const PowerOp POWER_SHUTDOWN =
      PowerOp._(1, _omitEnumNames ? '' : 'POWER_SHUTDOWN');

  static const $core.List<PowerOp> values = <PowerOp>[
    POWER_REBOOT,
    POWER_SHUTDOWN,
  ];

  static final $core.List<PowerOp?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static PowerOp? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PowerOp._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
