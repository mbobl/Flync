import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_metadata.freezed.dart';

part 'file_metadata.g.dart';

@freezed
class FileMetadata with _$FileMetadata {
  const factory FileMetadata({
    required String name,
    required int size,
    required DateTime modified,
  }) = _FileMetadata;

  factory FileMetadata.fromJson(Map<String, Object?> json) =>
      _$FileMetadataFromJson(json);
}
