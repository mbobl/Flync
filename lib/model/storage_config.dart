import 'package:flync/model/storage_source.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_config.freezed.dart';
part 'storage_config.g.dart';

@freezed
class StorageConfig with _$StorageConfig {
  const factory StorageConfig({
    required StorageSource source,
    String? hostname,
    String? directory,
    String? username,
    String? password,
  }) = _StorageConfig;

  factory StorageConfig.fromJson(Map<String, Object?> json) =>
      _$StorageConfigFromJson(json);
}
