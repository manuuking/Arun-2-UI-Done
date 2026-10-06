import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(String id);
}

class HiveProductRepository implements ProductRepository {
  Box get _box => Hive.box('products');

  HiveProductRepository() {
    _seedInitialProductsIfNeeded();
  }

  void _seedInitialProductsIfNeeded() {
    if (_box.isEmpty) {
      final p1 = Product(
        id: 'prod_gloves',
        name: 'Cotton Hand Gloves',
        description: 'Cotton Hand Gloves Pair',
        hsnCode: '6116',
        unit: 'Qty.',
        defaultRate: 35.0,
      );

      final p2 = Product(
        id: 'prod_uniforms',
        name: 'Industrial Uniforms',
        description: 'Industrial Safety Uniforms Heavy Duty',
        hsnCode: '6203',
        unit: 'Set',
        defaultRate: 850.0,
      );

      final p3 = Product(
        id: 'prod_vests',
        name: 'High-Vis Vests',
        description: 'Reflective Safety Vests 2-Inch Tape',
        hsnCode: '6114',
        unit: 'Qty.',
        defaultRate: 120.0,
      );

      final p4 = Product(
        id: 'prod_helmet',
        name: 'Safety Helmet',
        description: 'Industrial Hard Hat ISI Marked',
        hsnCode: '6506',
        unit: 'Qty.',
        defaultRate: 240.0,
      );

      _box.put(p1.id, p1.toMap());
      _box.put(p2.id, p2.toMap());
      _box.put(p3.id, p3.toMap());
      _box.put(p4.id, p4.toMap());
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }

  @override
  Future<Product?> getProductById(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      return Product.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    }
    return null;
  }

  @override
  Future<List<Product>> getProducts() async {
    final List<Product> list = [];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        list.add(Product.fromMap(Map<dynamic, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<void> saveProduct(Product product) async {
    await _box.put(product.id, product.toMap());
  }
}
