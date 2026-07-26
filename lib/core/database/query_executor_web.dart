import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

Future<QueryExecutor> createQueryExecutor(String dbName) async {
  // ignore: deprecated_member_use
  return WebDatabase(dbName);
}
