import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/invoicing_repository.dart';
import '../../domain/entities/invoice.dart';
import '../datasources/invoicing_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class InvoicingRepositoryImpl implements InvoicingRepository {
  final InvoicingLocalDataSource _dataSource;
  final _uuid = const Uuid();
  InvoicingRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Invoice>>> getAllInvoices() async {
    try {
      final data = await _dataSource.getAllInvoices();
      return Success(data.map((i) => _mapInvoice(i)).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to load invoices: $e'));
    }
  }

  @override
  Future<Result<Invoice?>> getInvoiceById(String id) async {
    try {
      final data = await _dataSource.getInvoiceById(id);
      return Success(data != null ? _mapInvoice(data) : null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load invoice: $e'));
    }
  }

  @override
  Future<Result<Invoice>> createInvoice(Invoice invoice) async {
    try {
      await _dataSource.insertInvoice(
        db.InvoicesCompanion(
          id: Value(invoice.id),
          invoiceNumber: Value(invoice.invoiceNumber),
          orderId: Value(invoice.orderId),
          customerId: Value(invoice.customerId),
          dueDate: Value(invoice.dueDate),
          status: Value(invoice.status),
          total: Value(invoice.total),
          createdAt: Value(invoice.createdAt),
          updatedAt: Value(invoice.updatedAt),
        ),
      );
      return Success(invoice);
    } catch (e) {
      return Error(DatabaseFailure('Failed to create invoice: $e'));
    }
  }

  @override
  Future<Result<Invoice>> updateInvoice(Invoice invoice) async {
    try {
      await _dataSource.updateInvoice(
        db.InvoicesCompanion(
          invoiceNumber: Value(invoice.invoiceNumber),
          orderId: Value(invoice.orderId),
          customerId: Value(invoice.customerId),
          dueDate: Value(invoice.dueDate),
          status: Value(invoice.status),
          total: Value(invoice.total),
          updatedAt: Value(DateTime.now()),
        ),
        invoice.id,
      );
      return Success(invoice);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update invoice: $e'));
    }
  }

  @override
  Future<Result<void>> deleteInvoice(String id) async {
    try {
      await _dataSource.deleteInvoice(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete invoice: $e'));
    }
  }

  @override
  Future<Result<Invoice>> generateFromOrder(String orderId) async {
    try {
      final data = await _dataSource.getOrderWithDetails(orderId);
      if (data == null) {
        return const Error(DatabaseFailure('Order not found'));
      }

      final order = data['order'] as db.Order;
      final customerName = data['customerName'] as String?;
      final items = data['items'] as List<db.OrderItem>;
      final count = await _dataSource.getInvoiceCount();
      final invoiceNumber =
          'INV-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${(count + 1).toString().padLeft(4, '0')}';

      final invoiceId = _uuid.v4();
      final now = DateTime.now();
      final dueDate = now.add(const Duration(days: 30));

      await _dataSource.insertInvoice(
        db.InvoicesCompanion(
          id: Value(invoiceId),
          invoiceNumber: Value(invoiceNumber),
          orderId: Value(orderId),
          customerId: Value(order.customerId),
          dueDate: Value(dueDate),
          status: const Value('pending'),
          total: Value(order.total),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      for (final item in items) {
        final productName = await _dataSource.getProductName(item.productId);
        final desc = productName ?? 'Product';
        await _dataSource.insertInvoiceItem(
          db.InvoiceItemsCompanion(
            id: Value(_uuid.v4()),
            invoiceId: Value(invoiceId),
            description: Value(desc),
            quantity: Value(item.quantity),
            unitPrice: Value(item.unitPrice),
            total: Value(item.subtotal),
          ),
        );
      }

      final invoice = Invoice(
        id: invoiceId,
        invoiceNumber: invoiceNumber,
        orderId: orderId,
        customerId: order.customerId,
        customerName: customerName,
        dueDate: dueDate,
        status: 'pending',
        total: order.total,
        createdAt: now,
        updatedAt: now,
      );
      return Success(invoice);
    } catch (e) {
      return Error(DatabaseFailure('Failed to generate invoice: $e'));
    }
  }

  @override
  Future<Result<List<InvoiceItem>>> getInvoiceItems(String invoiceId) async {
    try {
      final data = await _dataSource.getInvoiceItems(invoiceId);
      return Success(
        data
            .map(
              (i) => InvoiceItem(
                id: i.id,
                invoiceId: i.invoiceId,
                description: i.description,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                total: i.total,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Error(DatabaseFailure('Failed to load invoice items: $e'));
    }
  }

  @override
  Future<Result<String>> getNextInvoiceNumber() async {
    try {
      final count = await _dataSource.getInvoiceCount();
      final number =
          'INV-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${(count + 1).toString().padLeft(4, '0')}';
      return Success(number);
    } catch (e) {
      return Error(DatabaseFailure('Failed to generate number: $e'));
    }
  }

  Invoice _mapInvoice(db.Invoice row) {
    return Invoice(
      id: row.id,
      invoiceNumber: row.invoiceNumber,
      orderId: row.orderId,
      customerId: row.customerId,
      dueDate: row.dueDate,
      status: row.status,
      total: row.total,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
