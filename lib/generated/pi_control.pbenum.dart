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

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
