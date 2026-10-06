import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_card.dart';

class Step1InvoiceDetails extends StatelessWidget {
  const Step1InvoiceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'DOCUMENT META',
          child: Column(
            children: [
              TextFormField(
                initialValue: 'INV-0029',
                decoration: const InputDecoration(
                  labelText: 'Invoice Number',
                  suffixIcon: Icon(Icons.verified, color: Colors.green),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Delivery Challan No',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '03 Oct 2026',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Billing Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Transport By'),
                items: const [
                  DropdownMenuItem(value: 'vrl', child: Text('VRL Logistics')),
                  DropdownMenuItem(value: 'dtdc', child: Text('DTDC')),
                ],
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'LR Number (Optional)',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
