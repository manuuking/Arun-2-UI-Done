import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/number_to_words.dart';
import '../../data/models/company_profile.dart';
import '../../data/models/invoice.dart';
import '../../data/models/product.dart';
import '../../shared/widgets/section_card.dart';
import '../providers/providers.dart';
import 'widgets/step_indicator.dart';

class InvoiceCreateScreen extends ConsumerStatefulWidget {
  final String? editInvoiceId;
  const InvoiceCreateScreen({super.key, this.editInvoiceId});

  @override
  ConsumerState<InvoiceCreateScreen> createState() =>
      _InvoiceCreateScreenState();
}

class _LineItemDraft {
  Product? product;
  String customDescription;
  String hsnCode;
  double quantity;
  double rate;
  String? singlePoNo;
  String? manualPoNo;
  bool isManualPo;
  List<POAllocation> allocations;

  // Controllers to avoid cursor jumping
  late TextEditingController qtyCtrl;
  late TextEditingController rateCtrl;
  late TextEditingController hsnCtrl;
  late TextEditingController descCtrl;
  late TextEditingController manualPoCtrl;

  _LineItemDraft({
    this.product,
    this.customDescription = '',
    this.hsnCode = '',
    this.quantity = 1,
    this.rate = 0,
    this.singlePoNo,
    List<POAllocation>? allocations,
  }) : isManualPo = false,
       allocations = allocations ?? [] {
    qtyCtrl = TextEditingController(
      text: quantity > 0
          ? (quantity % 1 == 0
                ? quantity.toInt().toString()
                : quantity.toString())
          : '',
    );
    rateCtrl = TextEditingController(
      text: rate > 0 ? rate.toStringAsFixed(2) : '',
    );
    hsnCtrl = TextEditingController(text: hsnCode);
    descCtrl = TextEditingController(text: customDescription);
    manualPoCtrl = TextEditingController(text: manualPoNo ?? '');
  }

  double get amount => quantity * rate;

  void dispose() {
    qtyCtrl.dispose();
    rateCtrl.dispose();
    hsnCtrl.dispose();
    descCtrl.dispose();
    manualPoCtrl.dispose();
  }
}

class _InvoiceCreateScreenState extends ConsumerState<InvoiceCreateScreen> {
  int _currentStep = 1;
  final int _totalSteps = 4;
  final List<String> _stepLabels = ['Details', 'Company', 'Products', 'Totals'];

  // Step 1 - Meta & Logistics
  late TextEditingController _invoiceNoCtrl;
  late TextEditingController _challanNoCtrl;
  late TextEditingController _lrNoCtrl;
  late TextEditingController _lrDateCtrl;
  late TextEditingController _parcelNoCtrl;
  DateTime _invoiceDate = DateTime.now();
  String _transportBy = 'VRL Logistics';
  bool _isDuplicateInvoiceNo = false;
  bool _isDuplicateChallanNo = false;

  // Step 2 - Company
  CompanyProfile? _selectedCompany;
  Address? _selectedAddress;
  String _companySearch = '';

  // Step 3 - Line Items
  final List<_LineItemDraft> _items = [];

  // Step 4 - Tax & Compliance
  String _taxMode = 'CGST_SGST'; // CGST_SGST or IGST
  bool _isDuplicate = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _invoiceNoCtrl = TextEditingController(text: 'INV-0029');
    _challanNoCtrl = TextEditingController(text: 'CH-121');
    _lrNoCtrl = TextEditingController(text: '');
    _lrDateCtrl = TextEditingController(
      text: DateFormat('dd MMM yyyy').format(DateTime.now()),
    );
    _parcelNoCtrl = TextEditingController(text: '1');

    _invoiceNoCtrl.addListener(_checkDuplicateNumbers);
    _challanNoCtrl.addListener(_checkDuplicateNumbers);

    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _checkDuplicateNumbers() async {
    final invRepo = ref.read(invoiceRepositoryProvider);
    final allInvoices = await invRepo.getInvoices();

    final inputInvNo = _invoiceNoCtrl.text.trim();
    final inputChallan = _challanNoCtrl.text.trim();

    final hasDupInv = allInvoices.any(
      (i) =>
          i.invoiceNo.toLowerCase() == inputInvNo.toLowerCase() &&
          (widget.editInvoiceId == null || i.id != widget.editInvoiceId),
    );

    final hasDupChallan =
        inputChallan.isNotEmpty &&
        allInvoices.any(
          (i) =>
              i.challanNo?.toLowerCase() == inputChallan.toLowerCase() &&
              (widget.editInvoiceId == null || i.id != widget.editInvoiceId),
        );

    if (mounted) {
      setState(() {
        _isDuplicateInvoiceNo = hasDupInv;
        _isDuplicateChallanNo = hasDupChallan;
      });
    }
  }

  Future<void> _initData() async {
    final invRepo = ref.read(invoiceRepositoryProvider);
    final compRepo = ref.read(companyRepositoryProvider);
    final prodRepo = ref.read(productRepositoryProvider);

    final companies = await compRepo.getCompanies();
    final products = await prodRepo.getProducts();

    // If Editing existing invoice
    if (widget.editInvoiceId != null) {
      final existing = await invRepo.getInvoiceById(widget.editInvoiceId!);
      if (existing != null && mounted) {
        _invoiceNoCtrl.text = existing.invoiceNo;
        _challanNoCtrl.text = existing.challanNo ?? '';
        _invoiceDate = existing.invoiceDate;
        _lrNoCtrl.text = existing.lrNo ?? '';
        _lrDateCtrl.text =
            existing.lrDate ??
            DateFormat('dd MMM yyyy').format(existing.invoiceDate);
        _parcelNoCtrl.text = existing.parcelNo ?? '1';
        _transportBy = existing.transportBy ?? 'VRL Logistics';
        _taxMode = existing.igst > 0 ? 'IGST' : 'CGST_SGST';
        _isDuplicate = existing.invoiceType == 'duplicate';

        if (companies.isNotEmpty) {
          _selectedCompany = companies.firstWhere(
            (c) =>
                c.id == existing.buyerId ||
                c.name.toLowerCase() == existing.buyerName.toLowerCase(),
            orElse: () => companies.first,
          );
          if (_selectedCompany!.addresses.isNotEmpty) {
            _selectedAddress = _selectedCompany!.addresses.first;
          }
        }

        _items.clear();
        for (final item in existing.items) {
          Product? prod = products
              .where(
                (p) => p.id == item.productId || p.name == item.productName,
              )
              .firstOrNull;
          _items.add(
            _LineItemDraft(
              product:
                  prod ??
                  Product(
                    id: item.productId,
                    name: item.productName,
                    hsnCode: item.hsnCode,
                    unit: item.unit,
                    defaultRate: item.rate,
                  ),
              customDescription: item.description ?? '',
              hsnCode: item.hsnCode,
              quantity: item.quantity,
              rate: item.rate,
              singlePoNo: item.poId,
              allocations: List.from(item.poAllocations),
            ),
          );
        }

        setState(() => _isInitialized = true);
        return;
      }
    }

    // Default sequential invoice generation
    final invoices = await invRepo.getInvoices();

    final settingsBox = Hive.box('settings');
    int configuredInvNum = settingsBox.get(
      'last_invoice_sequence',
      defaultValue: 28,
    );
    int configuredChallanNum = settingsBox.get(
      'last_challan_sequence',
      defaultValue: 120,
    );

    int maxNum = configuredInvNum;
    int maxChallanNum = configuredChallanNum;

    for (final inv in invoices) {
      final match = RegExp(r'\d+').firstMatch(inv.invoiceNo);
      if (match != null) {
        final n = int.tryParse(match.group(0)!) ?? 0;
        if (n > maxNum) maxNum = n;
      }

      if (inv.challanNo != null) {
        final cmatch = RegExp(r'\d+').firstMatch(inv.challanNo!);
        if (cmatch != null) {
          final c = int.tryParse(cmatch.group(0)!) ?? 0;
          if (c > maxChallanNum) maxChallanNum = c;
        }
      }
    }

    final nextNum = maxNum + 1;
    final nextInvNo = 'INV-${nextNum.toString().padLeft(4, "0")}';

    final nextChallan = 'CH-${maxChallanNum + 1}';

    if (mounted) {
      setState(() {
        _invoiceNoCtrl.text = nextInvNo;
        _challanNoCtrl.text = nextChallan;

        if (companies.isNotEmpty && _selectedCompany == null) {
          _selectedCompany = companies.first;
          _selectedAddress = companies.first.addresses.isNotEmpty
              ? companies.first.addresses.first
              : null;
        }

        if (products.isNotEmpty && _items.isEmpty) {
          final p = products.first;
          final rate = _getDefaultRateFor(p, _selectedCompany);
          _items.add(
            _LineItemDraft(
              product: p,
              customDescription: '',
              hsnCode: p.hsnCode,
              quantity: 500,
              rate: rate,
              singlePoNo: 'PO-2026/881',
              allocations: [
                POAllocation(
                  poId: 'po_pgp_881',
                  poNo: 'PO-2026/881',
                  allocatedQty: 500,
                ),
              ],
            ),
          );
        }
        _isInitialized = true;
      });
    }
  }

  double _getDefaultRateFor(Product product, CompanyProfile? company) {
    if (company != null) {
      for (final r in company.productRates) {
        if (r.productId == product.id) {
          return r.rate;
        }
      }
    }
    return product.defaultRate;
  }

  List<CompanyProductRate> _getSavedRates(
    Product product,
    CompanyProfile? company,
  ) {
    if (company == null) return [];
    return company.productRates
        .where((r) => r.productId == product.id)
        .toList();
  }

  double get _subtotal => _items.fold(0.0, (sum, i) => sum + i.amount);
  double get _cgst => _taxMode == 'CGST_SGST' ? (_subtotal * 0.025) : 0.0;
  double get _sgst => _taxMode == 'CGST_SGST' ? (_subtotal * 0.025) : 0.0;
  double get _igst => _taxMode == 'IGST' ? (_subtotal * 0.05) : 0.0;
  double get _grandTotal => _subtotal + _cgst + _sgst + _igst;

  @override
  void dispose() {
    _invoiceNoCtrl.dispose();
    _challanNoCtrl.dispose();
    _lrNoCtrl.dispose();
    _lrDateCtrl.dispose();
    _parcelNoCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 2 && _selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a company'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_currentStep == 3) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one product line item'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      for (int i = 0; i < _items.length; i++) {
        final it = _items[i];
        if (it.product == null || it.quantity <= 0 || it.rate <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item #${i + 1} has invalid quantity or rate'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }
    }
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  /// SECTION 17: Save & Generate creates a TEMPORARY PREVIEW only.
  /// Does NOT permanently save to Drive or finalize yet!
  void _saveAndGeneratePreview() {
    if (_selectedCompany == null || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot generate preview: Missing company or line items',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final invNo = _invoiceNoCtrl.text.trim().isNotEmpty
        ? _invoiceNoCtrl.text.trim()
        : 'INV-${now.millisecondsSinceEpoch}';
    final challanNo = _challanNoCtrl.text.trim().isNotEmpty
        ? _challanNoCtrl.text.trim()
        : null;

    final invoiceItems = _items.map((draft) {
      final p = draft.product!;
      final hsn = draft.hsnCtrl.text.trim().isNotEmpty
          ? draft.hsnCtrl.text.trim()
          : p.hsnCode;
      final desc = draft.descCtrl.text.trim().isNotEmpty
          ? draft.descCtrl.text.trim()
          : null;

      // Extract primary PO label
      String? primaryPo;
      if (draft.allocations.isNotEmpty) {
        primaryPo = draft.allocations.first.poNo;
      } else if (draft.isManualPo &&
          draft.manualPoCtrl.text.trim().isNotEmpty) {
        primaryPo = draft.manualPoCtrl.text.trim();
      } else {
        primaryPo = draft.singlePoNo;
      }

      return InvoiceItem(
        id: 'item_${DateTime.now().microsecondsSinceEpoch}_${p.id}',
        productId: p.id,
        productName: p.name,
        description: desc,
        hsnCode: hsn,
        unit: p.unit,
        quantity: draft.quantity,
        rate: draft.rate,
        amount: draft.amount,
        taxSlab: _taxMode == 'CGST_SGST' ? 'CGST+SGST' : 'IGST',
        cgstRate: _taxMode == 'CGST_SGST' ? 2.5 : 0.0,
        sgstRate: _taxMode == 'CGST_SGST' ? 2.5 : 0.0,
        igstRate: _taxMode == 'IGST' ? 5.0 : 0.0,
        poId: primaryPo,
        poAllocations: List.from(draft.allocations),
      );
    }).toList();

    // Primary PO for invoice header
    String? headerPo;
    for (final it in invoiceItems) {
      if (it.poAllocations.isNotEmpty) {
        headerPo = it.poAllocations.first.poNo;
        break;
      } else if (it.poId != null && it.poId!.isNotEmpty) {
        headerPo = it.poId;
        break;
      }
    }

    final fullAddr = _selectedAddress != null
        ? '${_selectedAddress!.fullAddress}, ${_selectedAddress!.city}, ${_selectedAddress!.state} - ${_selectedAddress!.pincode}'
        : (_selectedCompany!.addresses.isNotEmpty
              ? '${_selectedCompany!.addresses.first.fullAddress}, ${_selectedCompany!.addresses.first.city}'
              : 'Rajkot, Gujarat');

    final words = NumberToWords.convert(_grandTotal);

    final previewInvoice = Invoice(
      id: widget.editInvoiceId ?? invNo,
      invoiceNo: invNo,
      challanNo: challanNo,
      invoiceDate: _invoiceDate,
      orderNo: headerPo,
      transportBy: _transportBy,
      lrNo: _lrNoCtrl.text.trim().isNotEmpty ? _lrNoCtrl.text.trim() : null,
      lrDate: _lrDateCtrl.text.trim().isNotEmpty
          ? _lrDateCtrl.text.trim()
          : null,
      parcelNo: _parcelNoCtrl.text.trim().isNotEmpty
          ? _parcelNoCtrl.text.trim()
          : '1',
      sellerId: 'arun_mensware_default',
      buyerId: _selectedCompany!.id,
      buyerName: _selectedCompany!.name,
      buyerGstin: _selectedCompany!.gstin.isNotEmpty
          ? _selectedCompany!.gstin.first
          : null,
      buyerAddress: fullAddr,
      items: invoiceItems,
      subtotal: _subtotal,
      cgst: _cgst,
      sgstAmount: _sgst,
      igst: _igst,
      otherExp: 0.0,
      roundOff: 0.0,
      grandTotal: _grandTotal,
      amountInWords: words,
      invoiceType: _isDuplicate ? 'duplicate' : 'original',
      status: 'pending',
      paidAmount: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    // Open Temporary Preview Page
    context.push('/invoice/preview', extra: previewInvoice);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editInvoiceId != null ? 'Edit Invoice' : 'New Invoice',
          style: AppTextStyles.headlineSm,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: StepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              stepLabels: _stepLabels,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentStep < _totalSteps) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prevStep,
                    child: Text(_currentStep == 1 ? 'CANCEL' : 'BACK'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: const Text('NEXT'),
                  ),
                ),
              ] else ...[
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: _prevStep,
                    child: const Text('BACK'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: ElevatedButton.icon(
                    onPressed: _saveAndGeneratePreview,
                    icon: const Icon(Icons.preview_outlined, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    label: const Text(
                      'SAVE & GENERATE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return _buildStep1();
    }
  }

  // STEP 1 - Meta & Logistics
  Widget _buildStep1() {
    final transportersAsync = ref.watch(transportersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'DOCUMENT META',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _invoiceNoCtrl,
                decoration: InputDecoration(
                  labelText: 'Invoice Number *',
                  suffixIcon: _isDuplicateInvoiceNo
                      ? const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        )
                      : const Icon(Icons.verified, color: Colors.green),
                  helperText: _isDuplicateInvoiceNo
                      ? 'Warning: Invoice number already exists'
                      : null,
                  helperStyle: const TextStyle(color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _challanNoCtrl,
                decoration: InputDecoration(
                  labelText: 'Delivery Challan No',
                  helperText: _isDuplicateChallanNo
                      ? 'Warning: Challan number already exists'
                      : null,
                  helperStyle: const TextStyle(color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('dd MMM yyyy').format(_invoiceDate),
                ),
                decoration: const InputDecoration(
                  labelText: 'Billing Date *',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _invoiceDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() {
                      _invoiceDate = picked;
                      _lrDateCtrl.text = DateFormat('dd MMM yyyy')
                          .format(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Transport Dropdown
              transportersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => DropdownButtonFormField<String>(
                  value: _transportBy,
                  decoration: const InputDecoration(labelText: 'Transport By'),
                  items: const [
                    DropdownMenuItem(
                      value: 'VRL Logistics',
                      child: Text('VRL Logistics'),
                    ),
                    DropdownMenuItem(
                      value: 'DTDC Courier',
                      child: Text('DTDC Courier'),
                    ),
                    DropdownMenuItem(
                      value: 'Self Pickup',
                      child: Text('Self Pickup'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _transportBy = val);
                  },
                ),
                data: (transporters) {
                  final items = transporters.map((t) => t.name).toList();
                  if (!items.contains(_transportBy))
                    items.insert(0, _transportBy);

                  return DropdownButtonFormField<String>(
                    value: _transportBy,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Transport By',
                    ),
                    items: items
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _transportBy = val);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lrNoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'LR Number (Optional)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lrDateCtrl,
                      decoration: const InputDecoration(labelText: 'LR Date'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2 - Company
  Widget _buildStep2() {
    final companiesAsync = ref.watch(companiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'BUYER COMPANY',
          child: companiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading companies: $e'),
            data: (companies) {
              final filtered = companies.where((c) {
                final q = _companySearch.toLowerCase();
                return q.isEmpty ||
                    c.name.toLowerCase().contains(q) ||
                    c.gstin.any((g) => g.toLowerCase().contains(q));
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _companySearch = v),
                    decoration: const InputDecoration(
                      hintText: 'Search company or GSTIN...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CompanyProfile>(
                    value: filtered.any((c) => c.id == _selectedCompany?.id)
                        ? filtered.firstWhere(
                            (c) => c.id == _selectedCompany?.id,
                          )
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Buyer Company *',
                    ),
                    items: filtered.map((c) {
                      return DropdownMenuItem<CompanyProfile>(
                        value: c,
                        child: Text(c.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (c) {
                      if (c != null) {
                        setState(() {
                          _selectedCompany = c;
                          _selectedAddress = c.addresses.isNotEmpty
                              ? c.addresses.first
                              : null;
                          // Update product rates in drafts based on selected company
                          for (final draft in _items) {
                            if (draft.product != null) {
                              draft.rate = _getDefaultRateFor(
                                draft.product!,
                                c,
                              );
                              draft.rateCtrl.text = draft.rate.toStringAsFixed(
                                2,
                              );
                            }
                          }
                        });
                      }
                    },
                  ),
                  if (_selectedCompany != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCompany!.name,
                            style: AppTextStyles.labelLg,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GSTIN: ${_selectedCompany!.gstin.isNotEmpty ? _selectedCompany!.gstin.first : "Unregistered"}',
                            style: AppTextStyles.numericTable.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_selectedCompany!.addresses.length > 1) ...[
                            Text(
                              'Select Delivery Address:',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<Address>(
                              value:
                                  _selectedCompany!.addresses.any(
                                    (a) => a.id == _selectedAddress?.id,
                                  )
                                  ? _selectedCompany!.addresses.firstWhere(
                                      (a) => a.id == _selectedAddress?.id,
                                    )
                                  : (_selectedCompany!.addresses.isNotEmpty
                                        ? _selectedCompany!.addresses.first
                                        : null),
                              isExpanded: true,
                              items: _selectedCompany!.addresses.map((a) {
                                return DropdownMenuItem<Address>(
                                  value: a,
                                  child: Text(
                                    '${a.label}: ${a.fullAddress}, ${a.city}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (addr) {
                                if (addr != null)
                                  setState(() => _selectedAddress = addr);
                              },
                            ),
                          ] else if (_selectedCompany!
                              .addresses
                              .isNotEmpty) ...[
                            Text(
                              'Billing & Delivery Address:',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedCompany!.addresses.first.fullAddress}, ${_selectedCompany!.addresses.first.city} - ${_selectedCompany!.addresses.first.pincode}',
                              style: AppTextStyles.bodySm,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // STEP 3 - Line Items & PO Allocations
  Widget _buildStep3() {
    final productsAsync = ref.watch(productsProvider);
    final posAsync = ref.watch(purchaseOrdersProvider);
    final invoicesAsync = ref.watch(invoicesProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading products: $e'),
      data: (products) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BILLED LINE ITEMS (${_items.length})',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final draft = entry.value;
              final savedRates = draft.product != null
                  ? _getSavedRates(draft.product!, _selectedCompany)
                  : <CompanyProductRate>[];

              // Company-specific active POs
              final companyPos =
                  posAsync.value
                      ?.where(
                        (p) =>
                            p.companyId == _selectedCompany?.id && p.isActive,
                      )
                      .toList() ??
                  [];

              final poBalances = companyPos.map((p) {
                return ref
                    .read(poRepositoryProvider)
                    .calculatePOBalance(p, invoicesAsync.value ?? []);
              }).toList();

              final otherUsedPOs = _items
                  .where(
                    (item) =>
                        item != draft &&
                        item.singlePoNo != null &&
                        !item.isManualPo,
                  )
                  .map((item) => item.singlePoNo)
                  .toSet();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row (Item # and delete)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<Product>(
                            value:
                                products.any((p) => p.id == draft.product?.id)
                                ? products.firstWhere(
                                    (p) => p.id == draft.product?.id,
                                  )
                                : null,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Product *',
                            ),
                            items: products.map((p) {
                              return DropdownMenuItem<Product>(
                                value: p,
                                child: Text(
                                  p.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (p) {
                              if (p != null) {
                                setState(() {
                                  draft.product = p;
                                  draft.hsnCode = p.hsnCode;
                                  draft.hsnCtrl.text = p.hsnCode;
                                  draft.rate = _getDefaultRateFor(
                                    p,
                                    _selectedCompany,
                                  );
                                  draft.rateCtrl.text = draft.rate
                                      .toStringAsFixed(2);
                                });
                              }
                            },
                          ),
                        ),
                        if (_items.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            onPressed: () {
                              setState(() {
                                final removed = _items.removeAt(index);
                                removed.dispose();
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Section 11: Dedicated HSN field
                    TextFormField(
                      controller: draft.hsnCtrl,
                      decoration: const InputDecoration(
                        labelText: 'HSN Code *',
                        hintText: 'e.g. 6116',
                      ),
                      onChanged: (v) => draft.hsnCode = v,
                    ),
                    const SizedBox(height: 12),

                    // Section 10: Manual custom description field
                    TextFormField(
                      controller: draft.descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Custom Description (Optional)',
                        hintText: 'e.g. Special dispatch',
                      ),
                      onChanged: (v) => draft.customDescription = v,
                    ),
                    const SizedBox(height: 12),

                    // Rates Dropdown + Custom Rate
                    if (savedRates.isNotEmpty) ...[
                      DropdownButtonFormField<double>(
                        value: savedRates.any((r) => r.rate == draft.rate)
                            ? draft.rate
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Company-Specific Predefined Rates',
                        ),
                        items: [
                          ...savedRates.map(
                            (r) => DropdownMenuItem(
                              value: r.rate,
                              child: Text(
                                '${r.label}: ₹${CurrencyFormatter.formatNumber(r.rate)}',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (r) {
                          if (r != null) {
                            setState(() {
                              draft.rate = r;
                              draft.rateCtrl.text = r.toStringAsFixed(2);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Qty & Clean Rate Input
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: draft.qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Qty.'),
                            onChanged: (v) {
                              final q = double.tryParse(v) ?? 0.0;
                              setState(() => draft.quantity = q);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: draft.rateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Rate (₹)',
                              prefixText: '₹ ',
                            ),
                            onChanged: (v) {
                              final r = double.tryParse(v) ?? 0.0;
                              setState(() => draft.rate = r);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // PO Allocation Control
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PO ALLOCATION',
                            style: AppTextStyles.labelSm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Manual PO Toggle
                          Row(
                            children: [
                              Checkbox(
                                value: draft.isManualPo,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onChanged: (val) {
                                  setState(() {
                                    draft.isManualPo = val ?? false;
                                    if (draft.isManualPo) {
                                      draft.singlePoNo = null;
                                      draft.allocations = [];
                                    } else {
                                      draft.manualPoNo = null;
                                      draft.manualPoCtrl.clear();
                                    }
                                  });
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  'Manual PO Number (Does not affect stock)',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),

                          if (draft.isManualPo) ...[
                            TextFormField(
                              controller: draft.manualPoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Manual PO Number',
                                hintText: 'e.g. CUSTOM-123',
                              ),
                              onChanged: (v) => draft.manualPoNo = v,
                            ),
                          ] else ...[
                            DropdownButtonFormField<String>(
                              value:
                                  poBalances.any(
                                    (bal) => bal.po.poNo == draft.singlePoNo,
                                  )
                                  ? draft.singlePoNo
                                  : null,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select PO ▼',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
                              items: poBalances.map((bal) {
                                final isLocked = otherUsedPOs.contains(
                                  bal.po.poNo,
                                );
                                final isFull =
                                    bal.remainingQty <= 0 &&
                                    draft.singlePoNo != bal.po.poNo;

                                String label =
                                    '${bal.po.poNo} | Total: ${CurrencyFormatter.formatQuantity(bal.po.orderedQty)} | Used: ${CurrencyFormatter.formatQuantity(bal.po.orderedQty - bal.remainingQty)} | Remaining: ${CurrencyFormatter.formatQuantity(bal.remainingQty)}';
                                if (isLocked) {
                                  label =
                                      '🔒 $label (Already used in this invoice)';
                                } else if (isFull) {
                                  label = '🚫 $label (FULL / COMPLETED)';
                                }

                                return DropdownMenuItem<String>(
                                  value: bal.po.poNo,
                                  enabled: !isLocked && !isFull,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: (isLocked || isFull)
                                          ? AppColors.onSurfaceVariant
                                          : AppColors.onSurface,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final selectedPo = companyPos.firstWhere(
                                    (p) => p.poNo == val,
                                  );
                                  setState(() {
                                    draft.singlePoNo = val;
                                    draft.allocations = [
                                      POAllocation(
                                        poId: selectedPo.id,
                                        poNo: selectedPo.poNo,
                                        allocatedQty: draft.quantity,
                                      ),
                                    ];
                                  });
                                }
                              },
                            ),

                            if (draft.singlePoNo != null &&
                                draft.allocations.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Builder(
                                builder: (context) {
                                  final bal = poBalances.firstWhere(
                                    (b) => b.po.poNo == draft.singlePoNo,
                                  );
                                  // Auto-sync qty
                                  draft.allocations[0] = POAllocation(
                                    poId: draft.allocations.first.poId,
                                    poNo: draft.allocations.first.poNo,
                                    allocatedQty: draft.quantity,
                                  );

                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.outlineVariant,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          draft.singlePoNo!,
                                          style: AppTextStyles.labelMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Current Allocation:',
                                              style: AppTextStyles.bodySm,
                                            ),
                                            Text(
                                              '${CurrencyFormatter.formatQuantity(draft.quantity)} Qty',
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total PO Qty:',
                                              style: AppTextStyles.bodySm,
                                            ),
                                            Text(
                                              '${CurrencyFormatter.formatQuantity(bal.po.orderedQty)} Qty',
                                              style: AppTextStyles.bodySm,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Used Qty:',
                                              style: AppTextStyles.bodySm,
                                            ),
                                            Text(
                                              '${CurrencyFormatter.formatQuantity(bal.po.orderedQty - bal.remainingQty)} Qty',
                                              style: AppTextStyles.bodySm,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Remaining Qty:',
                                              style: AppTextStyles.bodySm
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              '${CurrencyFormatter.formatQuantity(bal.remainingQty)} Qty',
                                              style: AppTextStyles.bodySm
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        bal.remainingQty <
                                                            draft.quantity
                                                        ? AppColors.error
                                                        : AppColors.secondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        if (bal.remainingQty < draft.quantity)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              'PO Qty Exceeded (${CurrencyFormatter.formatQuantity(draft.quantity - bal.remainingQty)})',
                                              style: const TextStyle(
                                                color: AppColors.error,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Line Amount:',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '₹${CurrencyFormatter.formatNumber(draft.amount)}',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('ADD ANOTHER PRODUCT'),
                onPressed: () {
                  setState(() {
                    _items.add(
                      _LineItemDraft(
                        product: products.isNotEmpty ? products.first : null,
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'PARCEL INFORMATION',
              child: TextFormField(
                controller: _parcelNoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Parcel No *',
                  hintText: 'e.g. 12',
                  prefixIcon: Icon(Icons.inventory_outlined),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items Subtotal:',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${CurrencyFormatter.formatNumber(_subtotal)}',
                    style: AppTextStyles.headlineSm,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // STEP 4 - Compliance, Taxes & Summary
  Widget _buildStep4() {
    final words = NumberToWords.convert(_grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'TAX CONFIGURATION & SUMMARY',
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _taxMode,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tax Structure *'),
                items: const [
                  DropdownMenuItem(
                    value: 'CGST_SGST',
                    child: Text(
                      'Intra-state: CGST 2.5% + SGST 2.5% (Total 5%)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'IGST',
                    child: Text(
                      'Inter-state: IGST 5.0%',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _taxMode = v);
                },
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(
                'Taxable Subtotal',
                '₹${CurrencyFormatter.formatNumber(_subtotal)}',
              ),
              const SizedBox(height: 6),
              if (_taxMode == 'CGST_SGST') ...[
                _buildSummaryRow(
                  'Add CGST 2.5%',
                  '₹${CurrencyFormatter.formatNumber(_cgst)}',
                  isMuted: true,
                ),
                const SizedBox(height: 6),
                _buildSummaryRow(
                  'Add SGST 2.5%',
                  '₹${CurrencyFormatter.formatNumber(_sgst)}',
                  isMuted: true,
                ),
              ] else ...[
                _buildSummaryRow(
                  'Add IGST 5.0%',
                  '₹${CurrencyFormatter.formatNumber(_igst)}',
                  isMuted: true,
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.onSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GRAND TOTAL',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    Text(
                      '₹${CurrencyFormatter.formatNumber(_grandTotal)}',
                      style: AppTextStyles.headlineLg.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Amount in Words: $words',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'COMPLIANCE & TYPE',
          child: Column(
            children: [
              if (_grandTotal >= 50000)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'E-Way Bill generation mandatory (Grand Total exceeds ₹50,000)',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isMuted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: isMuted ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.bold,
            color: isMuted ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
