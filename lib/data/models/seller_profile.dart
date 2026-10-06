class SellerProfile {
  final String name;
  final String? logoPath;
  final String address;
  final String gstin;
  final String phone;
  final String email;
  final String? manufacturerInfo;
  final String bankName;
  final String accountNo;
  final String ifsc;
  final String? bankEmail;
  final List<String> termsAndConditions;
  final String? signaturePath;
  final String? footerNote;

  SellerProfile({
    required this.name,
    this.logoPath,
    required this.address,
    required this.gstin,
    required this.phone,
    required this.email,
    this.manufacturerInfo,
    required this.bankName,
    required this.accountNo,
    required this.ifsc,
    this.bankEmail,
    this.termsAndConditions = const [],
    this.signaturePath,
    this.footerNote,
  });
}
