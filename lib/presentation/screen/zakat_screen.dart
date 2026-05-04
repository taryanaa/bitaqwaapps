import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bittaqwa/utils/color_constant.dart';
import 'package:flutter_bittaqwa/presentation/widgets/card_result_harta.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> with SingleTickerProviderStateMixin {
  final MoneyMaskedTextController controllerRupiah = MoneyMaskedTextController(
    thousandSeparator: '',
    precision: 0,
    decimalSeparator: '',
  );
  
  double totalHarta = 0;
  double zakatDikeluarkan = 0;
  final double minimumHarta = 85000000;
  bool isCalculated = false;
  bool isLoading = false;

  String formattedTotalHarta = '';
  String formattedZakatDikeluarkan = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controllerRupiah.dispose();
    super.dispose();
  }

  void hitungZakat() async {
    // Hapus focus dari text field
    FocusScope.of(context).unfocus();
    
    String cleanValue = controllerRupiah.text.replaceAll('.', '');
    double inputValue = double.tryParse(cleanValue) ?? 0;

    if (inputValue >= minimumHarta) {
      setState(() {
        isLoading = true;
      });

      // Simulasi loading untuk efek yang lebih smooth
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        totalHarta = inputValue;
        zakatDikeluarkan = (inputValue * 2.5) / 100;
        isCalculated = true;
        isLoading = false;
      });

      formattedTotalHarta = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
      ).format(totalHarta);
      
      formattedZakatDikeluarkan = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
      ).format(zakatDikeluarkan);

      // Trigger animasi
      _animationController.forward(from: 0);

      // Haptic feedback
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('Peringatan'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total harta belum mencapai nisab (85gr emas)'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Minimum: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(minimumHarta)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('OKE'),
            ),
          ],
        ),
      );
    }
  }

  void resetForm() {
    setState(() {
      controllerRupiah.text = '';
      totalHarta = 0;
      zakatDikeluarkan = 0;
      isCalculated = false;
    });
    _animationController.reverse();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    String formattedTotalHarta = controllerRupiah.text.replaceAll('.', ',');
    String formattedZakatDikeluarkan = zakatDikeluarkan
        .toStringAsFixed(0)
        .replaceAll('.', ',');

    Widget cardHarta() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: ColorConstant.colorPrimary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorConstant.colorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: ColorConstant.colorPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Total Harta",
                    style: TextStyle(
                      color: ColorConstant.colorText,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontFamily: "PoppinsMedium",
                    ),
                  ),
                ),
                if (isCalculated)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: resetForm,
                    color: ColorConstant.colorPrimary,
                    tooltip: 'Reset',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controllerRupiah,
              keyboardType: TextInputType.number,
              enabled: !isLoading,
              onChanged: (value) {
                // Reset hasil ketika user mengetik ulang
                if (isCalculated) {
                  setState(() {
                    isCalculated = false;
                  });
                  _animationController.reverse();
                }
              },
              decoration: InputDecoration(
                labelText: 'Masukkan Total Harta',
                labelStyle: TextStyle(
                  color: ColorConstant.colorText.withOpacity(0.7),
                  fontSize: 14,
                ),
                hintText: '0',
                fillColor: Colors.grey[50],
                filled: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(
                    'Rp',
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorConstant.colorText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: ColorConstant.colorPrimary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: ColorConstant.colorPrimary,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nisab minimal: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(minimumHarta)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                        fontFamily: "PoppinsMedium",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                onPressed: isLoading ? null : hitungZakat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstant.colorPrimary,
                  disabledBackgroundColor: ColorConstant.colorPrimary.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size(double.infinity, 0),
                  elevation: isLoading ? 0 : 2,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorConstant.colorWhite,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hitung Zakat",
                            style: TextStyle(
                              color: ColorConstant.colorWhite,
                              fontSize: 16,
                              fontFamily: "PoppinsMedium",
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calculate_outlined,
                            color: ColorConstant.colorWhite,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    }

    Widget cardResult(
      String formattedTotalHarta,
      String formattedZakatDikeluarkan,
    ) {
      if (!isCalculated) return const SizedBox.shrink();

      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorConstant.colorPrimary.withOpacity(0.1),
                        ColorConstant.colorPrimary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Perhitungan berhasil!',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "PoppinsMedium",
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                isSmallScreen
                    ? Column(
                        children: [
                          CardResultHarta(
                            title: "Total Uang",
                            result: "Rp. $formattedTotalHarta",
                            color: Colors.red[300]!,
                          ),
                          const SizedBox(height: 16),
                          CardResultHarta(
                            title: "Zakat Yang dikeluarkan",
                            result: "Rp. $formattedZakatDikeluarkan",
                            color: Colors.purple[300]!,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CardResultHarta(
                              title: "Total Uang",
                              result: "Rp. $formattedTotalHarta",
                              color: Colors.red[300]!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CardResultHarta(
                              title: "Zakat Yang dikeluarkan",
                              result: "Rp. $formattedZakatDikeluarkan",
                              color: Colors.purple[300]!,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorPrimary,
        elevation: 0,
        title: Text(
          'Kalkulator Zakat',
          style: TextStyle(
            color: ColorConstant.colorWhite,
            fontFamily: "PoppinsMedium",
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: ColorConstant.colorWhite,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Hero(
            tag: 'zakat_header',
            child: Image.asset(
              'assets/images/bg_header_zakat.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          cardHarta(),
          const SizedBox(height: 32),
          cardResult(formattedTotalHarta, formattedZakatDikeluarkan),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}