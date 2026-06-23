import '../../../../core/utils/result.dart';
import '../entities/invoice.dart';

abstract class InvoicingRepository {
  Future<Result<List<Invoice>>> getAllInvoices();
  Future<Result<Invoice?>> getInvoiceById(String id);
  Future<Result<Invoice>> createInvoice(Invoice invoice);
  Future<Result<Invoice>> updateInvoice(Invoice invoice);
  Future<Result<void>> deleteInvoice(String id);
  Future<Result<Invoice>> generateFromOrder(String orderId);
  Future<Result<List<InvoiceItem>>> getInvoiceItems(String invoiceId);
  Future<Result<String>> getNextInvoiceNumber();
}
