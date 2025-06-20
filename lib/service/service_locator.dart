import 'package:flync/service/persistence_service.dart';
import 'package:flync/service/sync/sync_service.dart';
import 'package:flync/ui/page/home/home_page_manager.dart';
import 'package:flync/ui/page/storage_form/storage_config_page_manager.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final dbInstance = HivePersistenceService();
  await dbInstance.initialize();
  getIt
    ..registerSingleton<PersistenceService>(dbInstance)
    ..registerLazySingleton<SyncService>(() => SimpleSyncService())
    ..registerLazySingleton<HomePageManager>(() => HomePageManager())
    ..registerLazySingleton<StorageConfigPageManager>(
      () => StorageConfigPageManager(),
    );
}
