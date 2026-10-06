import 'package:hive_flutter/hive_flutter.dart';

import '../models/transporter.dart';

abstract class TransporterRepository {
  Future<List<Transporter>> getTransporters({bool? activeOnly});
  Future<Transporter?> getTransporterById(String id);
  Future<void> saveTransporter(Transporter transporter);
  Future<void> deleteTransporter(String id);
  Future<void> toggleActive(String id, bool isActive);
}

class HiveTransporterRepository implements TransporterRepository {
  Box get _box => Hive.box('transporters');

  HiveTransporterRepository() {
    _seedInitialDataIfNeeded();
  }

  void _seedInitialDataIfNeeded() {
    if (_box.isEmpty) {
      final list = [
        Transporter(
          id: 'tr_vrl',
          name: 'VRL Logistics',
          phone: '+91 9428012345',
          isActive: true,
        ),
        Transporter(
          id: 'tr_dtdc',
          name: 'DTDC Courier',
          phone: '+91 9825098765',
          isActive: true,
        ),
        Transporter(
          id: 'tr_tci',
          name: 'TCI Freight',
          phone: '+91 9712345678',
          isActive: true,
        ),
        Transporter(
          id: 'tr_self',
          name: 'Self Pickup',
          phone: '',
          isActive: true,
        ),
      ];

      for (final t in list) {
        _box.put(t.id, t.toMap());
      }
    }
  }

  @override
  Future<List<Transporter>> getTransporters({bool? activeOnly}) async {
    final List<Transporter> list = [];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        final t = Transporter.fromMap(Map<dynamic, dynamic>.from(raw));
        if (activeOnly == true && !t.isActive) continue;
        list.add(t);
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<Transporter?> getTransporterById(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      return Transporter.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    }
    return null;
  }

  @override
  Future<void> saveTransporter(Transporter transporter) async {
    await _box.put(transporter.id, transporter.toMap());
  }

  @override
  Future<void> deleteTransporter(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> toggleActive(String id, bool isActive) async {
    final t = await getTransporterById(id);
    if (t != null) {
      final updated = t.copyWith(isActive: isActive);
      await saveTransporter(updated);
    }
  }
}
