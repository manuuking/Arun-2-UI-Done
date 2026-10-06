import 'package:hive_flutter/hive_flutter.dart';

import '../models/company_profile.dart';

abstract class CompanyRepository {
  Future<List<CompanyProfile>> getCompanies();
  Future<CompanyProfile?> getCompanyById(String id);
  Future<void> saveCompany(CompanyProfile company);
  Future<void> deleteCompany(String id);
}

class HiveCompanyRepository implements CompanyRepository {
  Box get _box => Hive.box('companies');

  HiveCompanyRepository() {
    _seedInitialCompaniesIfNeeded();
  }

  void _seedInitialCompaniesIfNeeded() {
    if (_box.isEmpty) {
      final now = DateTime.now();

      final c1 = CompanyProfile(
        id: 'comp_pgp',
        name: 'M/s PGP Glass Private Limited',
        shortName: 'PGP Glass',
        gstin: ['24AALCP5737F1ZA'],
        addresses: [
          Address(
            id: 'addr_pgp_1',
            label: 'Billing (Ring Road)',
            fullAddress: 'Plot No 177, 25 Mtr, 150 Feet Ring Road',
            city: 'Rajkot',
            state: 'Gujarat',
            pincode: '360005',
          ),
          Address(
            id: 'addr_pgp_2',
            label: 'Delivery Warehouse (Metoda)',
            fullAddress: 'Plot No 412, Gate 3, Lodhika GIDC, Metoda',
            city: 'Rajkot',
            state: 'Gujarat',
            pincode: '360021',
          ),
        ],
        productRates: [
          CompanyProductRate(
            productId: 'prod_gloves',
            label: 'Contract Rate',
            rate: 35.0,
          ),
          CompanyProductRate(
            productId: 'prod_vests',
            label: 'Special Rate',
            rate: 115.0,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 30)),
      );

      final c2 = CompanyProfile(
        id: 'comp_sterling',
        name: 'Sterling Safety Equips Ltd',
        shortName: 'Sterling',
        gstin: ['24BBXPT8991K1Z2'],
        addresses: [
          Address(
            id: 'addr_sterling_1',
            label: 'Head Office',
            fullAddress: 'GIDC Phase II, Naroda',
            city: 'Ahmedabad',
            state: 'Gujarat',
            pincode: '382330',
          ),
        ],
        productRates: [
          CompanyProductRate(
            productId: 'prod_uniforms',
            label: 'Bulk Rate',
            rate: 850.0,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 45)),
      );

      final c3 = CompanyProfile(
        id: 'comp_saurashtra',
        name: 'Saurashtra Industrial Corp',
        shortName: 'SIC Morbi',
        gstin: ['24CCHYP4412J1Z9'],
        addresses: [
          Address(
            id: 'addr_sic_1',
            label: 'Plant 1',
            fullAddress: '8-A National Highway, Near Ceramic Zone',
            city: 'Morbi',
            state: 'Gujarat',
            pincode: '363642',
          ),
        ],
        productRates: [
          CompanyProductRate(
            productId: 'prod_vests',
            label: 'Standard',
            rate: 120.0,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 60)),
      );

      _box.put(c1.id, c1.toMap());
      _box.put(c2.id, c2.toMap());
      _box.put(c3.id, c3.toMap());
    }
  }

  @override
  Future<void> deleteCompany(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<CompanyProfile>> getCompanies() async {
    final List<CompanyProfile> list = [];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        list.add(CompanyProfile.fromMap(Map<dynamic, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<CompanyProfile?> getCompanyById(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      return CompanyProfile.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    }
    for (final key in _box.keys) {
      final rawItem = _box.get(key);
      if (rawItem is Map) {
        final c = CompanyProfile.fromMap(Map<dynamic, dynamic>.from(rawItem));
        if (c.id == id || c.name.toLowerCase() == id.toLowerCase()) {
          return c;
        }
      }
    }
    return null;
  }

  @override
  Future<void> saveCompany(CompanyProfile company) async {
    await _box.put(company.id, company.toMap());
  }
}
