import 'package:flutter/material.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/constants/index.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  double get amount => double.tryParse(_amountController.text) ?? 0;
  double get fee => amount > 0 ? 1.0 : 0;
  double get total => amount + fee;

  void _adjustAmount(double change) {
    final double currentAmount = amount;
    final double newAmount = (currentAmount + change).clamp(0, 500);
    _amountController.text = newAmount.toStringAsFixed(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, iconRemove: false, elevationWhite: true, name: 'Pul Geçirmek'),
      body: Container(
        decoration: const BoxDecoration(
          color: kPrimaryColorBlack,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Phone Number Input
                      _buildInputCard(
                        title: 'Geçirjek nomeri',
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            prefix: Text(
                              '+993',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: kDarkOrange, width: 2),
                            ),
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Amount Input
                      _buildInputCard(
                        title: 'Geçirjek puluň möçberi',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildAdjustButton(Icons.remove, () => _adjustAmount(-10)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                        borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                        borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                        borderSide: BorderSide(color: kDarkOrange, width: 2),
                                      ),
                                      contentPadding: EdgeInsets.all(16),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      final double? val = double.tryParse(value);
                                      if (val != null && val > 500) {
                                        _amountController.text = '500';
                                        _amountController.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _amountController.text.length),
                                        );
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildAdjustButton(Icons.add, () => _adjustAmount(10)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Maksimum: 500 manat',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Fee Information
                      if (amount > 0)
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF5F0), Color(0xFFFFE5D9)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD4C4), width: 2),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildFeeRow('Möçber:', '${amount.toStringAsFixed(2)} TMT', false),
                              const SizedBox(height: 12),
                              _buildFeeRow('Komissiýa:', '+${fee.toStringAsFixed(2)} TMT', true),
                              const Divider(height: 32, thickness: 2, color: Color(0xFFFFD4C4)),
                              _buildFeeRow('Jemi:', '${total.toStringAsFixed(2)} TMT', false, isTotal: true),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Submit Button
                      if (amount > 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          onPressed: (_phoneController.text.isNotEmpty && amount > 0 && amount <= 500)
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Üstünlikli!'),
                                      content: Text('${total.toStringAsFixed(2)} TMT geçirildi'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Bolýar'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              : null,
                          // icon: const Icon(Icons.send_rounded, size: 20),
                          label: Container(
                            decoration: (_phoneController.text.isNotEmpty && amount > 0 && amount <= 500)
                                ? const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                  )
                                : BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                  ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Geçirmek',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: kAccentColor),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, bool isHighlight, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 24 : (isHighlight ? 18 : 20),
            fontWeight: FontWeight.bold,
            color: isHighlight ? kAccentColor : (isTotal ? kDarkOrange : const Color(0xFF1F2937)),
          ),
        ),
      ],
    );
  }
}
