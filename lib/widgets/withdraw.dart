import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithdrawBottomSheet extends StatefulWidget {
  final double currentBalance;
  final Function(double amount, String method, String details) onWithdraw;

  const WithdrawBottomSheet({
    super.key,
    required this.currentBalance,
    required this.onWithdraw,
  });

  // Static method to show the bottom sheet
  static void show(
      BuildContext context, {
        required double currentBalance,
        required Function(double amount, String method, String details) onWithdraw,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      // Add this to handle keyboard properly
      useSafeArea: true,
      builder: (context) => WithdrawBottomSheet(
        currentBalance: currentBalance,
        onWithdraw: onWithdraw,
      ),
    );
  }

  @override
  State<WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<WithdrawBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _confirmAccountController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  int _selectedMethodIndex = 0; // 0 for UPI, 1 for Bank
  bool _isProcessing = false;
  final PageController _pageController = PageController();

  final List<double> quickAmounts = [500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _amountController.dispose();
    _upiIdController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _accountHolderController.dispose();
    _confirmAccountController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    _amountController.text = amount.toString();
  }

  void _switchMethod(int index) {
    setState(() {
      _selectedMethodIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Enter amount';
    final amount = double.tryParse(value);
    if (amount == null) return 'Invalid amount';
    if (amount < 100) return 'Minimum ₹100';
    if (amount > widget.currentBalance) return 'Exceeds balance';
    return null;
  }

  String? _validateUpiId(String? value) {
    if (value == null || value.isEmpty) return 'Enter UPI ID';
    if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$').hasMatch(value)) {
      return 'Invalid UPI ID format';
    }
    return null;
  }

  String? _validateRequired(String? value, String field) {
    if (value == null || value.isEmpty) return 'Enter $field';
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) return 'Enter account number';
    if (value.length < 9 || value.length > 18) return '9-18 digits required';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Only digits allowed';
    return null;
  }

  String? _validateIFSC(String? value) {
    if (value == null || value.isEmpty) return 'Enter IFSC';

    // Convert to uppercase for validation
    final ifsc = value.trim().toUpperCase();

    // Check basic length
    if (ifsc.length != 11) return 'IFSC must be 11 characters';

    // Updated regex pattern that handles real-world IFSC codes
    // Format: 4 letters + 1 digit + 6 alphanumeric characters
    if (!RegExp(r'^[A-Z]{4}[0-9][A-Z0-9]{6}$').hasMatch(ifsc)) {
      return 'Invalid IFSC format (e.g., SBIN0001234)';
    }

    return null;
  }

  String? _validateConfirmAccount(String? value) {
    if (value != _accountNumberController.text) return 'Numbers don\'t match';
    return null;
  }

  void _processWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final amount = double.parse(_amountController.text);
    final method = _selectedMethodIndex == 0 ? 'UPI' : 'Bank Transfer';
    String details;

    if (_selectedMethodIndex == 0) {
      details = _upiIdController.text.trim();
    } else {
      details = '${_accountHolderController.text.trim()} - '
          '${_accountNumberController.text.trim()} - '
          '${_ifscController.text.trim().toUpperCase()}';
    }

    try {
      await widget.onWithdraw(amount, method, details);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Error handled by parent
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 100),
          child: Padding(
            // Add padding to avoid keyboard overlay
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: DraggableScrollableSheet(
              initialChildSize: keyboardHeight > 0 ? 0.95 : 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6418C3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(0xFF6418C3),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Withdraw Money',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6418C3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Available Balance: ₹${widget.currentBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6418C3),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            bottom: keyboardHeight > 0 ? 20 : 100, // Adjust padding based on keyboard
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Amount Section
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Withdrawal Amount',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                        ],
                                        validator: _validateAmount,
                                        decoration: InputDecoration(
                                          prefixIcon: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                            child: Text('₹', style: TextStyle(fontSize: 18)),
                                          ),
                                          prefixIconConstraints:
                                          const BoxConstraints(minWidth: 0, minHeight: 0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF6418C3), width: 2),
                                          ),
                                          hintText: 'Enter amount',
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Quick Amount Buttons
                                      Wrap(
                                        spacing: 8,
                                        children: quickAmounts
                                            .where((amount) => amount <= widget.currentBalance)
                                            .map((amount) => GestureDetector(
                                          onTap: () => _setQuickAmount(amount),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Text(
                                              '₹${amount.toInt()}',
                                              style: const TextStyle(
                                                color: Color(0xFF6418C3),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Method Selection
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _switchMethod(0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: _selectedMethodIndex == 0
                                                  ? const Color(0xFF6418C3)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.account_balance_wallet,
                                                  color: _selectedMethodIndex == 0
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'UPI',
                                                  style: TextStyle(
                                                    color: _selectedMethodIndex == 0
                                                        ? Colors.white
                                                        : Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _switchMethod(1),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: _selectedMethodIndex == 1
                                                  ? const Color(0xFF6418C3)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.account_balance,
                                                  color: _selectedMethodIndex == 1
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Bank',
                                                  style: TextStyle(
                                                    color: _selectedMethodIndex == 1
                                                        ? Colors.white
                                                        : Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Forms - Removed fixed height to allow dynamic sizing
                                _selectedMethodIndex == 0
                                    ? _buildUPIForm()
                                    : _buildBankTransferForm(),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Submit Button - Only show when keyboard is not open
                      if (keyboardHeight == 0)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _processWithdrawal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6418C3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Withdraw Money',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUPIForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UPI Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _upiIdController,
            validator: _validateUpiId,
            decoration: InputDecoration(
              labelText: 'UPI ID',
              hintText: 'yourname@paytm',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6418C3), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Money will be transferred within 30 minutes',
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _accountHolderController,
            label: 'Account Holder Name',
            icon: Icons.person,
            validator: (v) => _validateRequired(v, 'name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _accountNumberController,
            label: 'Account Number',
            icon: Icons.account_balance,
            validator: _validateAccountNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmAccountController,
            label: 'Confirm Account Number',
            icon: Icons.verified,
            validator: _validateConfirmAccount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ifscController,
            label: 'IFSC Code',
            icon: Icons.code,
            validator: _validateIFSC,
            textCapitalization: TextCapitalization.characters,
            hintText: 'SBIN0001234',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bank transfers take 1-3 business days',
                    style: TextStyle(fontSize: 13, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          // Add submit button here when keyboard is open
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processWithdrawal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6418C3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Withdraw Money',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6418C3), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}