import 'package:flync/model/storage_config.dart';
import 'package:flync/service/client/ftp_client.dart';
import 'package:flync/service/client/local_client.dart';
import 'package:flync/service/client/storage_client_service.dart';

enum StorageSource {
  local(client: LocalClient.new),
  ftp(client: FtpClient.new);

  const StorageSource({required this.client});

  final StorageClientService Function({required StorageConfig config}) client;
}
