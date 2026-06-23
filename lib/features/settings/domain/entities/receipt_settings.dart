import 'package:equatable/equatable.dart';

class ReceiptSettings extends Equatable {
  final String id;
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;
  final double taxRate;
  final int paperWidth;
  final String? headerText;
  final String? footerText;
  final String? logoPath;
  final bool showTax;
  final bool showDiscount;

  const ReceiptSettings({
    this.id = 'default',
    this.storeName,
    this.storeAddress,
    this.storePhone,
    this.taxRate = 0,
    this.paperWidth = 58,
    this.headerText,
    this.footerText,
    this.logoPath,
    this.showTax = true,
    this.showDiscount = true,
  });

  ReceiptSettings copyWith({
    String? id,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    double? taxRate,
    int? paperWidth,
    String? headerText,
    String? footerText,
    String? logoPath,
    bool? showTax,
    bool? showDiscount,
  }) {
    return ReceiptSettings(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      taxRate: taxRate ?? this.taxRate,
      paperWidth: paperWidth ?? this.paperWidth,
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      logoPath: logoPath ?? this.logoPath,
      showTax: showTax ?? this.showTax,
      showDiscount: showDiscount ?? this.showDiscount,
    );
  }

  @override
  List<Object?> get props => [id, storeName, storeAddress, taxRate, paperWidth];
}
