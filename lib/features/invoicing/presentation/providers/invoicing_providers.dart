import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/invoicing_local_datasource.dart';
import '../../data/repositories/invoicing_repository_impl.dart';
import '../../domain/repositories/invoicing_repository.dart';
import '../../domain/entities/invoice.dart' as domain;
import '../../../../core/database/app_database.dart' as db;

final invoicingDataSourceProvider = Provider<InvoicingLocalDataSource>((ref) {
  return InvoicingLocalDataSource(ref.watch(db.databaseProvider));
});

final invoicingRepositoryProvider = Provider<InvoicingRepository>((ref) {
  return InvoicingRepositoryImpl(ref.watch(invoicingDataSourceProvider));
});

final invoicesProvider = FutureProvider<List<domain.Invoice>>((ref) async {
  final result = await ref.watch(invoicingRepositoryProvider).getAllInvoices();
  return result.when(success: (d) => d, error: (f) => throw Exception(f.message));
});

final invoiceItemsProvider = FutureProvider.family<List<domain.InvoiceItem>, String>((ref, invoiceId) async {
  final result = await ref.watch(invoicingRepositoryProvider).getInvoiceItems(invoiceId);
  return result.when(success: (d) => d, error: (f) => throw Exception(f.message));
});
