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

  factory SellerProfile.defaultProfile() {
    return SellerProfile(
      name: 'ARUN MENSWARE SERVICE',
      address: 'Laxmi Chhaya Society-1, Plot No 177, 25 Mtr,\n150 Feet Ring Road, Rajkot, Gujarat - 360005.',
      gstin: '24AKZPP9424E1ZM',
      phone: '+91 - 9824417257',
      email: 'Arunmsws@gmail.com',
      bankName: 'HDFC RAJKOT',
      accountNo: '03792000003498',
      ifsc: 'HDFC0000379',
      bankEmail: 'Arunmsws@gmail.com',
      termsAndConditions: [
        'Interest @ 21% will be charged if payment is not made within 10 days.',
        'We will not be responsible for loss of the materials when it leaves our premises.',
        'Payment by A/c Payee Cheque/Draft Only.',
        'Subject To Rajkot Jurisdiction Only. E & O.E.'
      ],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'gstin': gstin,
      'phone': phone,
      'email': email,
      'bankName': bankName,
      'accountNo': accountNo,
      'ifsc': ifsc,
      'bankEmail': bankEmail,
      'termsAndConditions': termsAndConditions,
      'logoPath': logoPath,
      'signaturePath': signaturePath,
    };
  }

  factory SellerProfile.fromMap(Map<dynamic, dynamic> map) {
    return SellerProfile(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      gstin: map['gstin'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNo: map['accountNo'] ?? '',
      ifsc: map['ifsc'] ?? '',
      bankEmail: map['bankEmail'],
      termsAndConditions: (map['termsAndConditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      logoPath: map['logoPath'],
      signaturePath: map['signaturePath'],
    );
  }
}
