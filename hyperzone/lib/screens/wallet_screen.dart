import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  final double balance;
  final List<Map<String, dynamic>> transactions; 
  const WalletScreen({
    Key? key,
    required this.balance,
    required this.transactions,
  }) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

enum WalletTab { addMoney, history }

enum _PaymentMethod { upi, card, netbanking }

class _WalletScreenState extends State<WalletScreen> {
  late double _walletBalance;
  bool _hideBalance = false;
  WalletTab _selectedTab = WalletTab.addMoney;

  final TextEditingController _amountController =
      TextEditingController(text: '200');
  _PaymentMethod _activeMethod = _PaymentMethod.upi;

  
  late List<_WalletTx> _historyTx;
  @override
  void initState() {
    super.initState();

    _walletBalance = widget.balance;

    // Map HomeScreen transactions → Wallet tx model
    _historyTx = widget.transactions.map<_WalletTx>((tx) {
      final int rawAmount = (tx['amount'] as num?)?.toInt() ?? 0;
      final bool isCredit = rawAmount >= 0;

      final String title = tx['title']?.toString() ?? '';
      final String baseSubtitle = tx['subtitle']?.toString() ?? '';
      final String time = tx['time']?.toString() ?? '';

      final String subtitle =
          time.isNotEmpty ? '$baseSubtitle • $time' : baseSubtitle;

      return _WalletTx(
        title: title,
        subtitle: subtitle,
        amount: rawAmount.abs(), // always positive; sign comes from isCredit
        isCredit: isCredit,
        icon: isCredit
            ? Icons.arrow_downward_rounded   // money added
            : Icons.arrow_upward_rounded,    // money deducted
      );
    }).toList();

    
    if (_historyTx.isEmpty) {
      _historyTx.add(
        _WalletTx(
          title: 'No tournament yet',
          subtitle: 'Join a tournament to see transactions here',
          amount: 0,
          isCredit: true,
          icon: Icons.info_outline_rounded,
        ),
      );
    }
  }


  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF020817);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HYPERZONE WALLET',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF232B3E),
              child: Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedTab == WalletTab.addMoney
                  ? _buildAddMoneyTab()
                  : _buildHistoryTab(),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildBalanceCard() {
    const cardBg = LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x661B1F3B),
            blurRadius: 32,
            offset: Offset(0, 16),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _hideBalance
                    ? '₹•••••'
                    : '₹${_walletBalance.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _hideBalance = !_hideBalance;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _hideBalance
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.shield_moon_rounded,
                  size: 16, color: Colors.white70),
              SizedBox(width: 6),
              Text(
                'HyperSafe protection enabled',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTabs() {
    const cardBg = Color(0xFF050B14);
    const highlight = Color(0xFF2563EB);

    Widget buildTab(String label, WalletTab tab, IconData icon) {
      final bool active = _selectedTab == tab;
      return Expanded(
        child: HoverEffect(
          scale: active ? 1.0 : 1.02,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: active ? highlight : cardBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: Color(0x662563EB),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      )
                    ]
                  : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildTab('Add Money', WalletTab.addMoney,
            Icons.add_circle_outline_rounded),
        const SizedBox(width: 12),
        buildTab('History', WalletTab.history, Icons.history_rounded),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ADD MONEY TAB
  // ---------------------------------------------------------------------------

  Widget _buildAddMoneyTab() {
    const sectionBg = Color(0xFF050B14);

    return Container(
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Make a payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Amount row
          _buildAmountRow(),
          const SizedBox(height: 16),

          // Left methods + right content
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 500,
                  child: _buildMethodList(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: _buildMethodContent(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Proceed button – only for Card & NetBanking
          if (_activeMethod != _PaymentMethod.upi)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 44,
                width: 220,
                child: HoverEffect(
                  scale: 1.03,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {
                      // integrate payment gateway later
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.bolt_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Proceed to pay',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF020817),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '200',
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _quickAmountChip('₹500', 500),
        const SizedBox(width: 8),
        _quickAmountChip('₹1000', 1000),
        const SizedBox(width: 8),
        _quickAmountChip('₹2000', 2000),
      ],
    );
  }

  Widget _quickAmountChip(String label, int value) {
    return HoverEffect(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _amountController.text = value.toString();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodList() {
    return Column(
      children: [
        _paymentMethodTile(
          label: 'UPI',
          icon: Icons.qr_code_2,
          method: _PaymentMethod.upi,
        ),
        const SizedBox(height: 8),
        _paymentMethodTile(
          label: 'Card',
          icon: Icons.credit_card_rounded,
          method: _PaymentMethod.card,
        ),
        const SizedBox(height: 8),
        _paymentMethodTile(
          label: 'NetBanking',
          icon: Icons.account_balance_rounded,
          method: _PaymentMethod.netbanking,
        ),
      ],
    );
  }

  Widget _paymentMethodTile({
    required String label,
    required IconData icon,
    required _PaymentMethod method,
  }) {
    final active = _activeMethod == method;

    return HoverEffect(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeMethod = method;
          });
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF111827) : const Color(0xFF020617),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  active ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? const Color(0xFF60A5FA) : Colors.white70),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodContent() {
    switch (_activeMethod) {
      case _PaymentMethod.upi:
        return _buildUpiContent();
      case _PaymentMethod.card:
        return _buildCardContent();
      case _PaymentMethod.netbanking:
        return _buildNetbankingContent();
    }
  }

  Widget _buildUpiContent() {
    final amount =
        _amountController.text.isEmpty ? '0' : _amountController.text;

    return HoverEffect(
      scale: 1.01,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/upi_qr.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scan with any UPI app',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Amount: ₹$amount',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Use Google Pay, PhonePe, Paytm or any UPI app to scan this QR and complete payment.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    final amount =
        _amountController.text.isEmpty ? '0' : _amountController.text;

    return HoverEffect(
      scale: 1.01,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pay with card (₹$amount)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _cardField(label: 'Card number'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _cardField(label: 'MM')),
                const SizedBox(width: 8),
                Expanded(child: _cardField(label: 'YY')),
                const SizedBox(width: 8),
                Expanded(child: _cardField(label: 'CVV', obscure: true)),
              ],
            ),
            const SizedBox(height: 10),
            _cardField(label: 'Card holder name'),
          ],
        ),
      ),
    );
  }

  Widget _cardField({required String label, bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        isDense: true,
      ),
      style: const TextStyle(color: Colors.white, fontSize: 13),
    );
  }

  Widget _buildNetbankingContent() {
    final amount =
        _amountController.text.isEmpty ? '0' : _amountController.text;

    return HoverEffect(
      scale: 1.01,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NetBanking payment (₹$amount)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _cardField(label: 'Bank name'),
            const SizedBox(height: 10),
            _cardField(label: 'Account holder name'),
            const SizedBox(height: 10),
            _cardField(label: 'Account number'),
            const SizedBox(height: 10),
            _cardField(label: 'IFSC code'),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HISTORY TAB
  // ---------------------------------------------------------------------------

  Widget _buildHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All transactions',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildTxList(_historyTx)),
      ],
    );
  }

  Widget _buildTxList(List<_WalletTx> items) {
    const cardBg = Color(0xFF050B14);

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No transactions yet.',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: ScrollConfiguration(
        behavior: const _NoGlowBehavior(),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final tx = items[index];
            final bool isCredit = tx.isCredit;

            final amountText =
                '${isCredit ? '+' : '-'}₹${tx.amount.toString()}';

            final Color amountColor =
                isCredit ? const Color(0xFF2ECC71) : const Color(0xFFFF4D73);

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  hoverColor: Colors.white10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCredit
                                ? const Color(0xFF113822)
                                : const Color(0xFF3A121D),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            tx.icon,
                            size: 18,
                            color: isCredit
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFFF4D73),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tx.subtitle,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          amountText,
                          style: TextStyle(
                            color: amountColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const Divider(
            color: Colors.white12,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// simple tx model
class _WalletTx {
  final String title;
  final String subtitle;
  final int amount;
  final bool isCredit;
  final IconData icon;

  _WalletTx({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.icon,
  });
}

// remove overscroll glow
class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

// simple hover wrapper
class HoverEffect extends StatefulWidget {
  final Widget child;
  final double scale;
  final Color? hoverColor;
  final BorderRadius? borderRadius;

  const HoverEffect({
    Key? key,
    required this.child,
    this.scale = 1.02,
    this.hoverColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(999);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()
          ..scale(_hovered ? widget.scale : 1.0),
        decoration: BoxDecoration(
          color: _hovered && widget.hoverColor != null
              ? widget.hoverColor
              : Colors.transparent,
          borderRadius: radius,
        ),
        child: widget.child,
      ),
    );
  }
}
