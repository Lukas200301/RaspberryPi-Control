// This is a generated file - do not edit.
//
// Generated from pi_control.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use serviceActionDescriptor instead')
const ServiceAction$json = {
  '1': 'ServiceAction',
  '2': [
    {'1': 'START', '2': 0},
    {'1': 'STOP', '2': 1},
    {'1': 'RESTART', '2': 2},
    {'1': 'ENABLE', '2': 3},
    {'1': 'DISABLE', '2': 4},
    {'1': 'RELOAD', '2': 5},
  ],
};

/// Descriptor for `ServiceAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List serviceActionDescriptor = $convert.base64Decode(
    'Cg1TZXJ2aWNlQWN0aW9uEgkKBVNUQVJUEAASCAoEU1RPUBABEgsKB1JFU1RBUlQQAhIKCgZFTk'
    'FCTEUQAxILCgdESVNBQkxFEAQSCgoGUkVMT0FEEAU=');

@$core.Deprecated('Use containerOpDescriptor instead')
const ContainerOp$json = {
  '1': 'ContainerOp',
  '2': [
    {'1': 'CONTAINER_PAUSE', '2': 0},
    {'1': 'CONTAINER_UNPAUSE', '2': 1},
    {'1': 'CONTAINER_KILL', '2': 2},
    {'1': 'CONTAINER_REMOVE', '2': 3},
  ],
};

/// Descriptor for `ContainerOp`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List containerOpDescriptor = $convert.base64Decode(
    'CgtDb250YWluZXJPcBITCg9DT05UQUlORVJfUEFVU0UQABIVChFDT05UQUlORVJfVU5QQVVTRR'
    'ABEhIKDkNPTlRBSU5FUl9LSUxMEAISFAoQQ09OVEFJTkVSX1JFTU9WRRAD');

@$core.Deprecated('Use pruneTargetDescriptor instead')
const PruneTarget$json = {
  '1': 'PruneTarget',
  '2': [
    {'1': 'PRUNE_CONTAINERS', '2': 0},
    {'1': 'PRUNE_IMAGES', '2': 1},
    {'1': 'PRUNE_ALL_IMAGES', '2': 2},
    {'1': 'PRUNE_VOLUMES', '2': 3},
    {'1': 'PRUNE_NETWORKS', '2': 4},
    {'1': 'PRUNE_BUILD_CACHE', '2': 5},
  ],
};

/// Descriptor for `PruneTarget`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pruneTargetDescriptor = $convert.base64Decode(
    'CgtQcnVuZVRhcmdldBIUChBQUlVORV9DT05UQUlORVJTEAASEAoMUFJVTkVfSU1BR0VTEAESFA'
    'oQUFJVTkVfQUxMX0lNQUdFUxACEhEKDVBSVU5FX1ZPTFVNRVMQAxISCg5QUlVORV9ORVRXT1JL'
    'UxAEEhUKEVBSVU5FX0JVSUxEX0NBQ0hFEAU=');

@$core.Deprecated('Use pm2StartModeDescriptor instead')
const Pm2StartMode$json = {
  '1': 'Pm2StartMode',
  '2': [
    {'1': 'PM2_START_SCRIPT', '2': 0},
    {'1': 'PM2_START_ECOSYSTEM', '2': 1},
    {'1': 'PM2_START_SERVE', '2': 2},
  ],
};

/// Descriptor for `Pm2StartMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pm2StartModeDescriptor = $convert.base64Decode(
    'CgxQbTJTdGFydE1vZGUSFAoQUE0yX1NUQVJUX1NDUklQVBAAEhcKE1BNMl9TVEFSVF9FQ09TWV'
    'NURU0QARITCg9QTTJfU1RBUlRfU0VSVkUQAg==');

@$core.Deprecated('Use pm2ActionDescriptor instead')
const Pm2Action$json = {
  '1': 'Pm2Action',
  '2': [
    {'1': 'PM2_ACTION_START', '2': 0},
    {'1': 'PM2_ACTION_RESTART', '2': 1},
    {'1': 'PM2_ACTION_RELOAD', '2': 2},
    {'1': 'PM2_ACTION_STOP', '2': 3},
    {'1': 'PM2_ACTION_DELETE', '2': 4},
    {'1': 'PM2_ACTION_RESET', '2': 5},
    {'1': 'PM2_ACTION_SCALE', '2': 6},
    {'1': 'PM2_ACTION_SEND_SIGNAL', '2': 7},
    {'1': 'PM2_ACTION_TRIGGER', '2': 8},
    {'1': 'PM2_ACTION_FLUSH', '2': 9},
    {'1': 'PM2_ACTION_SEND_STDIN', '2': 10},
    {'1': 'PM2_ACTION_TOGGLE_WATCH', '2': 11},
    {'1': 'PM2_ACTION_PULL', '2': 12},
    {'1': 'PM2_ACTION_FORWARD', '2': 13},
    {'1': 'PM2_ACTION_BACKWARD', '2': 14},
  ],
};

/// Descriptor for `Pm2Action`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pm2ActionDescriptor = $convert.base64Decode(
    'CglQbTJBY3Rpb24SFAoQUE0yX0FDVElPTl9TVEFSVBAAEhYKElBNMl9BQ1RJT05fUkVTVEFSVB'
    'ABEhUKEVBNMl9BQ1RJT05fUkVMT0FEEAISEwoPUE0yX0FDVElPTl9TVE9QEAMSFQoRUE0yX0FD'
    'VElPTl9ERUxFVEUQBBIUChBQTTJfQUNUSU9OX1JFU0VUEAUSFAoQUE0yX0FDVElPTl9TQ0FMRR'
    'AGEhoKFlBNMl9BQ1RJT05fU0VORF9TSUdOQUwQBxIWChJQTTJfQUNUSU9OX1RSSUdHRVIQCBIU'
    'ChBQTTJfQUNUSU9OX0ZMVVNIEAkSGQoVUE0yX0FDVElPTl9TRU5EX1NURElOEAoSGwoXUE0yX0'
    'FDVElPTl9UT0dHTEVfV0FUQ0gQCxITCg9QTTJfQUNUSU9OX1BVTEwQDBIWChJQTTJfQUNUSU9O'
    'X0ZPUldBUkQQDRIXChNQTTJfQUNUSU9OX0JBQ0tXQVJEEA4=');

@$core.Deprecated('Use pm2OperationDescriptor instead')
const Pm2Operation$json = {
  '1': 'Pm2Operation',
  '2': [
    {'1': 'PM2_OP_SAVE', '2': 0},
    {'1': 'PM2_OP_RESURRECT', '2': 1},
    {'1': 'PM2_OP_CLEAR_DUMP', '2': 2},
    {'1': 'PM2_OP_UPDATE', '2': 3},
    {'1': 'PM2_OP_KILL', '2': 4},
    {'1': 'PM2_OP_PING', '2': 5},
    {'1': 'PM2_OP_FLUSH_ALL', '2': 6},
    {'1': 'PM2_OP_RELOAD_LOGS', '2': 7},
    {'1': 'PM2_OP_STARTUP', '2': 8},
    {'1': 'PM2_OP_UNSTARTUP', '2': 9},
    {'1': 'PM2_OP_INSTALL_MODULE', '2': 10},
    {'1': 'PM2_OP_UPDATE_MODULE', '2': 11},
    {'1': 'PM2_OP_UNINSTALL_MODULE', '2': 12},
    {'1': 'PM2_OP_SET_CONFIG', '2': 13},
    {'1': 'PM2_OP_UNSET_CONFIG', '2': 14},
    {'1': 'PM2_OP_DEPLOY', '2': 15},
    {'1': 'PM2_OP_REPORT', '2': 16},
    {'1': 'PM2_OP_INIT_ECOSYSTEM', '2': 17},
    {'1': 'PM2_OP_INSTALL_PM2', '2': 18},
    {'1': 'PM2_OP_PROFILE_CPU', '2': 19},
    {'1': 'PM2_OP_PROFILE_MEM', '2': 20},
    {'1': 'PM2_OP_LOGROTATE', '2': 21},
  ],
};

/// Descriptor for `Pm2Operation`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pm2OperationDescriptor = $convert.base64Decode(
    'CgxQbTJPcGVyYXRpb24SDwoLUE0yX09QX1NBVkUQABIUChBQTTJfT1BfUkVTVVJSRUNUEAESFQ'
    'oRUE0yX09QX0NMRUFSX0RVTVAQAhIRCg1QTTJfT1BfVVBEQVRFEAMSDwoLUE0yX09QX0tJTEwQ'
    'BBIPCgtQTTJfT1BfUElORxAFEhQKEFBNMl9PUF9GTFVTSF9BTEwQBhIWChJQTTJfT1BfUkVMT0'
    'FEX0xPR1MQBxISCg5QTTJfT1BfU1RBUlRVUBAIEhQKEFBNMl9PUF9VTlNUQVJUVVAQCRIZChVQ'
    'TTJfT1BfSU5TVEFMTF9NT0RVTEUQChIYChRQTTJfT1BfVVBEQVRFX01PRFVMRRALEhsKF1BNMl'
    '9PUF9VTklOU1RBTExfTU9EVUxFEAwSFQoRUE0yX09QX1NFVF9DT05GSUcQDRIXChNQTTJfT1Bf'
    'VU5TRVRfQ09ORklHEA4SEQoNUE0yX09QX0RFUExPWRAPEhEKDVBNMl9PUF9SRVBPUlQQEBIZCh'
    'VQTTJfT1BfSU5JVF9FQ09TWVNURU0QERIWChJQTTJfT1BfSU5TVEFMTF9QTTIQEhIWChJQTTJf'
    'T1BfUFJPRklMRV9DUFUQExIWChJQTTJfT1BfUFJPRklMRV9NRU0QFBIUChBQTTJfT1BfTE9HUk'
    '9UQVRFEBU=');

@$core.Deprecated('Use firewallOpDescriptor instead')
const FirewallOp$json = {
  '1': 'FirewallOp',
  '2': [
    {'1': 'FW_ENABLE', '2': 0},
    {'1': 'FW_DISABLE', '2': 1},
    {'1': 'FW_RELOAD', '2': 2},
    {'1': 'FW_RESET', '2': 3},
    {'1': 'FW_ADD_RULE', '2': 4},
    {'1': 'FW_DELETE_RULE', '2': 5},
    {'1': 'FW_SET_DEFAULT', '2': 6},
    {'1': 'FW_SET_LOGGING', '2': 7},
    {'1': 'FW_INSTALL', '2': 8},
  ],
};

/// Descriptor for `FirewallOp`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List firewallOpDescriptor = $convert.base64Decode(
    'CgpGaXJld2FsbE9wEg0KCUZXX0VOQUJMRRAAEg4KCkZXX0RJU0FCTEUQARINCglGV19SRUxPQU'
    'QQAhIMCghGV19SRVNFVBADEg8KC0ZXX0FERF9SVUxFEAQSEgoORldfREVMRVRFX1JVTEUQBRIS'
    'Cg5GV19TRVRfREVGQVVMVBAGEhIKDkZXX1NFVF9MT0dHSU5HEAcSDgoKRldfSU5TVEFMTBAI');

@$core.Deprecated('Use userOpDescriptor instead')
const UserOp$json = {
  '1': 'UserOp',
  '2': [
    {'1': 'USER_CREATE', '2': 0},
    {'1': 'USER_DELETE', '2': 1},
    {'1': 'USER_SET_PASSWORD', '2': 2},
    {'1': 'USER_LOCK', '2': 3},
    {'1': 'USER_UNLOCK', '2': 4},
    {'1': 'USER_ADD_GROUP', '2': 5},
    {'1': 'USER_REMOVE_GROUP', '2': 6},
    {'1': 'USER_SET_SHELL', '2': 7},
    {'1': 'USER_SET_FULL_NAME', '2': 8},
    {'1': 'GROUP_CREATE', '2': 9},
    {'1': 'GROUP_DELETE', '2': 10},
  ],
};

/// Descriptor for `UserOp`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userOpDescriptor = $convert.base64Decode(
    'CgZVc2VyT3ASDwoLVVNFUl9DUkVBVEUQABIPCgtVU0VSX0RFTEVURRABEhUKEVVTRVJfU0VUX1'
    'BBU1NXT1JEEAISDQoJVVNFUl9MT0NLEAMSDwoLVVNFUl9VTkxPQ0sQBBISCg5VU0VSX0FERF9H'
    'Uk9VUBAFEhUKEVVTRVJfUkVNT1ZFX0dST1VQEAYSEgoOVVNFUl9TRVRfU0hFTEwQBxIWChJVU0'
    'VSX1NFVF9GVUxMX05BTUUQCBIQCgxHUk9VUF9DUkVBVEUQCRIQCgxHUk9VUF9ERUxFVEUQCg==');

@$core.Deprecated('Use powerOpDescriptor instead')
const PowerOp$json = {
  '1': 'PowerOp',
  '2': [
    {'1': 'POWER_REBOOT', '2': 0},
    {'1': 'POWER_SHUTDOWN', '2': 1},
  ],
};

/// Descriptor for `PowerOp`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List powerOpDescriptor = $convert.base64Decode(
    'CgdQb3dlck9wEhAKDFBPV0VSX1JFQk9PVBAAEhIKDlBPV0VSX1NIVVRET1dOEAE=');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use liveStatsDescriptor instead')
const LiveStats$json = {
  '1': 'LiveStats',
  '2': [
    {'1': 'cpu_usage', '3': 1, '4': 1, '5': 1, '10': 'cpuUsage'},
    {'1': 'cpu_per_core', '3': 2, '4': 3, '5': 1, '10': 'cpuPerCore'},
    {'1': 'ram_used', '3': 3, '4': 1, '5': 4, '10': 'ramUsed'},
    {'1': 'ram_total', '3': 4, '4': 1, '5': 4, '10': 'ramTotal'},
    {'1': 'ram_free', '3': 5, '4': 1, '5': 4, '10': 'ramFree'},
    {'1': 'ram_cached', '3': 6, '4': 1, '5': 4, '10': 'ramCached'},
    {'1': 'swap_used', '3': 7, '4': 1, '5': 4, '10': 'swapUsed'},
    {'1': 'swap_total', '3': 8, '4': 1, '5': 4, '10': 'swapTotal'},
    {'1': 'cpu_temp', '3': 9, '4': 1, '5': 1, '10': 'cpuTemp'},
    {'1': 'gpu_temp', '3': 10, '4': 1, '5': 1, '10': 'gpuTemp'},
    {'1': 'uptime', '3': 11, '4': 1, '5': 4, '10': 'uptime'},
    {'1': 'load_1min', '3': 12, '4': 1, '5': 1, '10': 'load1min'},
    {'1': 'load_5min', '3': 13, '4': 1, '5': 1, '10': 'load5min'},
    {'1': 'load_15min', '3': 14, '4': 1, '5': 1, '10': 'load15min'},
    {'1': 'net_bytes_sent', '3': 15, '4': 1, '5': 4, '10': 'netBytesSent'},
    {'1': 'net_bytes_recv', '3': 16, '4': 1, '5': 4, '10': 'netBytesRecv'},
    {
      '1': 'top_processes',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ProcessInfo',
      '10': 'topProcesses'
    },
    {'1': 'timestamp', '3': 18, '4': 1, '5': 3, '10': 'timestamp'},
    {
      '1': 'disk_io',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.picontrol.DiskIOStat',
      '10': 'diskIo'
    },
  ],
};

/// Descriptor for `LiveStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List liveStatsDescriptor = $convert.base64Decode(
    'CglMaXZlU3RhdHMSGwoJY3B1X3VzYWdlGAEgASgBUghjcHVVc2FnZRIgCgxjcHVfcGVyX2Nvcm'
    'UYAiADKAFSCmNwdVBlckNvcmUSGQoIcmFtX3VzZWQYAyABKARSB3JhbVVzZWQSGwoJcmFtX3Rv'
    'dGFsGAQgASgEUghyYW1Ub3RhbBIZCghyYW1fZnJlZRgFIAEoBFIHcmFtRnJlZRIdCgpyYW1fY2'
    'FjaGVkGAYgASgEUglyYW1DYWNoZWQSGwoJc3dhcF91c2VkGAcgASgEUghzd2FwVXNlZBIdCgpz'
    'd2FwX3RvdGFsGAggASgEUglzd2FwVG90YWwSGQoIY3B1X3RlbXAYCSABKAFSB2NwdVRlbXASGQ'
    'oIZ3B1X3RlbXAYCiABKAFSB2dwdVRlbXASFgoGdXB0aW1lGAsgASgEUgZ1cHRpbWUSGwoJbG9h'
    'ZF8xbWluGAwgASgBUghsb2FkMW1pbhIbCglsb2FkXzVtaW4YDSABKAFSCGxvYWQ1bWluEh0KCm'
    'xvYWRfMTVtaW4YDiABKAFSCWxvYWQxNW1pbhIkCg5uZXRfYnl0ZXNfc2VudBgPIAEoBFIMbmV0'
    'Qnl0ZXNTZW50EiQKDm5ldF9ieXRlc19yZWN2GBAgASgEUgxuZXRCeXRlc1JlY3YSOwoNdG9wX3'
    'Byb2Nlc3NlcxgRIAMoCzIWLnBpY29udHJvbC5Qcm9jZXNzSW5mb1IMdG9wUHJvY2Vzc2VzEhwK'
    'CXRpbWVzdGFtcBgSIAEoA1IJdGltZXN0YW1wEi4KB2Rpc2tfaW8YEyADKAsyFS5waWNvbnRyb2'
    'wuRGlza0lPU3RhdFIGZGlza0lv');

@$core.Deprecated('Use processInfoDescriptor instead')
const ProcessInfo$json = {
  '1': 'ProcessInfo',
  '2': [
    {'1': 'pid', '3': 1, '4': 1, '5': 5, '10': 'pid'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'cpu_percent', '3': 3, '4': 1, '5': 1, '10': 'cpuPercent'},
    {'1': 'memory_percent', '3': 4, '4': 1, '5': 1, '10': 'memoryPercent'},
    {'1': 'memory_bytes', '3': 5, '4': 1, '5': 4, '10': 'memoryBytes'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'username', '3': 7, '4': 1, '5': 9, '10': 'username'},
    {'1': 'cmdline', '3': 8, '4': 1, '5': 9, '10': 'cmdline'},
    {'1': 'ppid', '3': 9, '4': 1, '5': 5, '10': 'ppid'},
  ],
};

/// Descriptor for `ProcessInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processInfoDescriptor = $convert.base64Decode(
    'CgtQcm9jZXNzSW5mbxIQCgNwaWQYASABKAVSA3BpZBISCgRuYW1lGAIgASgJUgRuYW1lEh8KC2'
    'NwdV9wZXJjZW50GAMgASgBUgpjcHVQZXJjZW50EiUKDm1lbW9yeV9wZXJjZW50GAQgASgBUg1t'
    'ZW1vcnlQZXJjZW50EiEKDG1lbW9yeV9ieXRlcxgFIAEoBFILbWVtb3J5Qnl0ZXMSFgoGc3RhdH'
    'VzGAYgASgJUgZzdGF0dXMSGgoIdXNlcm5hbWUYByABKAlSCHVzZXJuYW1lEhgKB2NtZGxpbmUY'
    'CCABKAlSB2NtZGxpbmUSEgoEcHBpZBgJIAEoBVIEcHBpZA==');

@$core.Deprecated('Use processListDescriptor instead')
const ProcessList$json = {
  '1': 'ProcessList',
  '2': [
    {
      '1': 'processes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ProcessInfo',
      '10': 'processes'
    },
  ],
};

/// Descriptor for `ProcessList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processListDescriptor = $convert.base64Decode(
    'CgtQcm9jZXNzTGlzdBI0Cglwcm9jZXNzZXMYASADKAsyFi5waWNvbnRyb2wuUHJvY2Vzc0luZm'
    '9SCXByb2Nlc3Nlcw==');

@$core.Deprecated('Use processIdDescriptor instead')
const ProcessId$json = {
  '1': 'ProcessId',
  '2': [
    {'1': 'pid', '3': 1, '4': 1, '5': 5, '10': 'pid'},
  ],
};

/// Descriptor for `ProcessId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processIdDescriptor =
    $convert.base64Decode('CglQcm9jZXNzSWQSEAoDcGlkGAEgASgFUgNwaWQ=');

@$core.Deprecated('Use serviceInfoDescriptor instead')
const ServiceInfo$json = {
  '1': 'ServiceInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'enabled', '3': 4, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'sub_state', '3': 5, '4': 1, '5': 9, '10': 'subState'},
  ],
};

/// Descriptor for `ServiceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceInfoDescriptor = $convert.base64Decode(
    'CgtTZXJ2aWNlSW5mbxISCgRuYW1lGAEgASgJUgRuYW1lEhYKBnN0YXR1cxgCIAEoCVIGc3RhdH'
    'VzEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIYCgdlbmFibGVkGAQgASgIUgdl'
    'bmFibGVkEhsKCXN1Yl9zdGF0ZRgFIAEoCVIIc3ViU3RhdGU=');

@$core.Deprecated('Use serviceListDescriptor instead')
const ServiceList$json = {
  '1': 'ServiceList',
  '2': [
    {
      '1': 'services',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ServiceInfo',
      '10': 'services'
    },
  ],
};

/// Descriptor for `ServiceList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceListDescriptor = $convert.base64Decode(
    'CgtTZXJ2aWNlTGlzdBIyCghzZXJ2aWNlcxgBIAMoCzIWLnBpY29udHJvbC5TZXJ2aWNlSW5mb1'
    'IIc2VydmljZXM=');

@$core.Deprecated('Use serviceCommandDescriptor instead')
const ServiceCommand$json = {
  '1': 'ServiceCommand',
  '2': [
    {'1': 'service_name', '3': 1, '4': 1, '5': 9, '10': 'serviceName'},
    {
      '1': 'action',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.picontrol.ServiceAction',
      '10': 'action'
    },
  ],
};

/// Descriptor for `ServiceCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceCommandDescriptor = $convert.base64Decode(
    'Cg5TZXJ2aWNlQ29tbWFuZBIhCgxzZXJ2aWNlX25hbWUYASABKAlSC3NlcnZpY2VOYW1lEjAKBm'
    'FjdGlvbhgCIAEoDjIYLnBpY29udHJvbC5TZXJ2aWNlQWN0aW9uUgZhY3Rpb24=');

@$core.Deprecated('Use actionStatusDescriptor instead')
const ActionStatus$json = {
  '1': 'ActionStatus',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'error_code', '3': 3, '4': 1, '5': 5, '10': 'errorCode'},
  ],
};

/// Descriptor for `ActionStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionStatusDescriptor = $convert.base64Decode(
    'CgxBY3Rpb25TdGF0dXMSGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdlEh0KCmVycm9yX2NvZGUYAyABKAVSCWVycm9yQ29kZQ==');

@$core.Deprecated('Use logFilterDescriptor instead')
const LogFilter$json = {
  '1': 'LogFilter',
  '2': [
    {'1': 'levels', '3': 1, '4': 3, '5': 9, '10': 'levels'},
    {'1': 'service', '3': 2, '4': 1, '5': 9, '10': 'service'},
    {'1': 'tail_lines', '3': 3, '4': 1, '5': 5, '10': 'tailLines'},
  ],
};

/// Descriptor for `LogFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logFilterDescriptor = $convert.base64Decode(
    'CglMb2dGaWx0ZXISFgoGbGV2ZWxzGAEgAygJUgZsZXZlbHMSGAoHc2VydmljZRgCIAEoCVIHc2'
    'VydmljZRIdCgp0YWlsX2xpbmVzGAMgASgFUgl0YWlsTGluZXM=');

@$core.Deprecated('Use logEntryDescriptor instead')
const LogEntry$json = {
  '1': 'LogEntry',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'level', '3': 2, '4': 1, '5': 9, '10': 'level'},
    {'1': 'service', '3': 3, '4': 1, '5': 9, '10': 'service'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `LogEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logEntryDescriptor = $convert.base64Decode(
    'CghMb2dFbnRyeRIcCgl0aW1lc3RhbXAYASABKANSCXRpbWVzdGFtcBIUCgVsZXZlbBgCIAEoCV'
    'IFbGV2ZWwSGAoHc2VydmljZRgDIAEoCVIHc2VydmljZRIYCgdtZXNzYWdlGAQgASgJUgdtZXNz'
    'YWdl');

@$core.Deprecated('Use diskInfoDescriptor instead')
const DiskInfo$json = {
  '1': 'DiskInfo',
  '2': [
    {
      '1': 'partitions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.DiskPartition',
      '10': 'partitions'
    },
  ],
};

/// Descriptor for `DiskInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diskInfoDescriptor = $convert.base64Decode(
    'CghEaXNrSW5mbxI4CgpwYXJ0aXRpb25zGAEgAygLMhgucGljb250cm9sLkRpc2tQYXJ0aXRpb2'
    '5SCnBhcnRpdGlvbnM=');

@$core.Deprecated('Use diskPartitionDescriptor instead')
const DiskPartition$json = {
  '1': 'DiskPartition',
  '2': [
    {'1': 'device', '3': 1, '4': 1, '5': 9, '10': 'device'},
    {'1': 'mount_point', '3': 2, '4': 1, '5': 9, '10': 'mountPoint'},
    {'1': 'filesystem', '3': 3, '4': 1, '5': 9, '10': 'filesystem'},
    {'1': 'total_bytes', '3': 4, '4': 1, '5': 4, '10': 'totalBytes'},
    {'1': 'used_bytes', '3': 5, '4': 1, '5': 4, '10': 'usedBytes'},
    {'1': 'free_bytes', '3': 6, '4': 1, '5': 4, '10': 'freeBytes'},
    {'1': 'usage_percent', '3': 7, '4': 1, '5': 1, '10': 'usagePercent'},
  ],
};

/// Descriptor for `DiskPartition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diskPartitionDescriptor = $convert.base64Decode(
    'Cg1EaXNrUGFydGl0aW9uEhYKBmRldmljZRgBIAEoCVIGZGV2aWNlEh8KC21vdW50X3BvaW50GA'
    'IgASgJUgptb3VudFBvaW50Eh4KCmZpbGVzeXN0ZW0YAyABKAlSCmZpbGVzeXN0ZW0SHwoLdG90'
    'YWxfYnl0ZXMYBCABKARSCnRvdGFsQnl0ZXMSHQoKdXNlZF9ieXRlcxgFIAEoBFIJdXNlZEJ5dG'
    'VzEh0KCmZyZWVfYnl0ZXMYBiABKARSCWZyZWVCeXRlcxIjCg11c2FnZV9wZXJjZW50GAcgASgB'
    'Ugx1c2FnZVBlcmNlbnQ=');

@$core.Deprecated('Use networkInfoDescriptor instead')
const NetworkInfo$json = {
  '1': 'NetworkInfo',
  '2': [
    {
      '1': 'interfaces',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.NetworkInterface',
      '10': 'interfaces'
    },
  ],
};

/// Descriptor for `NetworkInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkInfoDescriptor = $convert.base64Decode(
    'CgtOZXR3b3JrSW5mbxI7CgppbnRlcmZhY2VzGAEgAygLMhsucGljb250cm9sLk5ldHdvcmtJbn'
    'RlcmZhY2VSCmludGVyZmFjZXM=');

@$core.Deprecated('Use networkInterfaceDescriptor instead')
const NetworkInterface$json = {
  '1': 'NetworkInterface',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'addresses', '3': 2, '4': 3, '5': 9, '10': 'addresses'},
    {'1': 'mac_address', '3': 3, '4': 1, '5': 9, '10': 'macAddress'},
    {'1': 'is_up', '3': 4, '4': 1, '5': 8, '10': 'isUp'},
    {'1': 'bytes_sent', '3': 5, '4': 1, '5': 4, '10': 'bytesSent'},
    {'1': 'bytes_recv', '3': 6, '4': 1, '5': 4, '10': 'bytesRecv'},
    {'1': 'packets_sent', '3': 7, '4': 1, '5': 4, '10': 'packetsSent'},
    {'1': 'packets_recv', '3': 8, '4': 1, '5': 4, '10': 'packetsRecv'},
  ],
};

/// Descriptor for `NetworkInterface`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkInterfaceDescriptor = $convert.base64Decode(
    'ChBOZXR3b3JrSW50ZXJmYWNlEhIKBG5hbWUYASABKAlSBG5hbWUSHAoJYWRkcmVzc2VzGAIgAy'
    'gJUglhZGRyZXNzZXMSHwoLbWFjX2FkZHJlc3MYAyABKAlSCm1hY0FkZHJlc3MSEwoFaXNfdXAY'
    'BCABKAhSBGlzVXASHQoKYnl0ZXNfc2VudBgFIAEoBFIJYnl0ZXNTZW50Eh0KCmJ5dGVzX3JlY3'
    'YYBiABKARSCWJ5dGVzUmVjdhIhCgxwYWNrZXRzX3NlbnQYByABKARSC3BhY2tldHNTZW50EiEK'
    'DHBhY2tldHNfcmVjdhgIIAEoBFILcGFja2V0c1JlY3Y=');

@$core.Deprecated('Use networkConnectionListDescriptor instead')
const NetworkConnectionList$json = {
  '1': 'NetworkConnectionList',
  '2': [
    {
      '1': 'connections',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.NetworkConnection',
      '10': 'connections'
    },
  ],
};

/// Descriptor for `NetworkConnectionList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkConnectionListDescriptor = $convert.base64Decode(
    'ChVOZXR3b3JrQ29ubmVjdGlvbkxpc3QSPgoLY29ubmVjdGlvbnMYASADKAsyHC5waWNvbnRyb2'
    'wuTmV0d29ya0Nvbm5lY3Rpb25SC2Nvbm5lY3Rpb25z');

@$core.Deprecated('Use networkConnectionDescriptor instead')
const NetworkConnection$json = {
  '1': 'NetworkConnection',
  '2': [
    {'1': 'protocol', '3': 1, '4': 1, '5': 9, '10': 'protocol'},
    {'1': 'local_address', '3': 2, '4': 1, '5': 9, '10': 'localAddress'},
    {'1': 'local_port', '3': 3, '4': 1, '5': 5, '10': 'localPort'},
    {'1': 'remote_address', '3': 4, '4': 1, '5': 9, '10': 'remoteAddress'},
    {'1': 'remote_port', '3': 5, '4': 1, '5': 5, '10': 'remotePort'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'pid', '3': 7, '4': 1, '5': 5, '10': 'pid'},
    {'1': 'process_name', '3': 8, '4': 1, '5': 9, '10': 'processName'},
  ],
};

/// Descriptor for `NetworkConnection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkConnectionDescriptor = $convert.base64Decode(
    'ChFOZXR3b3JrQ29ubmVjdGlvbhIaCghwcm90b2NvbBgBIAEoCVIIcHJvdG9jb2wSIwoNbG9jYW'
    'xfYWRkcmVzcxgCIAEoCVIMbG9jYWxBZGRyZXNzEh0KCmxvY2FsX3BvcnQYAyABKAVSCWxvY2Fs'
    'UG9ydBIlCg5yZW1vdGVfYWRkcmVzcxgEIAEoCVINcmVtb3RlQWRkcmVzcxIfCgtyZW1vdGVfcG'
    '9ydBgFIAEoBVIKcmVtb3RlUG9ydBIWCgZzdGF0dXMYBiABKAlSBnN0YXR1cxIQCgNwaWQYByAB'
    'KAVSA3BpZBIhCgxwcm9jZXNzX25hbWUYCCABKAlSC3Byb2Nlc3NOYW1l');

@$core.Deprecated('Use packageFilterDescriptor instead')
const PackageFilter$json = {
  '1': 'PackageFilter',
  '2': [
    {'1': 'search_term', '3': 1, '4': 1, '5': 9, '10': 'searchTerm'},
    {'1': 'installed_only', '3': 2, '4': 1, '5': 8, '10': 'installedOnly'},
  ],
};

/// Descriptor for `PackageFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageFilterDescriptor = $convert.base64Decode(
    'Cg1QYWNrYWdlRmlsdGVyEh8KC3NlYXJjaF90ZXJtGAEgASgJUgpzZWFyY2hUZXJtEiUKDmluc3'
    'RhbGxlZF9vbmx5GAIgASgIUg1pbnN0YWxsZWRPbmx5');

@$core.Deprecated('Use packageInfoDescriptor instead')
const PackageInfo$json = {
  '1': 'PackageInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'architecture', '3': 3, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'installed', '3': 5, '4': 1, '5': 8, '10': 'installed'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'installed_size', '3': 7, '4': 1, '5': 4, '10': 'installedSize'},
    {'1': 'section', '3': 8, '4': 1, '5': 9, '10': 'section'},
  ],
};

/// Descriptor for `PackageInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageInfoDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlSW5mbxISCgRuYW1lGAEgASgJUgRuYW1lEhgKB3ZlcnNpb24YAiABKAlSB3Zlcn'
    'Npb24SIgoMYXJjaGl0ZWN0dXJlGAMgASgJUgxhcmNoaXRlY3R1cmUSIAoLZGVzY3JpcHRpb24Y'
    'BCABKAlSC2Rlc2NyaXB0aW9uEhwKCWluc3RhbGxlZBgFIAEoCFIJaW5zdGFsbGVkEhYKBnN0YX'
    'R1cxgGIAEoCVIGc3RhdHVzEiUKDmluc3RhbGxlZF9zaXplGAcgASgEUg1pbnN0YWxsZWRTaXpl'
    'EhgKB3NlY3Rpb24YCCABKAlSB3NlY3Rpb24=');

@$core.Deprecated('Use packageListDescriptor instead')
const PackageList$json = {
  '1': 'PackageList',
  '2': [
    {
      '1': 'packages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.PackageInfo',
      '10': 'packages'
    },
  ],
};

/// Descriptor for `PackageList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageListDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlTGlzdBIyCghwYWNrYWdlcxgBIAMoCzIWLnBpY29udHJvbC5QYWNrYWdlSW5mb1'
    'IIcGFja2FnZXM=');

@$core.Deprecated('Use packageCommandDescriptor instead')
const PackageCommand$json = {
  '1': 'PackageCommand',
  '2': [
    {'1': 'package_name', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
  ],
};

/// Descriptor for `PackageCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageCommandDescriptor = $convert.base64Decode(
    'Cg5QYWNrYWdlQ29tbWFuZBIhCgxwYWNrYWdlX25hbWUYASABKAlSC3BhY2thZ2VOYW1l');

@$core.Deprecated('Use packageDetailsRequestDescriptor instead')
const PackageDetailsRequest$json = {
  '1': 'PackageDetailsRequest',
  '2': [
    {'1': 'package_name', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
  ],
};

/// Descriptor for `PackageDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageDetailsRequestDescriptor = $convert.base64Decode(
    'ChVQYWNrYWdlRGV0YWlsc1JlcXVlc3QSIQoMcGFja2FnZV9uYW1lGAEgASgJUgtwYWNrYWdlTm'
    'FtZQ==');

@$core.Deprecated('Use packageDetailsDescriptor instead')
const PackageDetails$json = {
  '1': 'PackageDetails',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'architecture', '3': 3, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'long_description', '3': 5, '4': 1, '5': 9, '10': 'longDescription'},
    {'1': 'installed', '3': 6, '4': 1, '5': 8, '10': 'installed'},
    {'1': 'status', '3': 7, '4': 1, '5': 9, '10': 'status'},
    {'1': 'installed_size', '3': 8, '4': 1, '5': 4, '10': 'installedSize'},
    {'1': 'maintainer', '3': 9, '4': 1, '5': 9, '10': 'maintainer'},
    {'1': 'homepage', '3': 10, '4': 1, '5': 9, '10': 'homepage'},
    {'1': 'section', '3': 11, '4': 1, '5': 9, '10': 'section'},
    {'1': 'install_date', '3': 12, '4': 1, '5': 3, '10': 'installDate'},
    {'1': 'tags', '3': 13, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'source', '3': 14, '4': 1, '5': 9, '10': 'source'},
    {'1': 'priority', '3': 15, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'license', '3': 16, '4': 1, '5': 9, '10': 'license'},
  ],
};

/// Descriptor for `PackageDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageDetailsDescriptor = $convert.base64Decode(
    'Cg5QYWNrYWdlRGV0YWlscxISCgRuYW1lGAEgASgJUgRuYW1lEhgKB3ZlcnNpb24YAiABKAlSB3'
    'ZlcnNpb24SIgoMYXJjaGl0ZWN0dXJlGAMgASgJUgxhcmNoaXRlY3R1cmUSIAoLZGVzY3JpcHRp'
    'b24YBCABKAlSC2Rlc2NyaXB0aW9uEikKEGxvbmdfZGVzY3JpcHRpb24YBSABKAlSD2xvbmdEZX'
    'NjcmlwdGlvbhIcCglpbnN0YWxsZWQYBiABKAhSCWluc3RhbGxlZBIWCgZzdGF0dXMYByABKAlS'
    'BnN0YXR1cxIlCg5pbnN0YWxsZWRfc2l6ZRgIIAEoBFINaW5zdGFsbGVkU2l6ZRIeCgptYWludG'
    'FpbmVyGAkgASgJUgptYWludGFpbmVyEhoKCGhvbWVwYWdlGAogASgJUghob21lcGFnZRIYCgdz'
    'ZWN0aW9uGAsgASgJUgdzZWN0aW9uEiEKDGluc3RhbGxfZGF0ZRgMIAEoA1ILaW5zdGFsbERhdG'
    'USEgoEdGFncxgNIAMoCVIEdGFncxIWCgZzb3VyY2UYDiABKAlSBnNvdXJjZRIaCghwcmlvcml0'
    'eRgPIAEoBVIIcHJpb3JpdHkSGAoHbGljZW5zZRgQIAEoCVIHbGljZW5zZQ==');

@$core.Deprecated('Use packageDependenciesDescriptor instead')
const PackageDependencies$json = {
  '1': 'PackageDependencies',
  '2': [
    {'1': 'package_name', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
    {'1': 'depends', '3': 2, '4': 3, '5': 9, '10': 'depends'},
    {'1': 'required_by', '3': 3, '4': 3, '5': 9, '10': 'requiredBy'},
    {'1': 'recommends', '3': 4, '4': 3, '5': 9, '10': 'recommends'},
    {'1': 'suggests', '3': 5, '4': 3, '5': 9, '10': 'suggests'},
    {'1': 'conflicts', '3': 6, '4': 3, '5': 9, '10': 'conflicts'},
  ],
};

/// Descriptor for `PackageDependencies`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageDependenciesDescriptor = $convert.base64Decode(
    'ChNQYWNrYWdlRGVwZW5kZW5jaWVzEiEKDHBhY2thZ2VfbmFtZRgBIAEoCVILcGFja2FnZU5hbW'
    'USGAoHZGVwZW5kcxgCIAMoCVIHZGVwZW5kcxIfCgtyZXF1aXJlZF9ieRgDIAMoCVIKcmVxdWly'
    'ZWRCeRIeCgpyZWNvbW1lbmRzGAQgAygJUgpyZWNvbW1lbmRzEhoKCHN1Z2dlc3RzGAUgAygJUg'
    'hzdWdnZXN0cxIcCgljb25mbGljdHMYBiADKAlSCWNvbmZsaWN0cw==');

@$core.Deprecated('Use packageOperationLogDescriptor instead')
const PackageOperationLog$json = {
  '1': 'PackageOperationLog',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'level', '3': 2, '4': 1, '5': 9, '10': 'level'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'progress', '3': 4, '4': 1, '5': 1, '10': 'progress'},
    {'1': 'completed', '3': 5, '4': 1, '5': 8, '10': 'completed'},
    {'1': 'success', '3': 6, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `PackageOperationLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageOperationLogDescriptor = $convert.base64Decode(
    'ChNQYWNrYWdlT3BlcmF0aW9uTG9nEhwKCXRpbWVzdGFtcBgBIAEoA1IJdGltZXN0YW1wEhQKBW'
    'xldmVsGAIgASgJUgVsZXZlbBIYCgdtZXNzYWdlGAMgASgJUgdtZXNzYWdlEhoKCHByb2dyZXNz'
    'GAQgASgBUghwcm9ncmVzcxIcCgljb21wbGV0ZWQYBSABKAhSCWNvbXBsZXRlZBIYCgdzdWNjZX'
    'NzGAYgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use diskIOStatDescriptor instead')
const DiskIOStat$json = {
  '1': 'DiskIOStat',
  '2': [
    {'1': 'device', '3': 1, '4': 1, '5': 9, '10': 'device'},
    {'1': 'read_bytes', '3': 2, '4': 1, '5': 4, '10': 'readBytes'},
    {'1': 'write_bytes', '3': 3, '4': 1, '5': 4, '10': 'writeBytes'},
    {'1': 'read_count', '3': 4, '4': 1, '5': 4, '10': 'readCount'},
    {'1': 'write_count', '3': 5, '4': 1, '5': 4, '10': 'writeCount'},
  ],
};

/// Descriptor for `DiskIOStat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diskIOStatDescriptor = $convert.base64Decode(
    'CgpEaXNrSU9TdGF0EhYKBmRldmljZRgBIAEoCVIGZGV2aWNlEh0KCnJlYWRfYnl0ZXMYAiABKA'
    'RSCXJlYWRCeXRlcxIfCgt3cml0ZV9ieXRlcxgDIAEoBFIKd3JpdGVCeXRlcxIdCgpyZWFkX2Nv'
    'dW50GAQgASgEUglyZWFkQ291bnQSHwoLd3JpdGVfY291bnQYBSABKARSCndyaXRlQ291bnQ=');

@$core.Deprecated('Use versionInfoDescriptor instead')
const VersionInfo$json = {
  '1': 'VersionInfo',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'is_root', '3': 2, '4': 1, '5': 8, '10': 'isRoot'},
  ],
};

/// Descriptor for `VersionInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionInfoDescriptor = $convert.base64Decode(
    'CgtWZXJzaW9uSW5mbxIYCgd2ZXJzaW9uGAEgASgJUgd2ZXJzaW9uEhcKB2lzX3Jvb3QYAiABKA'
    'hSBmlzUm9vdA==');

@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = {
  '1': 'PingRequest',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
    {'1': 'timeout', '3': 3, '4': 1, '5': 5, '10': 'timeout'},
    {'1': 'packet_size', '3': 4, '4': 1, '5': 5, '10': 'packetSize'},
  ],
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode(
    'CgtQaW5nUmVxdWVzdBISCgRob3N0GAEgASgJUgRob3N0EhQKBWNvdW50GAIgASgFUgVjb3VudB'
    'IYCgd0aW1lb3V0GAMgASgFUgd0aW1lb3V0Eh8KC3BhY2tldF9zaXplGAQgASgFUgpwYWNrZXRT'
    'aXpl');

@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = {
  '1': 'PingResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'host', '3': 2, '4': 1, '5': 9, '10': 'host'},
    {'1': 'ip', '3': 3, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'latency', '3': 4, '4': 1, '5': 1, '10': 'latency'},
    {'1': 'sequence', '3': 5, '4': 1, '5': 5, '10': 'sequence'},
    {'1': 'ttl', '3': 6, '4': 1, '5': 5, '10': 'ttl'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
    {'1': 'finished', '3': 8, '4': 1, '5': 8, '10': 'finished'},
    {
      '1': 'statistics',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.picontrol.PingStats',
      '10': 'statistics'
    },
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode(
    'CgxQaW5nUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxISCgRob3N0GAIgASgJUg'
    'Rob3N0Eg4KAmlwGAMgASgJUgJpcBIYCgdsYXRlbmN5GAQgASgBUgdsYXRlbmN5EhoKCHNlcXVl'
    'bmNlGAUgASgFUghzZXF1ZW5jZRIQCgN0dGwYBiABKAVSA3R0bBIUCgVlcnJvchgHIAEoCVIFZX'
    'Jyb3ISGgoIZmluaXNoZWQYCCABKAhSCGZpbmlzaGVkEjQKCnN0YXRpc3RpY3MYCSABKAsyFC5w'
    'aWNvbnRyb2wuUGluZ1N0YXRzUgpzdGF0aXN0aWNz');

@$core.Deprecated('Use pingStatsDescriptor instead')
const PingStats$json = {
  '1': 'PingStats',
  '2': [
    {'1': 'packets_sent', '3': 1, '4': 1, '5': 5, '10': 'packetsSent'},
    {'1': 'packets_received', '3': 2, '4': 1, '5': 5, '10': 'packetsReceived'},
    {'1': 'packet_loss', '3': 3, '4': 1, '5': 1, '10': 'packetLoss'},
    {'1': 'min_latency', '3': 4, '4': 1, '5': 1, '10': 'minLatency'},
    {'1': 'max_latency', '3': 5, '4': 1, '5': 1, '10': 'maxLatency'},
    {'1': 'avg_latency', '3': 6, '4': 1, '5': 1, '10': 'avgLatency'},
  ],
};

/// Descriptor for `PingStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingStatsDescriptor = $convert.base64Decode(
    'CglQaW5nU3RhdHMSIQoMcGFja2V0c19zZW50GAEgASgFUgtwYWNrZXRzU2VudBIpChBwYWNrZX'
    'RzX3JlY2VpdmVkGAIgASgFUg9wYWNrZXRzUmVjZWl2ZWQSHwoLcGFja2V0X2xvc3MYAyABKAFS'
    'CnBhY2tldExvc3MSHwoLbWluX2xhdGVuY3kYBCABKAFSCm1pbkxhdGVuY3kSHwoLbWF4X2xhdG'
    'VuY3kYBSABKAFSCm1heExhdGVuY3kSHwoLYXZnX2xhdGVuY3kYBiABKAFSCmF2Z0xhdGVuY3k=');

@$core.Deprecated('Use portScanRequestDescriptor instead')
const PortScanRequest$json = {
  '1': 'PortScanRequest',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    {'1': 'ports', '3': 2, '4': 3, '5': 5, '10': 'ports'},
    {'1': 'start_port', '3': 3, '4': 1, '5': 5, '10': 'startPort'},
    {'1': 'end_port', '3': 4, '4': 1, '5': 5, '10': 'endPort'},
    {'1': 'timeout', '3': 5, '4': 1, '5': 5, '10': 'timeout'},
  ],
};

/// Descriptor for `PortScanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portScanRequestDescriptor = $convert.base64Decode(
    'Cg9Qb3J0U2NhblJlcXVlc3QSEgoEaG9zdBgBIAEoCVIEaG9zdBIUCgVwb3J0cxgCIAMoBVIFcG'
    '9ydHMSHQoKc3RhcnRfcG9ydBgDIAEoBVIJc3RhcnRQb3J0EhkKCGVuZF9wb3J0GAQgASgFUgdl'
    'bmRQb3J0EhgKB3RpbWVvdXQYBSABKAVSB3RpbWVvdXQ=');

@$core.Deprecated('Use portScanResponseDescriptor instead')
const PortScanResponse$json = {
  '1': 'PortScanResponse',
  '2': [
    {'1': 'port', '3': 1, '4': 1, '5': 5, '10': 'port'},
    {'1': 'open', '3': 2, '4': 1, '5': 8, '10': 'open'},
    {'1': 'service', '3': 3, '4': 1, '5': 9, '10': 'service'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'finished', '3': 5, '4': 1, '5': 8, '10': 'finished'},
    {'1': 'progress', '3': 6, '4': 1, '5': 5, '10': 'progress'},
  ],
};

/// Descriptor for `PortScanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portScanResponseDescriptor = $convert.base64Decode(
    'ChBQb3J0U2NhblJlc3BvbnNlEhIKBHBvcnQYASABKAVSBHBvcnQSEgoEb3BlbhgCIAEoCFIEb3'
    'BlbhIYCgdzZXJ2aWNlGAMgASgJUgdzZXJ2aWNlEhQKBWVycm9yGAQgASgJUgVlcnJvchIaCghm'
    'aW5pc2hlZBgFIAEoCFIIZmluaXNoZWQSGgoIcHJvZ3Jlc3MYBiABKAVSCHByb2dyZXNz');

@$core.Deprecated('Use dNSRequestDescriptor instead')
const DNSRequest$json = {
  '1': 'DNSRequest',
  '2': [
    {'1': 'hostname', '3': 1, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'record_type', '3': 2, '4': 1, '5': 9, '10': 'recordType'},
  ],
};

/// Descriptor for `DNSRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dNSRequestDescriptor = $convert.base64Decode(
    'CgpETlNSZXF1ZXN0EhoKCGhvc3RuYW1lGAEgASgJUghob3N0bmFtZRIfCgtyZWNvcmRfdHlwZR'
    'gCIAEoCVIKcmVjb3JkVHlwZQ==');

@$core.Deprecated('Use dNSResponseDescriptor instead')
const DNSResponse$json = {
  '1': 'DNSResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'hostname', '3': 2, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'addresses', '3': 3, '4': 3, '5': 9, '10': 'addresses'},
    {
      '1': 'records',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.picontrol.DNSRecord',
      '10': 'records'
    },
    {'1': 'query_time', '3': 5, '4': 1, '5': 1, '10': 'queryTime'},
    {'1': 'error', '3': 6, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `DNSResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dNSResponseDescriptor = $convert.base64Decode(
    'CgtETlNSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhoKCGhvc3RuYW1lGAIgAS'
    'gJUghob3N0bmFtZRIcCglhZGRyZXNzZXMYAyADKAlSCWFkZHJlc3NlcxIuCgdyZWNvcmRzGAQg'
    'AygLMhQucGljb250cm9sLkROU1JlY29yZFIHcmVjb3JkcxIdCgpxdWVyeV90aW1lGAUgASgBUg'
    'lxdWVyeVRpbWUSFAoFZXJyb3IYBiABKAlSBWVycm9y');

@$core.Deprecated('Use dNSRecordDescriptor instead')
const DNSRecord$json = {
  '1': 'DNSRecord',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
    {'1': 'ttl', '3': 3, '4': 1, '5': 5, '10': 'ttl'},
    {'1': 'priority', '3': 4, '4': 1, '5': 5, '10': 'priority'},
  ],
};

/// Descriptor for `DNSRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dNSRecordDescriptor = $convert.base64Decode(
    'CglETlNSZWNvcmQSEgoEdHlwZRgBIAEoCVIEdHlwZRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWUSEA'
    'oDdHRsGAMgASgFUgN0dGwSGgoIcHJpb3JpdHkYBCABKAVSCHByaW9yaXR5');

@$core.Deprecated('Use tracerouteRequestDescriptor instead')
const TracerouteRequest$json = {
  '1': 'TracerouteRequest',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    {'1': 'max_hops', '3': 2, '4': 1, '5': 5, '10': 'maxHops'},
    {'1': 'timeout', '3': 3, '4': 1, '5': 5, '10': 'timeout'},
  ],
};

/// Descriptor for `TracerouteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tracerouteRequestDescriptor = $convert.base64Decode(
    'ChFUcmFjZXJvdXRlUmVxdWVzdBISCgRob3N0GAEgASgJUgRob3N0EhkKCG1heF9ob3BzGAIgAS'
    'gFUgdtYXhIb3BzEhgKB3RpbWVvdXQYAyABKAVSB3RpbWVvdXQ=');

@$core.Deprecated('Use tracerouteResponseDescriptor instead')
const TracerouteResponse$json = {
  '1': 'TracerouteResponse',
  '2': [
    {'1': 'hop', '3': 1, '4': 1, '5': 5, '10': 'hop'},
    {'1': 'ip', '3': 2, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'hostname', '3': 3, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'latency', '3': 4, '4': 1, '5': 1, '10': 'latency'},
    {'1': 'timeout', '3': 5, '4': 1, '5': 8, '10': 'timeout'},
    {'1': 'finished', '3': 6, '4': 1, '5': 8, '10': 'finished'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `TracerouteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tracerouteResponseDescriptor = $convert.base64Decode(
    'ChJUcmFjZXJvdXRlUmVzcG9uc2USEAoDaG9wGAEgASgFUgNob3ASDgoCaXAYAiABKAlSAmlwEh'
    'oKCGhvc3RuYW1lGAMgASgJUghob3N0bmFtZRIYCgdsYXRlbmN5GAQgASgBUgdsYXRlbmN5EhgK'
    'B3RpbWVvdXQYBSABKAhSB3RpbWVvdXQSGgoIZmluaXNoZWQYBiABKAhSCGZpbmlzaGVkEhQKBW'
    'Vycm9yGAcgASgJUgVlcnJvcg==');

@$core.Deprecated('Use wifiInfoDescriptor instead')
const WifiInfo$json = {
  '1': 'WifiInfo',
  '2': [
    {'1': 'connected', '3': 1, '4': 1, '5': 8, '10': 'connected'},
    {'1': 'ssid', '3': 2, '4': 1, '5': 9, '10': 'ssid'},
    {'1': 'bssid', '3': 3, '4': 1, '5': 9, '10': 'bssid'},
    {'1': 'signal_strength', '3': 4, '4': 1, '5': 5, '10': 'signalStrength'},
    {'1': 'signal_quality', '3': 5, '4': 1, '5': 5, '10': 'signalQuality'},
    {'1': 'frequency', '3': 6, '4': 1, '5': 1, '10': 'frequency'},
    {'1': 'security', '3': 7, '4': 1, '5': 9, '10': 'security'},
    {'1': 'link_speed', '3': 8, '4': 1, '5': 1, '10': 'linkSpeed'},
    {'1': 'ip_address', '3': 9, '4': 1, '5': 9, '10': 'ipAddress'},
    {
      '1': 'available_networks',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.picontrol.WifiNetwork',
      '10': 'availableNetworks'
    },
  ],
};

/// Descriptor for `WifiInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wifiInfoDescriptor = $convert.base64Decode(
    'CghXaWZpSW5mbxIcCgljb25uZWN0ZWQYASABKAhSCWNvbm5lY3RlZBISCgRzc2lkGAIgASgJUg'
    'Rzc2lkEhQKBWJzc2lkGAMgASgJUgVic3NpZBInCg9zaWduYWxfc3RyZW5ndGgYBCABKAVSDnNp'
    'Z25hbFN0cmVuZ3RoEiUKDnNpZ25hbF9xdWFsaXR5GAUgASgFUg1zaWduYWxRdWFsaXR5EhwKCW'
    'ZyZXF1ZW5jeRgGIAEoAVIJZnJlcXVlbmN5EhoKCHNlY3VyaXR5GAcgASgJUghzZWN1cml0eRId'
    'CgpsaW5rX3NwZWVkGAggASgBUglsaW5rU3BlZWQSHQoKaXBfYWRkcmVzcxgJIAEoCVIJaXBBZG'
    'RyZXNzEkUKEmF2YWlsYWJsZV9uZXR3b3JrcxgKIAMoCzIWLnBpY29udHJvbC5XaWZpTmV0d29y'
    'a1IRYXZhaWxhYmxlTmV0d29ya3M=');

@$core.Deprecated('Use wifiNetworkDescriptor instead')
const WifiNetwork$json = {
  '1': 'WifiNetwork',
  '2': [
    {'1': 'ssid', '3': 1, '4': 1, '5': 9, '10': 'ssid'},
    {'1': 'bssid', '3': 2, '4': 1, '5': 9, '10': 'bssid'},
    {'1': 'signal_strength', '3': 3, '4': 1, '5': 5, '10': 'signalStrength'},
    {'1': 'signal_quality', '3': 4, '4': 1, '5': 5, '10': 'signalQuality'},
    {'1': 'frequency', '3': 5, '4': 1, '5': 1, '10': 'frequency'},
    {'1': 'security', '3': 6, '4': 1, '5': 9, '10': 'security'},
  ],
};

/// Descriptor for `WifiNetwork`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wifiNetworkDescriptor = $convert.base64Decode(
    'CgtXaWZpTmV0d29yaxISCgRzc2lkGAEgASgJUgRzc2lkEhQKBWJzc2lkGAIgASgJUgVic3NpZB'
    'InCg9zaWduYWxfc3RyZW5ndGgYAyABKAVSDnNpZ25hbFN0cmVuZ3RoEiUKDnNpZ25hbF9xdWFs'
    'aXR5GAQgASgFUg1zaWduYWxRdWFsaXR5EhwKCWZyZXF1ZW5jeRgFIAEoAVIJZnJlcXVlbmN5Eh'
    'oKCHNlY3VyaXR5GAYgASgJUghzZWN1cml0eQ==');

@$core.Deprecated('Use speedTestRequestDescriptor instead')
const SpeedTestRequest$json = {
  '1': 'SpeedTestRequest',
  '2': [
    {'1': 'test_download', '3': 1, '4': 1, '5': 8, '10': 'testDownload'},
    {'1': 'test_upload', '3': 2, '4': 1, '5': 8, '10': 'testUpload'},
    {'1': 'duration', '3': 3, '4': 1, '5': 5, '10': 'duration'},
  ],
};

/// Descriptor for `SpeedTestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speedTestRequestDescriptor = $convert.base64Decode(
    'ChBTcGVlZFRlc3RSZXF1ZXN0EiMKDXRlc3RfZG93bmxvYWQYASABKAhSDHRlc3REb3dubG9hZB'
    'IfCgt0ZXN0X3VwbG9hZBgCIAEoCFIKdGVzdFVwbG9hZBIaCghkdXJhdGlvbhgDIAEoBVIIZHVy'
    'YXRpb24=');

@$core.Deprecated('Use speedTestResponseDescriptor instead')
const SpeedTestResponse$json = {
  '1': 'SpeedTestResponse',
  '2': [
    {'1': 'phase', '3': 1, '4': 1, '5': 9, '10': 'phase'},
    {'1': 'download_speed', '3': 2, '4': 1, '5': 1, '10': 'downloadSpeed'},
    {'1': 'upload_speed', '3': 3, '4': 1, '5': 1, '10': 'uploadSpeed'},
    {'1': 'progress', '3': 4, '4': 1, '5': 1, '10': 'progress'},
    {'1': 'latency', '3': 5, '4': 1, '5': 1, '10': 'latency'},
    {'1': 'server', '3': 6, '4': 1, '5': 9, '10': 'server'},
    {'1': 'finished', '3': 7, '4': 1, '5': 8, '10': 'finished'},
    {'1': 'error', '3': 8, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `SpeedTestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speedTestResponseDescriptor = $convert.base64Decode(
    'ChFTcGVlZFRlc3RSZXNwb25zZRIUCgVwaGFzZRgBIAEoCVIFcGhhc2USJQoOZG93bmxvYWRfc3'
    'BlZWQYAiABKAFSDWRvd25sb2FkU3BlZWQSIQoMdXBsb2FkX3NwZWVkGAMgASgBUgt1cGxvYWRT'
    'cGVlZBIaCghwcm9ncmVzcxgEIAEoAVIIcHJvZ3Jlc3MSGAoHbGF0ZW5jeRgFIAEoAVIHbGF0ZW'
    '5jeRIWCgZzZXJ2ZXIYBiABKAlSBnNlcnZlchIaCghmaW5pc2hlZBgHIAEoCFIIZmluaXNoZWQS'
    'FAoFZXJyb3IYCCABKAlSBWVycm9y');

@$core.Deprecated('Use fileChunkDescriptor instead')
const FileChunk$json = {
  '1': 'FileChunk',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
    {'1': 'offset', '3': 3, '4': 1, '5': 3, '10': 'offset'},
    {'1': 'total_size', '3': 4, '4': 1, '5': 3, '10': 'totalSize'},
    {'1': 'is_final', '3': 5, '4': 1, '5': 8, '10': 'isFinal'},
    {'1': 'error', '3': 6, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `FileChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileChunkDescriptor = $convert.base64Decode(
    'CglGaWxlQ2h1bmsSEgoEcGF0aBgBIAEoCVIEcGF0aBISCgRkYXRhGAIgASgMUgRkYXRhEhYKBm'
    '9mZnNldBgDIAEoA1IGb2Zmc2V0Eh0KCnRvdGFsX3NpemUYBCABKANSCXRvdGFsU2l6ZRIZCghp'
    'c19maW5hbBgFIAEoCFIHaXNGaW5hbBIUCgVlcnJvchgGIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use fileUploadResponseDescriptor instead')
const FileUploadResponse$json = {
  '1': 'FileUploadResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'path', '3': 2, '4': 1, '5': 9, '10': 'path'},
    {'1': 'bytes_written', '3': 3, '4': 1, '5': 3, '10': 'bytesWritten'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'duration', '3': 5, '4': 1, '5': 1, '10': 'duration'},
  ],
};

/// Descriptor for `FileUploadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileUploadResponseDescriptor = $convert.base64Decode(
    'ChJGaWxlVXBsb2FkUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxISCgRwYXRoGA'
    'IgASgJUgRwYXRoEiMKDWJ5dGVzX3dyaXR0ZW4YAyABKANSDGJ5dGVzV3JpdHRlbhIUCgVlcnJv'
    'chgEIAEoCVIFZXJyb3ISGgoIZHVyYXRpb24YBSABKAFSCGR1cmF0aW9u');

@$core.Deprecated('Use fileDownloadRequestDescriptor instead')
const FileDownloadRequest$json = {
  '1': 'FileDownloadRequest',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'offset', '3': 2, '4': 1, '5': 3, '10': 'offset'},
  ],
};

/// Descriptor for `FileDownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDownloadRequestDescriptor = $convert.base64Decode(
    'ChNGaWxlRG93bmxvYWRSZXF1ZXN0EhIKBHBhdGgYASABKAlSBHBhdGgSFgoGb2Zmc2V0GAIgAS'
    'gDUgZvZmZzZXQ=');

@$core.Deprecated('Use fileDeleteRequestDescriptor instead')
const FileDeleteRequest$json = {
  '1': 'FileDeleteRequest',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'is_directory', '3': 2, '4': 1, '5': 8, '10': 'isDirectory'},
  ],
};

/// Descriptor for `FileDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDeleteRequestDescriptor = $convert.base64Decode(
    'ChFGaWxlRGVsZXRlUmVxdWVzdBISCgRwYXRoGAEgASgJUgRwYXRoEiEKDGlzX2RpcmVjdG9yeR'
    'gCIAEoCFILaXNEaXJlY3Rvcnk=');

@$core.Deprecated('Use fileDeleteResponseDescriptor instead')
const FileDeleteResponse$json = {
  '1': 'FileDeleteResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'path', '3': 2, '4': 1, '5': 9, '10': 'path'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `FileDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDeleteResponseDescriptor = $convert.base64Decode(
    'ChJGaWxlRGVsZXRlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxISCgRwYXRoGA'
    'IgASgJUgRwYXRoEhQKBWVycm9yGAMgASgJUgVlcnJvcg==');

@$core.Deprecated('Use dockerFilterDescriptor instead')
const DockerFilter$json = {
  '1': 'DockerFilter',
  '2': [
    {'1': 'all', '3': 1, '4': 1, '5': 8, '10': 'all'},
  ],
};

/// Descriptor for `DockerFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dockerFilterDescriptor =
    $convert.base64Decode('CgxEb2NrZXJGaWx0ZXISEAoDYWxsGAEgASgIUgNhbGw=');

@$core.Deprecated('Use containerIdDescriptor instead')
const ContainerId$json = {
  '1': 'ContainerId',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ContainerId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List containerIdDescriptor =
    $convert.base64Decode('CgtDb250YWluZXJJZBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use containerListDescriptor instead')
const ContainerList$json = {
  '1': 'ContainerList',
  '2': [
    {
      '1': 'containers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ContainerInfo',
      '10': 'containers'
    },
  ],
};

/// Descriptor for `ContainerList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List containerListDescriptor = $convert.base64Decode(
    'Cg1Db250YWluZXJMaXN0EjgKCmNvbnRhaW5lcnMYASADKAsyGC5waWNvbnRyb2wuQ29udGFpbm'
    'VySW5mb1IKY29udGFpbmVycw==');

@$core.Deprecated('Use containerInfoDescriptor instead')
const ContainerInfo$json = {
  '1': 'ContainerInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'names', '3': 2, '4': 3, '5': 9, '10': 'names'},
    {'1': 'image', '3': 3, '4': 1, '5': 9, '10': 'image'},
    {'1': 'state', '3': 4, '4': 1, '5': 9, '10': 'state'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'created', '3': 6, '4': 1, '5': 3, '10': 'created'},
    {'1': 'ports', '3': 7, '4': 3, '5': 9, '10': 'ports'},
    {'1': 'compose_project', '3': 8, '4': 1, '5': 9, '10': 'composeProject'},
    {'1': 'compose_service', '3': 9, '4': 1, '5': 9, '10': 'composeService'},
  ],
};

/// Descriptor for `ContainerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List containerInfoDescriptor = $convert.base64Decode(
    'Cg1Db250YWluZXJJbmZvEg4KAmlkGAEgASgJUgJpZBIUCgVuYW1lcxgCIAMoCVIFbmFtZXMSFA'
    'oFaW1hZ2UYAyABKAlSBWltYWdlEhQKBXN0YXRlGAQgASgJUgVzdGF0ZRIWCgZzdGF0dXMYBSAB'
    'KAlSBnN0YXR1cxIYCgdjcmVhdGVkGAYgASgDUgdjcmVhdGVkEhQKBXBvcnRzGAcgAygJUgVwb3'
    'J0cxInCg9jb21wb3NlX3Byb2plY3QYCCABKAlSDmNvbXBvc2VQcm9qZWN0EicKD2NvbXBvc2Vf'
    'c2VydmljZRgJIAEoCVIOY29tcG9zZVNlcnZpY2U=');

@$core.Deprecated('Use dockerInfoDescriptor instead')
const DockerInfo$json = {
  '1': 'DockerInfo',
  '2': [
    {'1': 'server_version', '3': 1, '4': 1, '5': 9, '10': 'serverVersion'},
    {'1': 'containers', '3': 2, '4': 1, '5': 5, '10': 'containers'},
    {'1': 'running', '3': 3, '4': 1, '5': 5, '10': 'running'},
    {'1': 'paused', '3': 4, '4': 1, '5': 5, '10': 'paused'},
    {'1': 'stopped', '3': 5, '4': 1, '5': 5, '10': 'stopped'},
    {'1': 'images', '3': 6, '4': 1, '5': 5, '10': 'images'},
    {'1': 'storage_driver', '3': 7, '4': 1, '5': 9, '10': 'storageDriver'},
    {'1': 'operating_system', '3': 8, '4': 1, '5': 9, '10': 'operatingSystem'},
    {'1': 'architecture', '3': 9, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'memory_total', '3': 10, '4': 1, '5': 4, '10': 'memoryTotal'},
    {'1': 'cpus', '3': 11, '4': 1, '5': 5, '10': 'cpus'},
  ],
};

/// Descriptor for `DockerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dockerInfoDescriptor = $convert.base64Decode(
    'CgpEb2NrZXJJbmZvEiUKDnNlcnZlcl92ZXJzaW9uGAEgASgJUg1zZXJ2ZXJWZXJzaW9uEh4KCm'
    'NvbnRhaW5lcnMYAiABKAVSCmNvbnRhaW5lcnMSGAoHcnVubmluZxgDIAEoBVIHcnVubmluZxIW'
    'CgZwYXVzZWQYBCABKAVSBnBhdXNlZBIYCgdzdG9wcGVkGAUgASgFUgdzdG9wcGVkEhYKBmltYW'
    'dlcxgGIAEoBVIGaW1hZ2VzEiUKDnN0b3JhZ2VfZHJpdmVyGAcgASgJUg1zdG9yYWdlRHJpdmVy'
    'EikKEG9wZXJhdGluZ19zeXN0ZW0YCCABKAlSD29wZXJhdGluZ1N5c3RlbRIiCgxhcmNoaXRlY3'
    'R1cmUYCSABKAlSDGFyY2hpdGVjdHVyZRIhCgxtZW1vcnlfdG90YWwYCiABKARSC21lbW9yeVRv'
    'dGFsEhIKBGNwdXMYCyABKAVSBGNwdXM=');

@$core.Deprecated('Use containerActionRequestDescriptor instead')
const ContainerActionRequest$json = {
  '1': 'ContainerActionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'op',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.picontrol.ContainerOp',
      '10': 'op'
    },
    {'1': 'force', '3': 3, '4': 1, '5': 8, '10': 'force'},
    {'1': 'remove_volumes', '3': 4, '4': 1, '5': 8, '10': 'removeVolumes'},
  ],
};

/// Descriptor for `ContainerActionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List containerActionRequestDescriptor = $convert.base64Decode(
    'ChZDb250YWluZXJBY3Rpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBImCgJvcBgCIAEoDjIWLn'
    'BpY29udHJvbC5Db250YWluZXJPcFICb3ASFAoFZm9yY2UYAyABKAhSBWZvcmNlEiUKDnJlbW92'
    'ZV92b2x1bWVzGAQgASgIUg1yZW1vdmVWb2x1bWVz');

@$core.Deprecated('Use containerMountDescriptor instead')
const ContainerMount$json = {
  '1': 'ContainerMount',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'source', '3': 2, '4': 1, '5': 9, '10': 'source'},
    {'1': 'destination', '3': 3, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'read_write', '3': 4, '4': 1, '5': 8, '10': 'readWrite'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ContainerMount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List containerMountDescriptor = $convert.base64Decode(
    'Cg5Db250YWluZXJNb3VudBISCgR0eXBlGAEgASgJUgR0eXBlEhYKBnNvdXJjZRgCIAEoCVIGc2'
    '91cmNlEiAKC2Rlc3RpbmF0aW9uGAMgASgJUgtkZXN0aW5hdGlvbhIdCgpyZWFkX3dyaXRlGAQg'
    'ASgIUglyZWFkV3JpdGUSEgoEbmFtZRgFIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use containerDetailsDescriptor instead')
const ContainerDetails$json = {
  '1': 'ContainerDetails',
  '2': [
    {
      '1': 'info',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.picontrol.ContainerInfo',
      '10': 'info'
    },
    {'1': 'command', '3': 2, '4': 1, '5': 9, '10': 'command'},
    {'1': 'restart_policy', '3': 3, '4': 1, '5': 9, '10': 'restartPolicy'},
    {'1': 'health', '3': 4, '4': 1, '5': 9, '10': 'health'},
    {'1': 'exit_code', '3': 5, '4': 1, '5': 5, '10': 'exitCode'},
    {'1': 'started_at', '3': 6, '4': 1, '5': 3, '10': 'startedAt'},
    {'1': 'finished_at', '3': 7, '4': 1, '5': 3, '10': 'finishedAt'},
    {'1': 'networks', '3': 8, '4': 3, '5': 9, '10': 'networks'},
    {'1': 'ip_addresses', '3': 9, '4': 3, '5': 9, '10': 'ipAddresses'},
    {
      '1': 'mounts',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ContainerMount',
      '10': 'mounts'
    },
    {'1': 'env', '3': 11, '4': 3, '5': 9, '10': 'env'},
    {'1': 'hostname', '3': 12, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'restart_count', '3': 13, '4': 1, '5': 5, '10': 'restartCount'},
    {'1': 'tty', '3': 14, '4': 1, '5': 8, '10': 'tty'},
  ],
};

/// Descriptor for `ContainerDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List containerDetailsDescriptor = $convert.base64Decode(
    'ChBDb250YWluZXJEZXRhaWxzEiwKBGluZm8YASABKAsyGC5waWNvbnRyb2wuQ29udGFpbmVySW'
    '5mb1IEaW5mbxIYCgdjb21tYW5kGAIgASgJUgdjb21tYW5kEiUKDnJlc3RhcnRfcG9saWN5GAMg'
    'ASgJUg1yZXN0YXJ0UG9saWN5EhYKBmhlYWx0aBgEIAEoCVIGaGVhbHRoEhsKCWV4aXRfY29kZR'
    'gFIAEoBVIIZXhpdENvZGUSHQoKc3RhcnRlZF9hdBgGIAEoA1IJc3RhcnRlZEF0Eh8KC2Zpbmlz'
    'aGVkX2F0GAcgASgDUgpmaW5pc2hlZEF0EhoKCG5ldHdvcmtzGAggAygJUghuZXR3b3JrcxIhCg'
    'xpcF9hZGRyZXNzZXMYCSADKAlSC2lwQWRkcmVzc2VzEjEKBm1vdW50cxgKIAMoCzIZLnBpY29u'
    'dHJvbC5Db250YWluZXJNb3VudFIGbW91bnRzEhAKA2VudhgLIAMoCVIDZW52EhoKCGhvc3RuYW'
    '1lGAwgASgJUghob3N0bmFtZRIjCg1yZXN0YXJ0X2NvdW50GA0gASgFUgxyZXN0YXJ0Q291bnQS'
    'EAoDdHR5GA4gASgIUgN0dHk=');

@$core.Deprecated('Use containerStatsDescriptor instead')
const ContainerStats$json = {
  '1': 'ContainerStats',
  '2': [
    {'1': 'cpu_percent', '3': 1, '4': 1, '5': 1, '10': 'cpuPercent'},
    {'1': 'memory_usage', '3': 2, '4': 1, '5': 4, '10': 'memoryUsage'},
    {'1': 'memory_limit', '3': 3, '4': 1, '5': 4, '10': 'memoryLimit'},
    {'1': 'net_rx', '3': 4, '4': 1, '5': 4, '10': 'netRx'},
    {'1': 'net_tx', '3': 5, '4': 1, '5': 4, '10': 'netTx'},
    {'1': 'block_read', '3': 6, '4': 1, '5': 4, '10': 'blockRead'},
    {'1': 'block_write', '3': 7, '4': 1, '5': 4, '10': 'blockWrite'},
    {'1': 'pids', '3': 8, '4': 1, '5': 4, '10': 'pids'},
  ],
};

/// Descriptor for `ContainerStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List containerStatsDescriptor = $convert.base64Decode(
    'Cg5Db250YWluZXJTdGF0cxIfCgtjcHVfcGVyY2VudBgBIAEoAVIKY3B1UGVyY2VudBIhCgxtZW'
    '1vcnlfdXNhZ2UYAiABKARSC21lbW9yeVVzYWdlEiEKDG1lbW9yeV9saW1pdBgDIAEoBFILbWVt'
    'b3J5TGltaXQSFQoGbmV0X3J4GAQgASgEUgVuZXRSeBIVCgZuZXRfdHgYBSABKARSBW5ldFR4Eh'
    '0KCmJsb2NrX3JlYWQYBiABKARSCWJsb2NrUmVhZBIfCgtibG9ja193cml0ZRgHIAEoBFIKYmxv'
    'Y2tXcml0ZRISCgRwaWRzGAggASgEUgRwaWRz');

@$core.Deprecated('Use dockerImageDescriptor instead')
const DockerImage$json = {
  '1': 'DockerImage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tags', '3': 2, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'size', '3': 3, '4': 1, '5': 3, '10': 'size'},
    {'1': 'created', '3': 4, '4': 1, '5': 3, '10': 'created'},
    {'1': 'containers', '3': 5, '4': 1, '5': 5, '10': 'containers'},
  ],
};

/// Descriptor for `DockerImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dockerImageDescriptor = $convert.base64Decode(
    'CgtEb2NrZXJJbWFnZRIOCgJpZBgBIAEoCVICaWQSEgoEdGFncxgCIAMoCVIEdGFncxISCgRzaX'
    'plGAMgASgDUgRzaXplEhgKB2NyZWF0ZWQYBCABKANSB2NyZWF0ZWQSHgoKY29udGFpbmVycxgF'
    'IAEoBVIKY29udGFpbmVycw==');

@$core.Deprecated('Use imageListDescriptor instead')
const ImageList$json = {
  '1': 'ImageList',
  '2': [
    {
      '1': 'images',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.DockerImage',
      '10': 'images'
    },
  ],
};

/// Descriptor for `ImageList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageListDescriptor = $convert.base64Decode(
    'CglJbWFnZUxpc3QSLgoGaW1hZ2VzGAEgAygLMhYucGljb250cm9sLkRvY2tlckltYWdlUgZpbW'
    'FnZXM=');

@$core.Deprecated('Use imageRemoveRequestDescriptor instead')
const ImageRemoveRequest$json = {
  '1': 'ImageRemoveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'force', '3': 2, '4': 1, '5': 8, '10': 'force'},
  ],
};

/// Descriptor for `ImageRemoveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageRemoveRequestDescriptor = $convert.base64Decode(
    'ChJJbWFnZVJlbW92ZVJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhQKBWZvcmNlGAIgASgIUgVmb3'
    'JjZQ==');

@$core.Deprecated('Use pruneRequestDescriptor instead')
const PruneRequest$json = {
  '1': 'PruneRequest',
  '2': [
    {
      '1': 'target',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.picontrol.PruneTarget',
      '10': 'target'
    },
  ],
};

/// Descriptor for `PruneRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pruneRequestDescriptor = $convert.base64Decode(
    'CgxQcnVuZVJlcXVlc3QSLgoGdGFyZ2V0GAEgASgOMhYucGljb250cm9sLlBydW5lVGFyZ2V0Ug'
    'Z0YXJnZXQ=');

@$core.Deprecated('Use pruneResultDescriptor instead')
const PruneResult$json = {
  '1': 'PruneResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'space_reclaimed', '3': 3, '4': 1, '5': 4, '10': 'spaceReclaimed'},
    {'1': 'deleted', '3': 4, '4': 1, '5': 5, '10': 'deleted'},
  ],
};

/// Descriptor for `PruneResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pruneResultDescriptor = $convert.base64Decode(
    'CgtQcnVuZVJlc3VsdBIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2UYAiABKA'
    'lSB21lc3NhZ2USJwoPc3BhY2VfcmVjbGFpbWVkGAMgASgEUg5zcGFjZVJlY2xhaW1lZBIYCgdk'
    'ZWxldGVkGAQgASgFUgdkZWxldGVk');

@$core.Deprecated('Use logRequestDescriptor instead')
const LogRequest$json = {
  '1': 'LogRequest',
  '2': [
    {'1': 'container_id', '3': 1, '4': 1, '5': 9, '10': 'containerId'},
    {'1': 'follow', '3': 2, '4': 1, '5': 8, '10': 'follow'},
    {'1': 'tail', '3': 3, '4': 1, '5': 5, '10': 'tail'},
  ],
};

/// Descriptor for `LogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logRequestDescriptor = $convert.base64Decode(
    'CgpMb2dSZXF1ZXN0EiEKDGNvbnRhaW5lcl9pZBgBIAEoCVILY29udGFpbmVySWQSFgoGZm9sbG'
    '93GAIgASgIUgZmb2xsb3cSEgoEdGFpbBgDIAEoBVIEdGFpbA==');

@$core.Deprecated('Use systemUpdateStatusDescriptor instead')
const SystemUpdateStatus$json = {
  '1': 'SystemUpdateStatus',
  '2': [
    {'1': 'os_name', '3': 1, '4': 1, '5': 9, '10': 'osName'},
    {'1': 'kernel_version', '3': 2, '4': 1, '5': 9, '10': 'kernelVersion'},
    {'1': 'architecture', '3': 3, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'upgradable_count', '3': 4, '4': 1, '5': 5, '10': 'upgradableCount'},
    {
      '1': 'upgradable_packages',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.picontrol.UpgradablePackage',
      '10': 'upgradablePackages'
    },
    {'1': 'last_update', '3': 6, '4': 1, '5': 9, '10': 'lastUpdate'},
    {'1': 'uptime', '3': 7, '4': 1, '5': 9, '10': 'uptime'},
    {'1': 'reboot_required', '3': 8, '4': 1, '5': 8, '10': 'rebootRequired'},
    {'1': 'reboot_packages', '3': 9, '4': 3, '5': 9, '10': 'rebootPackages'},
    {'1': 'last_update_unix', '3': 10, '4': 1, '5': 3, '10': 'lastUpdateUnix'},
  ],
};

/// Descriptor for `SystemUpdateStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemUpdateStatusDescriptor = $convert.base64Decode(
    'ChJTeXN0ZW1VcGRhdGVTdGF0dXMSFwoHb3NfbmFtZRgBIAEoCVIGb3NOYW1lEiUKDmtlcm5lbF'
    '92ZXJzaW9uGAIgASgJUg1rZXJuZWxWZXJzaW9uEiIKDGFyY2hpdGVjdHVyZRgDIAEoCVIMYXJj'
    'aGl0ZWN0dXJlEikKEHVwZ3JhZGFibGVfY291bnQYBCABKAVSD3VwZ3JhZGFibGVDb3VudBJNCh'
    'N1cGdyYWRhYmxlX3BhY2thZ2VzGAUgAygLMhwucGljb250cm9sLlVwZ3JhZGFibGVQYWNrYWdl'
    'UhJ1cGdyYWRhYmxlUGFja2FnZXMSHwoLbGFzdF91cGRhdGUYBiABKAlSCmxhc3RVcGRhdGUSFg'
    'oGdXB0aW1lGAcgASgJUgZ1cHRpbWUSJwoPcmVib290X3JlcXVpcmVkGAggASgIUg5yZWJvb3RS'
    'ZXF1aXJlZBInCg9yZWJvb3RfcGFja2FnZXMYCSADKAlSDnJlYm9vdFBhY2thZ2VzEigKEGxhc3'
    'RfdXBkYXRlX3VuaXgYCiABKANSDmxhc3RVcGRhdGVVbml4');

@$core.Deprecated('Use upgradablePackageDescriptor instead')
const UpgradablePackage$json = {
  '1': 'UpgradablePackage',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'current_version', '3': 2, '4': 1, '5': 9, '10': 'currentVersion'},
    {'1': 'new_version', '3': 3, '4': 1, '5': 9, '10': 'newVersion'},
    {'1': 'architecture', '3': 4, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'security', '3': 5, '4': 1, '5': 8, '10': 'security'},
    {'1': 'source', '3': 6, '4': 1, '5': 9, '10': 'source'},
  ],
};

/// Descriptor for `UpgradablePackage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List upgradablePackageDescriptor = $convert.base64Decode(
    'ChFVcGdyYWRhYmxlUGFja2FnZRISCgRuYW1lGAEgASgJUgRuYW1lEicKD2N1cnJlbnRfdmVyc2'
    'lvbhgCIAEoCVIOY3VycmVudFZlcnNpb24SHwoLbmV3X3ZlcnNpb24YAyABKAlSCm5ld1ZlcnNp'
    'b24SIgoMYXJjaGl0ZWN0dXJlGAQgASgJUgxhcmNoaXRlY3R1cmUSGgoIc2VjdXJpdHkYBSABKA'
    'hSCHNlY3VyaXR5EhYKBnNvdXJjZRgGIAEoCVIGc291cmNl');

@$core.Deprecated('Use upgradeProgressDescriptor instead')
const UpgradeProgress$json = {
  '1': 'UpgradeProgress',
  '2': [
    {'1': 'line', '3': 1, '4': 1, '5': 9, '10': 'line'},
    {'1': 'phase', '3': 2, '4': 1, '5': 9, '10': 'phase'},
    {'1': 'percent', '3': 3, '4': 1, '5': 5, '10': 'percent'},
    {'1': 'is_complete', '3': 4, '4': 1, '5': 8, '10': 'isComplete'},
    {'1': 'success', '3': 5, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `UpgradeProgress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List upgradeProgressDescriptor = $convert.base64Decode(
    'Cg9VcGdyYWRlUHJvZ3Jlc3MSEgoEbGluZRgBIAEoCVIEbGluZRIUCgVwaGFzZRgCIAEoCVIFcG'
    'hhc2USGAoHcGVyY2VudBgDIAEoBVIHcGVyY2VudBIfCgtpc19jb21wbGV0ZRgEIAEoCFIKaXND'
    'b21wbGV0ZRIYCgdzdWNjZXNzGAUgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use pm2InfoDescriptor instead')
const Pm2Info$json = {
  '1': 'Pm2Info',
  '2': [
    {'1': 'installed', '3': 1, '4': 1, '5': 8, '10': 'installed'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'pm2_path', '3': 3, '4': 1, '5': 9, '10': 'pm2Path'},
    {'1': 'node_version', '3': 4, '4': 1, '5': 9, '10': 'nodeVersion'},
    {'1': 'user', '3': 5, '4': 1, '5': 9, '10': 'user'},
    {'1': 'home', '3': 6, '4': 1, '5': 9, '10': 'home'},
    {'1': 'pm2_home', '3': 7, '4': 1, '5': 9, '10': 'pm2Home'},
    {'1': 'daemon_running', '3': 8, '4': 1, '5': 8, '10': 'daemonRunning'},
    {'1': 'daemon_pid', '3': 9, '4': 1, '5': 5, '10': 'daemonPid'},
    {'1': 'startup_enabled', '3': 10, '4': 1, '5': 8, '10': 'startupEnabled'},
    {'1': 'startup_service', '3': 11, '4': 1, '5': 9, '10': 'startupService'},
    {'1': 'dump_exists', '3': 12, '4': 1, '5': 8, '10': 'dumpExists'},
    {
      '1': 'dump_process_count',
      '3': 13,
      '4': 1,
      '5': 5,
      '10': 'dumpProcessCount'
    },
    {
      '1': 'module_config_json',
      '3': 14,
      '4': 1,
      '5': 9,
      '10': 'moduleConfigJson'
    },
    {'1': 'npm_available', '3': 15, '4': 1, '5': 8, '10': 'npmAvailable'},
    {'1': 'agent_is_root', '3': 16, '4': 1, '5': 8, '10': 'agentIsRoot'},
    {'1': 'error', '3': 17, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `Pm2Info`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2InfoDescriptor = $convert.base64Decode(
    'CgdQbTJJbmZvEhwKCWluc3RhbGxlZBgBIAEoCFIJaW5zdGFsbGVkEhgKB3ZlcnNpb24YAiABKA'
    'lSB3ZlcnNpb24SGQoIcG0yX3BhdGgYAyABKAlSB3BtMlBhdGgSIQoMbm9kZV92ZXJzaW9uGAQg'
    'ASgJUgtub2RlVmVyc2lvbhISCgR1c2VyGAUgASgJUgR1c2VyEhIKBGhvbWUYBiABKAlSBGhvbW'
    'USGQoIcG0yX2hvbWUYByABKAlSB3BtMkhvbWUSJQoOZGFlbW9uX3J1bm5pbmcYCCABKAhSDWRh'
    'ZW1vblJ1bm5pbmcSHQoKZGFlbW9uX3BpZBgJIAEoBVIJZGFlbW9uUGlkEicKD3N0YXJ0dXBfZW'
    '5hYmxlZBgKIAEoCFIOc3RhcnR1cEVuYWJsZWQSJwoPc3RhcnR1cF9zZXJ2aWNlGAsgASgJUg5z'
    'dGFydHVwU2VydmljZRIfCgtkdW1wX2V4aXN0cxgMIAEoCFIKZHVtcEV4aXN0cxIsChJkdW1wX3'
    'Byb2Nlc3NfY291bnQYDSABKAVSEGR1bXBQcm9jZXNzQ291bnQSLAoSbW9kdWxlX2NvbmZpZ19q'
    'c29uGA4gASgJUhBtb2R1bGVDb25maWdKc29uEiMKDW5wbV9hdmFpbGFibGUYDyABKAhSDG5wbU'
    'F2YWlsYWJsZRIiCg1hZ2VudF9pc19yb290GBAgASgIUgthZ2VudElzUm9vdBIUCgVlcnJvchgR'
    'IAEoCVIFZXJyb3I=');

@$core.Deprecated('Use pm2ProcessListDescriptor instead')
const Pm2ProcessList$json = {
  '1': 'Pm2ProcessList',
  '2': [
    {
      '1': 'processes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.Pm2Process',
      '10': 'processes'
    },
  ],
};

/// Descriptor for `Pm2ProcessList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2ProcessListDescriptor = $convert.base64Decode(
    'Cg5QbTJQcm9jZXNzTGlzdBIzCglwcm9jZXNzZXMYASADKAsyFS5waWNvbnRyb2wuUG0yUHJvY2'
    'Vzc1IJcHJvY2Vzc2Vz');

@$core.Deprecated('Use pm2ProcessDescriptor instead')
const Pm2Process$json = {
  '1': 'Pm2Process',
  '2': [
    {'1': 'pm_id', '3': 1, '4': 1, '5': 5, '10': 'pmId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'namespace', '3': 3, '4': 1, '5': 9, '10': 'namespace'},
    {'1': 'pid', '3': 4, '4': 1, '5': 5, '10': 'pid'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'cpu', '3': 6, '4': 1, '5': 1, '10': 'cpu'},
    {'1': 'memory', '3': 7, '4': 1, '5': 4, '10': 'memory'},
    {'1': 'started_at', '3': 8, '4': 1, '5': 3, '10': 'startedAt'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'restarts', '3': 10, '4': 1, '5': 5, '10': 'restarts'},
    {
      '1': 'unstable_restarts',
      '3': 11,
      '4': 1,
      '5': 5,
      '10': 'unstableRestarts'
    },
    {'1': 'exec_mode', '3': 12, '4': 1, '5': 9, '10': 'execMode'},
    {'1': 'instances', '3': 13, '4': 1, '5': 5, '10': 'instances'},
    {'1': 'watch', '3': 14, '4': 1, '5': 8, '10': 'watch'},
    {'1': 'autorestart', '3': 15, '4': 1, '5': 8, '10': 'autorestart'},
    {'1': 'version', '3': 16, '4': 1, '5': 9, '10': 'version'},
    {'1': 'script', '3': 17, '4': 1, '5': 9, '10': 'script'},
    {'1': 'cwd', '3': 18, '4': 1, '5': 9, '10': 'cwd'},
    {'1': 'interpreter', '3': 19, '4': 1, '5': 9, '10': 'interpreter'},
    {'1': 'node_version', '3': 20, '4': 1, '5': 9, '10': 'nodeVersion'},
    {'1': 'is_module', '3': 21, '4': 1, '5': 8, '10': 'isModule'},
    {'1': 'user', '3': 22, '4': 1, '5': 9, '10': 'user'},
    {'1': 'out_log', '3': 23, '4': 1, '5': 9, '10': 'outLog'},
    {'1': 'err_log', '3': 24, '4': 1, '5': 9, '10': 'errLog'},
    {
      '1': 'max_memory_restart',
      '3': 25,
      '4': 1,
      '5': 3,
      '10': 'maxMemoryRestart'
    },
    {'1': 'cron_restart', '3': 26, '4': 1, '5': 9, '10': 'cronRestart'},
    {'1': 'args', '3': 27, '4': 3, '5': 9, '10': 'args'},
    {'1': 'custom_actions', '3': 28, '4': 3, '5': 9, '10': 'customActions'},
    {
      '1': 'metrics',
      '3': 29,
      '4': 3,
      '5': 11,
      '6': '.picontrol.Pm2Metric',
      '10': 'metrics'
    },
    {
      '1': 'versioning',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.picontrol.Pm2Versioning',
      '10': 'versioning'
    },
    {'1': 'exit_code', '3': 31, '4': 1, '5': 5, '10': 'exitCode'},
    {'1': 'interpreter_args', '3': 32, '4': 1, '5': 9, '10': 'interpreterArgs'},
  ],
};

/// Descriptor for `Pm2Process`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2ProcessDescriptor = $convert.base64Decode(
    'CgpQbTJQcm9jZXNzEhMKBXBtX2lkGAEgASgFUgRwbUlkEhIKBG5hbWUYAiABKAlSBG5hbWUSHA'
    'oJbmFtZXNwYWNlGAMgASgJUgluYW1lc3BhY2USEAoDcGlkGAQgASgFUgNwaWQSFgoGc3RhdHVz'
    'GAUgASgJUgZzdGF0dXMSEAoDY3B1GAYgASgBUgNjcHUSFgoGbWVtb3J5GAcgASgEUgZtZW1vcn'
    'kSHQoKc3RhcnRlZF9hdBgIIAEoA1IJc3RhcnRlZEF0Eh0KCmNyZWF0ZWRfYXQYCSABKANSCWNy'
    'ZWF0ZWRBdBIaCghyZXN0YXJ0cxgKIAEoBVIIcmVzdGFydHMSKwoRdW5zdGFibGVfcmVzdGFydH'
    'MYCyABKAVSEHVuc3RhYmxlUmVzdGFydHMSGwoJZXhlY19tb2RlGAwgASgJUghleGVjTW9kZRIc'
    'CglpbnN0YW5jZXMYDSABKAVSCWluc3RhbmNlcxIUCgV3YXRjaBgOIAEoCFIFd2F0Y2gSIAoLYX'
    'V0b3Jlc3RhcnQYDyABKAhSC2F1dG9yZXN0YXJ0EhgKB3ZlcnNpb24YECABKAlSB3ZlcnNpb24S'
    'FgoGc2NyaXB0GBEgASgJUgZzY3JpcHQSEAoDY3dkGBIgASgJUgNjd2QSIAoLaW50ZXJwcmV0ZX'
    'IYEyABKAlSC2ludGVycHJldGVyEiEKDG5vZGVfdmVyc2lvbhgUIAEoCVILbm9kZVZlcnNpb24S'
    'GwoJaXNfbW9kdWxlGBUgASgIUghpc01vZHVsZRISCgR1c2VyGBYgASgJUgR1c2VyEhcKB291dF'
    '9sb2cYFyABKAlSBm91dExvZxIXCgdlcnJfbG9nGBggASgJUgZlcnJMb2cSLAoSbWF4X21lbW9y'
    'eV9yZXN0YXJ0GBkgASgDUhBtYXhNZW1vcnlSZXN0YXJ0EiEKDGNyb25fcmVzdGFydBgaIAEoCV'
    'ILY3JvblJlc3RhcnQSEgoEYXJncxgbIAMoCVIEYXJncxIlCg5jdXN0b21fYWN0aW9ucxgcIAMo'
    'CVINY3VzdG9tQWN0aW9ucxIuCgdtZXRyaWNzGB0gAygLMhQucGljb250cm9sLlBtMk1ldHJpY1'
    'IHbWV0cmljcxI4Cgp2ZXJzaW9uaW5nGB4gASgLMhgucGljb250cm9sLlBtMlZlcnNpb25pbmdS'
    'CnZlcnNpb25pbmcSGwoJZXhpdF9jb2RlGB8gASgFUghleGl0Q29kZRIpChBpbnRlcnByZXRlcl'
    '9hcmdzGCAgASgJUg9pbnRlcnByZXRlckFyZ3M=');

@$core.Deprecated('Use pm2MetricDescriptor instead')
const Pm2Metric$json = {
  '1': 'Pm2Metric',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `Pm2Metric`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2MetricDescriptor = $convert.base64Decode(
    'CglQbTJNZXRyaWMSEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWUSEg'
    'oEdW5pdBgDIAEoCVIEdW5pdA==');

@$core.Deprecated('Use pm2VersioningDescriptor instead')
const Pm2Versioning$json = {
  '1': 'Pm2Versioning',
  '2': [
    {'1': 'present', '3': 1, '4': 1, '5': 8, '10': 'present'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'branch', '3': 4, '4': 1, '5': 9, '10': 'branch'},
    {'1': 'revision', '3': 5, '4': 1, '5': 9, '10': 'revision'},
    {'1': 'comment', '3': 6, '4': 1, '5': 9, '10': 'comment'},
    {'1': 'unstaged', '3': 7, '4': 1, '5': 8, '10': 'unstaged'},
    {'1': 'update_time', '3': 8, '4': 1, '5': 3, '10': 'updateTime'},
    {'1': 'repo_path', '3': 9, '4': 1, '5': 9, '10': 'repoPath'},
  ],
};

/// Descriptor for `Pm2Versioning`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2VersioningDescriptor = $convert.base64Decode(
    'Cg1QbTJWZXJzaW9uaW5nEhgKB3ByZXNlbnQYASABKAhSB3ByZXNlbnQSEgoEdHlwZRgCIAEoCV'
    'IEdHlwZRIQCgN1cmwYAyABKAlSA3VybBIWCgZicmFuY2gYBCABKAlSBmJyYW5jaBIaCghyZXZp'
    'c2lvbhgFIAEoCVIIcmV2aXNpb24SGAoHY29tbWVudBgGIAEoCVIHY29tbWVudBIaCgh1bnN0YW'
    'dlZBgHIAEoCFIIdW5zdGFnZWQSHwoLdXBkYXRlX3RpbWUYCCABKANSCnVwZGF0ZVRpbWUSGwoJ'
    'cmVwb19wYXRoGAkgASgJUghyZXBvUGF0aA==');

@$core.Deprecated('Use pm2TargetDescriptor instead')
const Pm2Target$json = {
  '1': 'Pm2Target',
  '2': [
    {'1': 'target', '3': 1, '4': 1, '5': 9, '10': 'target'},
  ],
};

/// Descriptor for `Pm2Target`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2TargetDescriptor =
    $convert.base64Decode('CglQbTJUYXJnZXQSFgoGdGFyZ2V0GAEgASgJUgZ0YXJnZXQ=');

@$core.Deprecated('Use pm2ProcessDetailsDescriptor instead')
const Pm2ProcessDetails$json = {
  '1': 'Pm2ProcessDetails',
  '2': [
    {
      '1': 'process',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.picontrol.Pm2Process',
      '10': 'process'
    },
    {
      '1': 'env',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.picontrol.Pm2ProcessDetails.EnvEntry',
      '10': 'env'
    },
    {'1': 'raw_json', '3': 3, '4': 1, '5': 9, '10': 'rawJson'},
  ],
  '3': [Pm2ProcessDetails_EnvEntry$json],
};

@$core.Deprecated('Use pm2ProcessDetailsDescriptor instead')
const Pm2ProcessDetails_EnvEntry$json = {
  '1': 'EnvEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Pm2ProcessDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2ProcessDetailsDescriptor = $convert.base64Decode(
    'ChFQbTJQcm9jZXNzRGV0YWlscxIvCgdwcm9jZXNzGAEgASgLMhUucGljb250cm9sLlBtMlByb2'
    'Nlc3NSB3Byb2Nlc3MSNwoDZW52GAIgAygLMiUucGljb250cm9sLlBtMlByb2Nlc3NEZXRhaWxz'
    'LkVudkVudHJ5UgNlbnYSGQoIcmF3X2pzb24YAyABKAlSB3Jhd0pzb24aNgoIRW52RW50cnkSEA'
    'oDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use pm2StartRequestDescriptor instead')
const Pm2StartRequest$json = {
  '1': 'Pm2StartRequest',
  '2': [
    {
      '1': 'mode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.picontrol.Pm2StartMode',
      '10': 'mode'
    },
    {'1': 'script', '3': 2, '4': 1, '5': 9, '10': 'script'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'cwd', '3': 4, '4': 1, '5': 9, '10': 'cwd'},
    {'1': 'args', '3': 5, '4': 3, '5': 9, '10': 'args'},
    {'1': 'interpreter', '3': 6, '4': 1, '5': 9, '10': 'interpreter'},
    {'1': 'interpreter_args', '3': 7, '4': 1, '5': 9, '10': 'interpreterArgs'},
    {'1': 'namespace', '3': 8, '4': 1, '5': 9, '10': 'namespace'},
    {
      '1': 'env',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.picontrol.Pm2StartRequest.EnvEntry',
      '10': 'env'
    },
    {'1': 'instances', '3': 10, '4': 1, '5': 9, '10': 'instances'},
    {'1': 'watch', '3': 11, '4': 1, '5': 8, '10': 'watch'},
    {'1': 'ignore_watch', '3': 12, '4': 1, '5': 9, '10': 'ignoreWatch'},
    {'1': 'watch_delay', '3': 13, '4': 1, '5': 9, '10': 'watchDelay'},
    {
      '1': 'max_memory_restart',
      '3': 14,
      '4': 1,
      '5': 9,
      '10': 'maxMemoryRestart'
    },
    {'1': 'cron_restart', '3': 15, '4': 1, '5': 9, '10': 'cronRestart'},
    {'1': 'no_autorestart', '3': 16, '4': 1, '5': 8, '10': 'noAutorestart'},
    {'1': 'restart_delay', '3': 17, '4': 1, '5': 5, '10': 'restartDelay'},
    {
      '1': 'exp_backoff_restart_delay',
      '3': 18,
      '4': 1,
      '5': 5,
      '10': 'expBackoffRestartDelay'
    },
    {'1': 'max_restarts', '3': 19, '4': 1, '5': 5, '10': 'maxRestarts'},
    {'1': 'stop_exit_codes', '3': 20, '4': 1, '5': 9, '10': 'stopExitCodes'},
    {'1': 'time', '3': 21, '4': 1, '5': 8, '10': 'time'},
    {'1': 'log_date_format', '3': 22, '4': 1, '5': 9, '10': 'logDateFormat'},
    {'1': 'merge_logs', '3': 23, '4': 1, '5': 8, '10': 'mergeLogs'},
    {'1': 'output_log', '3': 24, '4': 1, '5': 9, '10': 'outputLog'},
    {'1': 'error_log', '3': 25, '4': 1, '5': 9, '10': 'errorLog'},
    {'1': 'combined_log', '3': 26, '4': 1, '5': 9, '10': 'combinedLog'},
    {'1': 'disable_logs', '3': 27, '4': 1, '5': 8, '10': 'disableLogs'},
    {'1': 'kill_timeout', '3': 28, '4': 1, '5': 5, '10': 'killTimeout'},
    {'1': 'listen_timeout', '3': 29, '4': 1, '5': 5, '10': 'listenTimeout'},
    {'1': 'wait_ready', '3': 30, '4': 1, '5': 8, '10': 'waitReady'},
    {
      '1': 'shutdown_with_message',
      '3': 31,
      '4': 1,
      '5': 8,
      '10': 'shutdownWithMessage'
    },
    {'1': 'no_treekill', '3': 32, '4': 1, '5': 8, '10': 'noTreekill'},
    {'1': 'no_autostart', '3': 33, '4': 1, '5': 8, '10': 'noAutostart'},
    {'1': 'no_vizion', '3': 34, '4': 1, '5': 8, '10': 'noVizion'},
    {'1': 'force', '3': 35, '4': 1, '5': 8, '10': 'force'},
    {'1': 'config_file', '3': 36, '4': 1, '5': 9, '10': 'configFile'},
    {'1': 'env_name', '3': 37, '4': 1, '5': 9, '10': 'envName'},
    {'1': 'only', '3': 38, '4': 1, '5': 9, '10': 'only'},
    {'1': 'update_env', '3': 39, '4': 1, '5': 8, '10': 'updateEnv'},
    {'1': 'serve_path', '3': 40, '4': 1, '5': 9, '10': 'servePath'},
    {'1': 'serve_port', '3': 41, '4': 1, '5': 5, '10': 'servePort'},
    {'1': 'spa', '3': 42, '4': 1, '5': 8, '10': 'spa'},
    {
      '1': 'basic_auth_username',
      '3': 43,
      '4': 1,
      '5': 9,
      '10': 'basicAuthUsername'
    },
    {
      '1': 'basic_auth_password',
      '3': 44,
      '4': 1,
      '5': 9,
      '10': 'basicAuthPassword'
    },
  ],
  '3': [Pm2StartRequest_EnvEntry$json],
};

@$core.Deprecated('Use pm2StartRequestDescriptor instead')
const Pm2StartRequest_EnvEntry$json = {
  '1': 'EnvEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Pm2StartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2StartRequestDescriptor = $convert.base64Decode(
    'Cg9QbTJTdGFydFJlcXVlc3QSKwoEbW9kZRgBIAEoDjIXLnBpY29udHJvbC5QbTJTdGFydE1vZG'
    'VSBG1vZGUSFgoGc2NyaXB0GAIgASgJUgZzY3JpcHQSEgoEbmFtZRgDIAEoCVIEbmFtZRIQCgNj'
    'd2QYBCABKAlSA2N3ZBISCgRhcmdzGAUgAygJUgRhcmdzEiAKC2ludGVycHJldGVyGAYgASgJUg'
    'tpbnRlcnByZXRlchIpChBpbnRlcnByZXRlcl9hcmdzGAcgASgJUg9pbnRlcnByZXRlckFyZ3MS'
    'HAoJbmFtZXNwYWNlGAggASgJUgluYW1lc3BhY2USNQoDZW52GAkgAygLMiMucGljb250cm9sLl'
    'BtMlN0YXJ0UmVxdWVzdC5FbnZFbnRyeVIDZW52EhwKCWluc3RhbmNlcxgKIAEoCVIJaW5zdGFu'
    'Y2VzEhQKBXdhdGNoGAsgASgIUgV3YXRjaBIhCgxpZ25vcmVfd2F0Y2gYDCABKAlSC2lnbm9yZV'
    'dhdGNoEh8KC3dhdGNoX2RlbGF5GA0gASgJUgp3YXRjaERlbGF5EiwKEm1heF9tZW1vcnlfcmVz'
    'dGFydBgOIAEoCVIQbWF4TWVtb3J5UmVzdGFydBIhCgxjcm9uX3Jlc3RhcnQYDyABKAlSC2Nyb2'
    '5SZXN0YXJ0EiUKDm5vX2F1dG9yZXN0YXJ0GBAgASgIUg1ub0F1dG9yZXN0YXJ0EiMKDXJlc3Rh'
    'cnRfZGVsYXkYESABKAVSDHJlc3RhcnREZWxheRI5ChlleHBfYmFja29mZl9yZXN0YXJ0X2RlbG'
    'F5GBIgASgFUhZleHBCYWNrb2ZmUmVzdGFydERlbGF5EiEKDG1heF9yZXN0YXJ0cxgTIAEoBVIL'
    'bWF4UmVzdGFydHMSJgoPc3RvcF9leGl0X2NvZGVzGBQgASgJUg1zdG9wRXhpdENvZGVzEhIKBH'
    'RpbWUYFSABKAhSBHRpbWUSJgoPbG9nX2RhdGVfZm9ybWF0GBYgASgJUg1sb2dEYXRlRm9ybWF0'
    'Eh0KCm1lcmdlX2xvZ3MYFyABKAhSCW1lcmdlTG9ncxIdCgpvdXRwdXRfbG9nGBggASgJUglvdX'
    'RwdXRMb2cSGwoJZXJyb3JfbG9nGBkgASgJUghlcnJvckxvZxIhCgxjb21iaW5lZF9sb2cYGiAB'
    'KAlSC2NvbWJpbmVkTG9nEiEKDGRpc2FibGVfbG9ncxgbIAEoCFILZGlzYWJsZUxvZ3MSIQoMa2'
    'lsbF90aW1lb3V0GBwgASgFUgtraWxsVGltZW91dBIlCg5saXN0ZW5fdGltZW91dBgdIAEoBVIN'
    'bGlzdGVuVGltZW91dBIdCgp3YWl0X3JlYWR5GB4gASgIUgl3YWl0UmVhZHkSMgoVc2h1dGRvd2'
    '5fd2l0aF9tZXNzYWdlGB8gASgIUhNzaHV0ZG93bldpdGhNZXNzYWdlEh8KC25vX3RyZWVraWxs'
    'GCAgASgIUgpub1RyZWVraWxsEiEKDG5vX2F1dG9zdGFydBghIAEoCFILbm9BdXRvc3RhcnQSGw'
    'oJbm9fdml6aW9uGCIgASgIUghub1ZpemlvbhIUCgVmb3JjZRgjIAEoCFIFZm9yY2USHwoLY29u'
    'ZmlnX2ZpbGUYJCABKAlSCmNvbmZpZ0ZpbGUSGQoIZW52X25hbWUYJSABKAlSB2Vudk5hbWUSEg'
    'oEb25seRgmIAEoCVIEb25seRIdCgp1cGRhdGVfZW52GCcgASgIUgl1cGRhdGVFbnYSHQoKc2Vy'
    'dmVfcGF0aBgoIAEoCVIJc2VydmVQYXRoEh0KCnNlcnZlX3BvcnQYKSABKAVSCXNlcnZlUG9ydB'
    'IQCgNzcGEYKiABKAhSA3NwYRIuChNiYXNpY19hdXRoX3VzZXJuYW1lGCsgASgJUhFiYXNpY0F1'
    'dGhVc2VybmFtZRIuChNiYXNpY19hdXRoX3Bhc3N3b3JkGCwgASgJUhFiYXNpY0F1dGhQYXNzd2'
    '9yZBo2CghFbnZFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6'
    'AjgB');

@$core.Deprecated('Use pm2ControlRequestDescriptor instead')
const Pm2ControlRequest$json = {
  '1': 'Pm2ControlRequest',
  '2': [
    {
      '1': 'action',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.picontrol.Pm2Action',
      '10': 'action'
    },
    {'1': 'target', '3': 2, '4': 1, '5': 9, '10': 'target'},
    {'1': 'update_env', '3': 3, '4': 1, '5': 8, '10': 'updateEnv'},
    {'1': 'env_name', '3': 4, '4': 1, '5': 9, '10': 'envName'},
    {'1': 'only', '3': 5, '4': 1, '5': 9, '10': 'only'},
    {'1': 'value', '3': 6, '4': 1, '5': 9, '10': 'value'},
    {'1': 'action_name', '3': 7, '4': 1, '5': 9, '10': 'actionName'},
    {'1': 'action_param', '3': 8, '4': 1, '5': 9, '10': 'actionParam'},
  ],
};

/// Descriptor for `Pm2ControlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2ControlRequestDescriptor = $convert.base64Decode(
    'ChFQbTJDb250cm9sUmVxdWVzdBIsCgZhY3Rpb24YASABKA4yFC5waWNvbnRyb2wuUG0yQWN0aW'
    '9uUgZhY3Rpb24SFgoGdGFyZ2V0GAIgASgJUgZ0YXJnZXQSHQoKdXBkYXRlX2VudhgDIAEoCFIJ'
    'dXBkYXRlRW52EhkKCGVudl9uYW1lGAQgASgJUgdlbnZOYW1lEhIKBG9ubHkYBSABKAlSBG9ubH'
    'kSFAoFdmFsdWUYBiABKAlSBXZhbHVlEh8KC2FjdGlvbl9uYW1lGAcgASgJUgphY3Rpb25OYW1l'
    'EiEKDGFjdGlvbl9wYXJhbRgIIAEoCVILYWN0aW9uUGFyYW0=');

@$core.Deprecated('Use pm2CommandResultDescriptor instead')
const Pm2CommandResult$json = {
  '1': 'Pm2CommandResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'output', '3': 2, '4': 1, '5': 9, '10': 'output'},
    {'1': 'command', '3': 3, '4': 1, '5': 9, '10': 'command'},
    {'1': 'exit_code', '3': 4, '4': 1, '5': 5, '10': 'exitCode'},
  ],
};

/// Descriptor for `Pm2CommandResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2CommandResultDescriptor = $convert.base64Decode(
    'ChBQbTJDb21tYW5kUmVzdWx0EhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFgoGb3V0cHV0GA'
    'IgASgJUgZvdXRwdXQSGAoHY29tbWFuZBgDIAEoCVIHY29tbWFuZBIbCglleGl0X2NvZGUYBCAB'
    'KAVSCGV4aXRDb2Rl');

@$core.Deprecated('Use pm2LogRequestDescriptor instead')
const Pm2LogRequest$json = {
  '1': 'Pm2LogRequest',
  '2': [
    {'1': 'target', '3': 1, '4': 1, '5': 9, '10': 'target'},
    {'1': 'lines', '3': 2, '4': 1, '5': 5, '10': 'lines'},
    {'1': 'follow', '3': 3, '4': 1, '5': 8, '10': 'follow'},
    {'1': 'include_out', '3': 4, '4': 1, '5': 8, '10': 'includeOut'},
    {'1': 'include_err', '3': 5, '4': 1, '5': 8, '10': 'includeErr'},
    {'1': 'include_daemon', '3': 6, '4': 1, '5': 8, '10': 'includeDaemon'},
  ],
};

/// Descriptor for `Pm2LogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2LogRequestDescriptor = $convert.base64Decode(
    'Cg1QbTJMb2dSZXF1ZXN0EhYKBnRhcmdldBgBIAEoCVIGdGFyZ2V0EhQKBWxpbmVzGAIgASgFUg'
    'VsaW5lcxIWCgZmb2xsb3cYAyABKAhSBmZvbGxvdxIfCgtpbmNsdWRlX291dBgEIAEoCFIKaW5j'
    'bHVkZU91dBIfCgtpbmNsdWRlX2VychgFIAEoCFIKaW5jbHVkZUVychIlCg5pbmNsdWRlX2RhZW'
    '1vbhgGIAEoCFINaW5jbHVkZURhZW1vbg==');

@$core.Deprecated('Use pm2LogLineDescriptor instead')
const Pm2LogLine$json = {
  '1': 'Pm2LogLine',
  '2': [
    {'1': 'app_name', '3': 1, '4': 1, '5': 9, '10': 'appName'},
    {'1': 'pm_id', '3': 2, '4': 1, '5': 5, '10': 'pmId'},
    {'1': 'stream', '3': 3, '4': 1, '5': 9, '10': 'stream'},
    {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    {'1': 'received_at', '3': 5, '4': 1, '5': 3, '10': 'receivedAt'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {
      '1': 'timestamp_from_log',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'timestampFromLog'
    },
    {'1': 'history', '3': 8, '4': 1, '5': 8, '10': 'history'},
    {'1': 'message', '3': 9, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `Pm2LogLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2LogLineDescriptor = $convert.base64Decode(
    'CgpQbTJMb2dMaW5lEhkKCGFwcF9uYW1lGAEgASgJUgdhcHBOYW1lEhMKBXBtX2lkGAIgASgFUg'
    'RwbUlkEhYKBnN0cmVhbRgDIAEoCVIGc3RyZWFtEhIKBHRleHQYBCABKAlSBHRleHQSHwoLcmVj'
    'ZWl2ZWRfYXQYBSABKANSCnJlY2VpdmVkQXQSHAoJdGltZXN0YW1wGAYgASgDUgl0aW1lc3RhbX'
    'ASLAoSdGltZXN0YW1wX2Zyb21fbG9nGAcgASgIUhB0aW1lc3RhbXBGcm9tTG9nEhgKB2hpc3Rv'
    'cnkYCCABKAhSB2hpc3RvcnkSGAoHbWVzc2FnZRgJIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use pm2OperationRequestDescriptor instead')
const Pm2OperationRequest$json = {
  '1': 'Pm2OperationRequest',
  '2': [
    {
      '1': 'operation',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.picontrol.Pm2Operation',
      '10': 'operation'
    },
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 3, '4': 1, '5': 9, '10': 'value'},
    {'1': 'config_file', '3': 4, '4': 1, '5': 9, '10': 'configFile'},
    {'1': 'deploy_env', '3': 5, '4': 1, '5': 9, '10': 'deployEnv'},
    {'1': 'deploy_command', '3': 6, '4': 1, '5': 9, '10': 'deployCommand'},
    {'1': 'deploy_args', '3': 7, '4': 1, '5': 9, '10': 'deployArgs'},
    {'1': 'cwd', '3': 8, '4': 1, '5': 9, '10': 'cwd'},
    {'1': 'force', '3': 9, '4': 1, '5': 8, '10': 'force'},
    {'1': 'mode', '3': 10, '4': 1, '5': 9, '10': 'mode'},
  ],
};

/// Descriptor for `Pm2OperationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2OperationRequestDescriptor = $convert.base64Decode(
    'ChNQbTJPcGVyYXRpb25SZXF1ZXN0EjUKCW9wZXJhdGlvbhgBIAEoDjIXLnBpY29udHJvbC5QbT'
    'JPcGVyYXRpb25SCW9wZXJhdGlvbhISCgRuYW1lGAIgASgJUgRuYW1lEhQKBXZhbHVlGAMgASgJ'
    'UgV2YWx1ZRIfCgtjb25maWdfZmlsZRgEIAEoCVIKY29uZmlnRmlsZRIdCgpkZXBsb3lfZW52GA'
    'UgASgJUglkZXBsb3lFbnYSJQoOZGVwbG95X2NvbW1hbmQYBiABKAlSDWRlcGxveUNvbW1hbmQS'
    'HwoLZGVwbG95X2FyZ3MYByABKAlSCmRlcGxveUFyZ3MSEAoDY3dkGAggASgJUgNjd2QSFAoFZm'
    '9yY2UYCSABKAhSBWZvcmNlEhIKBG1vZGUYCiABKAlSBG1vZGU=');

@$core.Deprecated('Use pm2OutputLineDescriptor instead')
const Pm2OutputLine$json = {
  '1': 'Pm2OutputLine',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'is_error', '3': 2, '4': 1, '5': 8, '10': 'isError'},
    {'1': 'done', '3': 3, '4': 1, '5': 8, '10': 'done'},
    {'1': 'success', '3': 4, '4': 1, '5': 8, '10': 'success'},
    {'1': 'exit_code', '3': 5, '4': 1, '5': 5, '10': 'exitCode'},
  ],
};

/// Descriptor for `Pm2OutputLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pm2OutputLineDescriptor = $convert.base64Decode(
    'Cg1QbTJPdXRwdXRMaW5lEhIKBHRleHQYASABKAlSBHRleHQSGQoIaXNfZXJyb3IYAiABKAhSB2'
    'lzRXJyb3ISEgoEZG9uZRgDIAEoCFIEZG9uZRIYCgdzdWNjZXNzGAQgASgIUgdzdWNjZXNzEhsK'
    'CWV4aXRfY29kZRgFIAEoBVIIZXhpdENvZGU=');

@$core.Deprecated('Use commandOutputDescriptor instead')
const CommandOutput$json = {
  '1': 'CommandOutput',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'output', '3': 2, '4': 1, '5': 9, '10': 'output'},
    {'1': 'exit_code', '3': 3, '4': 1, '5': 5, '10': 'exitCode'},
    {'1': 'command', '3': 4, '4': 1, '5': 9, '10': 'command'},
  ],
};

/// Descriptor for `CommandOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandOutputDescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kT3V0cHV0EhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFgoGb3V0cHV0GAIgAS'
    'gJUgZvdXRwdXQSGwoJZXhpdF9jb2RlGAMgASgFUghleGl0Q29kZRIYCgdjb21tYW5kGAQgASgJ'
    'Ugdjb21tYW5k');

@$core.Deprecated('Use crontabRequestDescriptor instead')
const CrontabRequest$json = {
  '1': 'CrontabRequest',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 9, '10': 'user'},
  ],
};

/// Descriptor for `CrontabRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List crontabRequestDescriptor =
    $convert.base64Decode('Cg5Dcm9udGFiUmVxdWVzdBISCgR1c2VyGAEgASgJUgR1c2Vy');

@$core.Deprecated('Use crontabDescriptor instead')
const Crontab$json = {
  '1': 'Crontab',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 9, '10': 'user'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'exists', '3': 3, '4': 1, '5': 8, '10': 'exists'},
    {
      '1': 'system_files',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.picontrol.CronFile',
      '10': 'systemFiles'
    },
    {
      '1': 'users_with_crontab',
      '3': 5,
      '4': 3,
      '5': 9,
      '10': 'usersWithCrontab'
    },
  ],
};

/// Descriptor for `Crontab`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List crontabDescriptor = $convert.base64Decode(
    'CgdDcm9udGFiEhIKBHVzZXIYASABKAlSBHVzZXISGAoHY29udGVudBgCIAEoCVIHY29udGVudB'
    'IWCgZleGlzdHMYAyABKAhSBmV4aXN0cxI2CgxzeXN0ZW1fZmlsZXMYBCADKAsyEy5waWNvbnRy'
    'b2wuQ3JvbkZpbGVSC3N5c3RlbUZpbGVzEiwKEnVzZXJzX3dpdGhfY3JvbnRhYhgFIAMoCVIQdX'
    'NlcnNXaXRoQ3JvbnRhYg==');

@$core.Deprecated('Use cronFileDescriptor instead')
const CronFile$json = {
  '1': 'CronFile',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
  ],
};

/// Descriptor for `CronFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cronFileDescriptor = $convert.base64Decode(
    'CghDcm9uRmlsZRISCgRwYXRoGAEgASgJUgRwYXRoEhgKB2NvbnRlbnQYAiABKAlSB2NvbnRlbn'
    'Q=');

@$core.Deprecated('Use runAsUserRequestDescriptor instead')
const RunAsUserRequest$json = {
  '1': 'RunAsUserRequest',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 9, '10': 'user'},
    {'1': 'command', '3': 2, '4': 1, '5': 9, '10': 'command'},
    {'1': 'timeout_seconds', '3': 3, '4': 1, '5': 5, '10': 'timeoutSeconds'},
  ],
};

/// Descriptor for `RunAsUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runAsUserRequestDescriptor = $convert.base64Decode(
    'ChBSdW5Bc1VzZXJSZXF1ZXN0EhIKBHVzZXIYASABKAlSBHVzZXISGAoHY29tbWFuZBgCIAEoCV'
    'IHY29tbWFuZBInCg90aW1lb3V0X3NlY29uZHMYAyABKAVSDnRpbWVvdXRTZWNvbmRz');

@$core.Deprecated('Use firewallStatusDescriptor instead')
const FirewallStatus$json = {
  '1': 'FirewallStatus',
  '2': [
    {'1': 'installed', '3': 1, '4': 1, '5': 8, '10': 'installed'},
    {'1': 'active', '3': 2, '4': 1, '5': 8, '10': 'active'},
    {'1': 'default_incoming', '3': 3, '4': 1, '5': 9, '10': 'defaultIncoming'},
    {'1': 'default_outgoing', '3': 4, '4': 1, '5': 9, '10': 'defaultOutgoing'},
    {'1': 'default_routed', '3': 5, '4': 1, '5': 9, '10': 'defaultRouted'},
    {'1': 'logging', '3': 6, '4': 1, '5': 9, '10': 'logging'},
    {
      '1': 'rules',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.picontrol.FirewallRule',
      '10': 'rules'
    },
    {'1': 'raw', '3': 8, '4': 1, '5': 9, '10': 'raw'},
    {'1': 'ssh_port', '3': 9, '4': 1, '5': 5, '10': 'sshPort'},
    {'1': 'app_profiles', '3': 10, '4': 3, '5': 9, '10': 'appProfiles'},
  ],
};

/// Descriptor for `FirewallStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List firewallStatusDescriptor = $convert.base64Decode(
    'Cg5GaXJld2FsbFN0YXR1cxIcCglpbnN0YWxsZWQYASABKAhSCWluc3RhbGxlZBIWCgZhY3Rpdm'
    'UYAiABKAhSBmFjdGl2ZRIpChBkZWZhdWx0X2luY29taW5nGAMgASgJUg9kZWZhdWx0SW5jb21p'
    'bmcSKQoQZGVmYXVsdF9vdXRnb2luZxgEIAEoCVIPZGVmYXVsdE91dGdvaW5nEiUKDmRlZmF1bH'
    'Rfcm91dGVkGAUgASgJUg1kZWZhdWx0Um91dGVkEhgKB2xvZ2dpbmcYBiABKAlSB2xvZ2dpbmcS'
    'LQoFcnVsZXMYByADKAsyFy5waWNvbnRyb2wuRmlyZXdhbGxSdWxlUgVydWxlcxIQCgNyYXcYCC'
    'ABKAlSA3JhdxIZCghzc2hfcG9ydBgJIAEoBVIHc3NoUG9ydBIhCgxhcHBfcHJvZmlsZXMYCiAD'
    'KAlSC2FwcFByb2ZpbGVz');

@$core.Deprecated('Use firewallRuleDescriptor instead')
const FirewallRule$json = {
  '1': 'FirewallRule',
  '2': [
    {'1': 'number', '3': 1, '4': 1, '5': 5, '10': 'number'},
    {'1': 'to', '3': 2, '4': 1, '5': 9, '10': 'to'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
    {'1': 'from', '3': 4, '4': 1, '5': 9, '10': 'from'},
    {'1': 'v6', '3': 5, '4': 1, '5': 8, '10': 'v6'},
    {'1': 'comment', '3': 6, '4': 1, '5': 9, '10': 'comment'},
    {'1': 'spec', '3': 7, '4': 1, '5': 9, '10': 'spec'},
  ],
};

/// Descriptor for `FirewallRule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List firewallRuleDescriptor = $convert.base64Decode(
    'CgxGaXJld2FsbFJ1bGUSFgoGbnVtYmVyGAEgASgFUgZudW1iZXISDgoCdG8YAiABKAlSAnRvEh'
    'YKBmFjdGlvbhgDIAEoCVIGYWN0aW9uEhIKBGZyb20YBCABKAlSBGZyb20SDgoCdjYYBSABKAhS'
    'AnY2EhgKB2NvbW1lbnQYBiABKAlSB2NvbW1lbnQSEgoEc3BlYxgHIAEoCVIEc3BlYw==');

@$core.Deprecated('Use firewallRequestDescriptor instead')
const FirewallRequest$json = {
  '1': 'FirewallRequest',
  '2': [
    {
      '1': 'op',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.picontrol.FirewallOp',
      '10': 'op'
    },
    {'1': 'rule_action', '3': 2, '4': 1, '5': 9, '10': 'ruleAction'},
    {'1': 'direction', '3': 3, '4': 1, '5': 9, '10': 'direction'},
    {'1': 'port', '3': 4, '4': 1, '5': 9, '10': 'port'},
    {'1': 'protocol', '3': 5, '4': 1, '5': 9, '10': 'protocol'},
    {'1': 'from', '3': 6, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 7, '4': 1, '5': 9, '10': 'to'},
    {'1': 'comment', '3': 8, '4': 1, '5': 9, '10': 'comment'},
    {'1': 'number', '3': 9, '4': 1, '5': 5, '10': 'number'},
    {'1': 'policy', '3': 10, '4': 1, '5': 9, '10': 'policy'},
    {'1': 'chain', '3': 11, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'logging', '3': 12, '4': 1, '5': 9, '10': 'logging'},
    {'1': 'interface', '3': 13, '4': 1, '5': 9, '10': 'interface'},
    {'1': 'rule_spec', '3': 14, '4': 1, '5': 9, '10': 'ruleSpec'},
  ],
};

/// Descriptor for `FirewallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List firewallRequestDescriptor = $convert.base64Decode(
    'Cg9GaXJld2FsbFJlcXVlc3QSJQoCb3AYASABKA4yFS5waWNvbnRyb2wuRmlyZXdhbGxPcFICb3'
    'ASHwoLcnVsZV9hY3Rpb24YAiABKAlSCnJ1bGVBY3Rpb24SHAoJZGlyZWN0aW9uGAMgASgJUglk'
    'aXJlY3Rpb24SEgoEcG9ydBgEIAEoCVIEcG9ydBIaCghwcm90b2NvbBgFIAEoCVIIcHJvdG9jb2'
    'wSEgoEZnJvbRgGIAEoCVIEZnJvbRIOCgJ0bxgHIAEoCVICdG8SGAoHY29tbWVudBgIIAEoCVIH'
    'Y29tbWVudBIWCgZudW1iZXIYCSABKAVSBm51bWJlchIWCgZwb2xpY3kYCiABKAlSBnBvbGljeR'
    'IUCgVjaGFpbhgLIAEoCVIFY2hhaW4SGAoHbG9nZ2luZxgMIAEoCVIHbG9nZ2luZxIcCglpbnRl'
    'cmZhY2UYDSABKAlSCWludGVyZmFjZRIbCglydWxlX3NwZWMYDiABKAlSCHJ1bGVTcGVj');

@$core.Deprecated('Use userListDescriptor instead')
const UserList$json = {
  '1': 'UserList',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.SystemUser',
      '10': 'users'
    },
    {
      '1': 'groups',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.picontrol.SystemGroup',
      '10': 'groups'
    },
    {'1': 'agent_user', '3': 3, '4': 1, '5': 9, '10': 'agentUser'},
    {'1': 'shells', '3': 4, '4': 3, '5': 9, '10': 'shells'},
  ],
};

/// Descriptor for `UserList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userListDescriptor = $convert.base64Decode(
    'CghVc2VyTGlzdBIrCgV1c2VycxgBIAMoCzIVLnBpY29udHJvbC5TeXN0ZW1Vc2VyUgV1c2Vycx'
    'IuCgZncm91cHMYAiADKAsyFi5waWNvbnRyb2wuU3lzdGVtR3JvdXBSBmdyb3VwcxIdCgphZ2Vu'
    'dF91c2VyGAMgASgJUglhZ2VudFVzZXISFgoGc2hlbGxzGAQgAygJUgZzaGVsbHM=');

@$core.Deprecated('Use systemUserDescriptor instead')
const SystemUser$json = {
  '1': 'SystemUser',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'uid', '3': 2, '4': 1, '5': 5, '10': 'uid'},
    {'1': 'gid', '3': 3, '4': 1, '5': 5, '10': 'gid'},
    {'1': 'full_name', '3': 4, '4': 1, '5': 9, '10': 'fullName'},
    {'1': 'home', '3': 5, '4': 1, '5': 9, '10': 'home'},
    {'1': 'shell', '3': 6, '4': 1, '5': 9, '10': 'shell'},
    {'1': 'groups', '3': 7, '4': 3, '5': 9, '10': 'groups'},
    {'1': 'locked', '3': 8, '4': 1, '5': 8, '10': 'locked'},
    {'1': 'is_system', '3': 9, '4': 1, '5': 8, '10': 'isSystem'},
    {'1': 'can_sudo', '3': 10, '4': 1, '5': 8, '10': 'canSudo'},
    {'1': 'has_password', '3': 11, '4': 1, '5': 8, '10': 'hasPassword'},
  ],
};

/// Descriptor for `SystemUser`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemUserDescriptor = $convert.base64Decode(
    'CgpTeXN0ZW1Vc2VyEhIKBG5hbWUYASABKAlSBG5hbWUSEAoDdWlkGAIgASgFUgN1aWQSEAoDZ2'
    'lkGAMgASgFUgNnaWQSGwoJZnVsbF9uYW1lGAQgASgJUghmdWxsTmFtZRISCgRob21lGAUgASgJ'
    'UgRob21lEhQKBXNoZWxsGAYgASgJUgVzaGVsbBIWCgZncm91cHMYByADKAlSBmdyb3VwcxIWCg'
    'Zsb2NrZWQYCCABKAhSBmxvY2tlZBIbCglpc19zeXN0ZW0YCSABKAhSCGlzU3lzdGVtEhkKCGNh'
    'bl9zdWRvGAogASgIUgdjYW5TdWRvEiEKDGhhc19wYXNzd29yZBgLIAEoCFILaGFzUGFzc3dvcm'
    'Q=');

@$core.Deprecated('Use systemGroupDescriptor instead')
const SystemGroup$json = {
  '1': 'SystemGroup',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'gid', '3': 2, '4': 1, '5': 5, '10': 'gid'},
    {'1': 'members', '3': 3, '4': 3, '5': 9, '10': 'members'},
    {'1': 'is_system', '3': 4, '4': 1, '5': 8, '10': 'isSystem'},
  ],
};

/// Descriptor for `SystemGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemGroupDescriptor = $convert.base64Decode(
    'CgtTeXN0ZW1Hcm91cBISCgRuYW1lGAEgASgJUgRuYW1lEhAKA2dpZBgCIAEoBVIDZ2lkEhgKB2'
    '1lbWJlcnMYAyADKAlSB21lbWJlcnMSGwoJaXNfc3lzdGVtGAQgASgIUghpc1N5c3RlbQ==');

@$core.Deprecated('Use userRequestDescriptor instead')
const UserRequest$json = {
  '1': 'UserRequest',
  '2': [
    {'1': 'op', '3': 1, '4': 1, '5': 14, '6': '.picontrol.UserOp', '10': 'op'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
    {'1': 'group', '3': 4, '4': 1, '5': 9, '10': 'group'},
    {'1': 'shell', '3': 5, '4': 1, '5': 9, '10': 'shell'},
    {'1': 'full_name', '3': 6, '4': 1, '5': 9, '10': 'fullName'},
    {'1': 'remove_home', '3': 7, '4': 1, '5': 8, '10': 'removeHome'},
    {'1': 'sudo', '3': 8, '4': 1, '5': 8, '10': 'sudo'},
    {'1': 'groups', '3': 9, '4': 3, '5': 9, '10': 'groups'},
  ],
};

/// Descriptor for `UserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userRequestDescriptor = $convert.base64Decode(
    'CgtVc2VyUmVxdWVzdBIhCgJvcBgBIAEoDjIRLnBpY29udHJvbC5Vc2VyT3BSAm9wEhoKCHVzZX'
    'JuYW1lGAIgASgJUgh1c2VybmFtZRIaCghwYXNzd29yZBgDIAEoCVIIcGFzc3dvcmQSFAoFZ3Jv'
    'dXAYBCABKAlSBWdyb3VwEhQKBXNoZWxsGAUgASgJUgVzaGVsbBIbCglmdWxsX25hbWUYBiABKA'
    'lSCGZ1bGxOYW1lEh8KC3JlbW92ZV9ob21lGAcgASgIUgpyZW1vdmVIb21lEhIKBHN1ZG8YCCAB'
    'KAhSBHN1ZG8SFgoGZ3JvdXBzGAkgAygJUgZncm91cHM=');

@$core.Deprecated('Use hardwareInfoDescriptor instead')
const HardwareInfo$json = {
  '1': 'HardwareInfo',
  '2': [
    {'1': 'is_raspberry_pi', '3': 1, '4': 1, '5': 8, '10': 'isRaspberryPi'},
    {'1': 'model', '3': 2, '4': 1, '5': 9, '10': 'model'},
    {'1': 'serial', '3': 3, '4': 1, '5': 9, '10': 'serial'},
    {'1': 'revision', '3': 4, '4': 1, '5': 9, '10': 'revision'},
    {'1': 'soc', '3': 5, '4': 1, '5': 9, '10': 'soc'},
    {'1': 'architecture', '3': 6, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'cpu_cores', '3': 7, '4': 1, '5': 5, '10': 'cpuCores'},
    {'1': 'cpu_freq_mhz', '3': 8, '4': 3, '5': 3, '10': 'cpuFreqMhz'},
    {'1': 'cpu_min_mhz', '3': 9, '4': 1, '5': 3, '10': 'cpuMinMhz'},
    {'1': 'cpu_max_mhz', '3': 10, '4': 1, '5': 3, '10': 'cpuMaxMhz'},
    {'1': 'governor', '3': 11, '4': 1, '5': 9, '10': 'governor'},
    {'1': 'memory_total', '3': 12, '4': 1, '5': 4, '10': 'memoryTotal'},
    {'1': 'gpu_memory', '3': 13, '4': 1, '5': 9, '10': 'gpuMemory'},
    {'1': 'cpu_temp', '3': 14, '4': 1, '5': 1, '10': 'cpuTemp'},
    {
      '1': 'vcgencmd_available',
      '3': 15,
      '4': 1,
      '5': 8,
      '10': 'vcgencmdAvailable'
    },
    {'1': 'throttled_raw', '3': 16, '4': 1, '5': 9, '10': 'throttledRaw'},
    {'1': 'throttled_now', '3': 17, '4': 3, '5': 9, '10': 'throttledNow'},
    {'1': 'throttled_past', '3': 18, '4': 3, '5': 9, '10': 'throttledPast'},
    {
      '1': 'voltages',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.picontrol.HardwareInfo.VoltagesEntry',
      '10': 'voltages'
    },
    {
      '1': 'clocks',
      '3': 20,
      '4': 3,
      '5': 11,
      '6': '.picontrol.HardwareInfo.ClocksEntry',
      '10': 'clocks'
    },
    {'1': 'firmware', '3': 21, '4': 1, '5': 9, '10': 'firmware'},
    {'1': 'bootloader', '3': 22, '4': 1, '5': 9, '10': 'bootloader'},
    {'1': 'kernel', '3': 23, '4': 1, '5': 9, '10': 'kernel'},
    {'1': 'os', '3': 24, '4': 1, '5': 9, '10': 'os'},
    {'1': 'hostname', '3': 25, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'usb_devices', '3': 26, '4': 3, '5': 9, '10': 'usbDevices'},
  ],
  '3': [HardwareInfo_VoltagesEntry$json, HardwareInfo_ClocksEntry$json],
};

@$core.Deprecated('Use hardwareInfoDescriptor instead')
const HardwareInfo_VoltagesEntry$json = {
  '1': 'VoltagesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use hardwareInfoDescriptor instead')
const HardwareInfo_ClocksEntry$json = {
  '1': 'ClocksEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `HardwareInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hardwareInfoDescriptor = $convert.base64Decode(
    'CgxIYXJkd2FyZUluZm8SJgoPaXNfcmFzcGJlcnJ5X3BpGAEgASgIUg1pc1Jhc3BiZXJyeVBpEh'
    'QKBW1vZGVsGAIgASgJUgVtb2RlbBIWCgZzZXJpYWwYAyABKAlSBnNlcmlhbBIaCghyZXZpc2lv'
    'bhgEIAEoCVIIcmV2aXNpb24SEAoDc29jGAUgASgJUgNzb2MSIgoMYXJjaGl0ZWN0dXJlGAYgAS'
    'gJUgxhcmNoaXRlY3R1cmUSGwoJY3B1X2NvcmVzGAcgASgFUghjcHVDb3JlcxIgCgxjcHVfZnJl'
    'cV9taHoYCCADKANSCmNwdUZyZXFNaHoSHgoLY3B1X21pbl9taHoYCSABKANSCWNwdU1pbk1oeh'
    'IeCgtjcHVfbWF4X21oehgKIAEoA1IJY3B1TWF4TWh6EhoKCGdvdmVybm9yGAsgASgJUghnb3Zl'
    'cm5vchIhCgxtZW1vcnlfdG90YWwYDCABKARSC21lbW9yeVRvdGFsEh0KCmdwdV9tZW1vcnkYDS'
    'ABKAlSCWdwdU1lbW9yeRIZCghjcHVfdGVtcBgOIAEoAVIHY3B1VGVtcBItChJ2Y2dlbmNtZF9h'
    'dmFpbGFibGUYDyABKAhSEXZjZ2VuY21kQXZhaWxhYmxlEiMKDXRocm90dGxlZF9yYXcYECABKA'
    'lSDHRocm90dGxlZFJhdxIjCg10aHJvdHRsZWRfbm93GBEgAygJUgx0aHJvdHRsZWROb3cSJQoO'
    'dGhyb3R0bGVkX3Bhc3QYEiADKAlSDXRocm90dGxlZFBhc3QSQQoIdm9sdGFnZXMYEyADKAsyJS'
    '5waWNvbnRyb2wuSGFyZHdhcmVJbmZvLlZvbHRhZ2VzRW50cnlSCHZvbHRhZ2VzEjsKBmNsb2Nr'
    'cxgUIAMoCzIjLnBpY29udHJvbC5IYXJkd2FyZUluZm8uQ2xvY2tzRW50cnlSBmNsb2NrcxIaCg'
    'hmaXJtd2FyZRgVIAEoCVIIZmlybXdhcmUSHgoKYm9vdGxvYWRlchgWIAEoCVIKYm9vdGxvYWRl'
    'chIWCgZrZXJuZWwYFyABKAlSBmtlcm5lbBIOCgJvcxgYIAEoCVICb3MSGgoIaG9zdG5hbWUYGS'
    'ABKAlSCGhvc3RuYW1lEh8KC3VzYl9kZXZpY2VzGBogAygJUgp1c2JEZXZpY2VzGjsKDVZvbHRh'
    'Z2VzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4ARo5Cg'
    'tDbG9ja3NFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use gpioStateDescriptor instead')
const GpioState$json = {
  '1': 'GpioState',
  '2': [
    {'1': 'supported', '3': 1, '4': 1, '5': 8, '10': 'supported'},
    {'1': 'tool', '3': 2, '4': 1, '5': 9, '10': 'tool'},
    {
      '1': 'pins',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.picontrol.GpioPin',
      '10': 'pins'
    },
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `GpioState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpioStateDescriptor = $convert.base64Decode(
    'CglHcGlvU3RhdGUSHAoJc3VwcG9ydGVkGAEgASgIUglzdXBwb3J0ZWQSEgoEdG9vbBgCIAEoCV'
    'IEdG9vbBImCgRwaW5zGAMgAygLMhIucGljb250cm9sLkdwaW9QaW5SBHBpbnMSFAoFZXJyb3IY'
    'BCABKAlSBWVycm9y');

@$core.Deprecated('Use gpioPinDescriptor instead')
const GpioPin$json = {
  '1': 'GpioPin',
  '2': [
    {'1': 'gpio', '3': 1, '4': 1, '5': 5, '10': 'gpio'},
    {'1': 'mode', '3': 2, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'pull', '3': 3, '4': 1, '5': 9, '10': 'pull'},
    {'1': 'level', '3': 4, '4': 1, '5': 8, '10': 'level'},
    {'1': 'function', '3': 5, '4': 1, '5': 9, '10': 'function'},
  ],
};

/// Descriptor for `GpioPin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpioPinDescriptor = $convert.base64Decode(
    'CgdHcGlvUGluEhIKBGdwaW8YASABKAVSBGdwaW8SEgoEbW9kZRgCIAEoCVIEbW9kZRISCgRwdW'
    'xsGAMgASgJUgRwdWxsEhQKBWxldmVsGAQgASgIUgVsZXZlbBIaCghmdW5jdGlvbhgFIAEoCVII'
    'ZnVuY3Rpb24=');

@$core.Deprecated('Use gpioRequestDescriptor instead')
const GpioRequest$json = {
  '1': 'GpioRequest',
  '2': [
    {'1': 'gpio', '3': 1, '4': 1, '5': 5, '10': 'gpio'},
    {'1': 'mode', '3': 2, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'level', '3': 3, '4': 1, '5': 8, '10': 'level'},
    {'1': 'pull', '3': 4, '4': 1, '5': 9, '10': 'pull'},
  ],
};

/// Descriptor for `GpioRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpioRequestDescriptor = $convert.base64Decode(
    'CgtHcGlvUmVxdWVzdBISCgRncGlvGAEgASgFUgRncGlvEhIKBG1vZGUYAiABKAlSBG1vZGUSFA'
    'oFbGV2ZWwYAyABKAhSBWxldmVsEhIKBHB1bGwYBCABKAlSBHB1bGw=');

@$core.Deprecated('Use powerRequestDescriptor instead')
const PowerRequest$json = {
  '1': 'PowerRequest',
  '2': [
    {'1': 'op', '3': 1, '4': 1, '5': 14, '6': '.picontrol.PowerOp', '10': 'op'},
  ],
};

/// Descriptor for `PowerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List powerRequestDescriptor = $convert.base64Decode(
    'CgxQb3dlclJlcXVlc3QSIgoCb3AYASABKA4yEi5waWNvbnRyb2wuUG93ZXJPcFICb3A=');
