import 'package:drift/drift.dart';
import 'package:drift/web.dart';

Future<QueryExecutor> createQueryExecutor(String dbName) async {
  return WebDatabase(dbName);
}
