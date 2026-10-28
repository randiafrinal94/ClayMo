import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Di web, sqflite berjalan di atas sqlite3.wasm (disiapkan oleh
/// `dart run sqflite_common_ffi_web:setup` ke folder `web/`).
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
