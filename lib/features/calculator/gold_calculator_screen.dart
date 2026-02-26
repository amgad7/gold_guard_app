import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gold_caurd_app/core/styling/app_colors.dart';
import 'package:gold_caurd_app/core/widgets/spacing_widgets.dart';

import '../home/services/gold_api_service.dart';
import '../home/data/gold_price_model.dart';

class GoldCalculatorScreen extends StatefulWidget {
  const GoldCalculatorScreen({super.key});

  @override
  State<GoldCalculatorScreen> createState() => _GoldCalculatorScreenState();
}

class _GoldCalculatorScreenState extends State<GoldCalculatorScreen> {
  final TextEditingController weightController = TextEditingController();
  final GoldApiService _apiService = GoldApiService();

  String selectedKarat = '24K';
  String selectedCurrency = 'EGP';

  GoldPriceModel? priceUSD;
  GoldPriceModel? priceEGP;

  bool isLoading = true;
  double? result;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    setState(() => isLoading = true);
    try {
      final usd = await _apiService.getGoldPrice('USD');
      final egp = await _apiService.getGoldPrice('EGP');
      setState(() {
        priceUSD = usd;
        priceEGP = egp;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _calculate() {
    final weight = double.tryParse(weightController.text);
    if (weight == null || weight <= 0) return;

    final model = selectedCurrency == 'USD' ? priceUSD : priceEGP;
    if (model == null) return;

    double? pricePerGram;
    switch (selectedKarat) {
      case '21K':
        pricePerGram = model.price21k;
        break;
      case '18K':
        pricePerGram = model.price18k;
        break;
      default:
        pricePerGram = model.priceGram24k;
    }

    if (pricePerGram == null) return;

    setState(() {
      result = weight * pricePerGram!;
    });
  }

  double? _getCurrentPrice() {
    final model = selectedCurrency == 'USD' ? priceUSD : priceEGP;
    if (model == null) return null;
    switch (selectedKarat) {
      case '21K':
        return model.price21k;
      case '18K':
        return model.price18k;
      default:
        return model.priceGram24k;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Gold Calculator',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadPrices,
            icon: Icon(Icons.refresh, color: AppColors.primaryColor),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withValues(alpha: 0.2),
                          AppColors.secondaryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          color: AppColors.primaryColor,
                          size: 40.sp,
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calculate Gold Value',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Enter weight to calculate current value',
                                style: TextStyle(
                                  color: AppColors.secondaryColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  HeightSpace(25),

                  // Karat Selector
                  Text(
                    'Select Karat',
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  HeightSpace(10),
                  Row(
                    children: ['24K', '21K', '18K'].map((karat) {
                      final isSelected = selectedKarat == karat;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedKarat = karat;
                              result = null;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey[900],
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.secondaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                karat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  HeightSpace(20),

                  // Currency Selector
                  Text(
                    'Select Currency',
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  HeightSpace(10),
                  Row(
                    children: [
                      _buildCurrencyButton('EGP', '🇪🇬'),
                      SizedBox(width: 10.w),
                      _buildCurrencyButton('USD', '🇺🇸'),
                    ],
                  ),
                  HeightSpace(20),

                  // Current Price Info
                  if (_getCurrentPrice() != null)
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current $selectedKarat price:',
                            style: TextStyle(
                              color: AppColors.secondaryColor,
                              fontSize: 13.sp,
                            ),
                          ),
                          Text(
                            '${_getCurrentPrice()!.toStringAsFixed(2)} $selectedCurrency/g',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  HeightSpace(20),

                  // Weight Input
                  Text(
                    'Weight (grams)',
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  HeightSpace(10),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                    onChanged: (_) => _calculate(),
                    decoration: InputDecoration(
                      hintText: 'Enter weight in grams',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      prefixIcon: Icon(
                        Icons.scale,
                        color: AppColors.primaryColor,
                      ),
                      suffixText: 'g',
                      suffixStyle: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondaryColor),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                  HeightSpace(25),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      child: Text(
                        'Calculate',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  HeightSpace(25),

                  // Result
                  if (result != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(25.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.15),
                            AppColors.secondaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Estimated Value',
                            style: TextStyle(
                              color: AppColors.secondaryColor,
                              fontSize: 14.sp,
                            ),
                          ),
                          HeightSpace(10),
                          Text(
                            '${result!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            selectedCurrency,
                            style: TextStyle(
                              color: AppColors.secondaryColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          HeightSpace(15),
                          Divider(
                            color: AppColors.secondaryColor.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          HeightSpace(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildResultDetail(
                                'Weight',
                                '${weightController.text} g',
                              ),
                              _buildResultDetail('Karat', selectedKarat),
                              _buildResultDetail(
                                'Price/g',
                                '${_getCurrentPrice()?.toStringAsFixed(2) ?? '0'}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrencyButton(String currency, String flag) {
    final isSelected = selectedCurrency == currency;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCurrency = currency;
            result = null;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.grey[900],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.secondaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              '$flag $currency',
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.secondaryColor, fontSize: 11.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
