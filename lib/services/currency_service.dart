import 'dart:io';
import 'package:flutter/material.dart';

/// Service de gestion des devises et prix internationaux
class CurrencyService {
  // Prix de base en euros
  static const double _baseMonthlyPriceEUR = 2.99;
  static const double _baseLifetimePriceEUR = 24.99;
  
  // Taux de change approximatifs (dans une vraie app, utiliser une API)
  static const Map<String, CurrencyInfo> _currencies = {
    'EUR': CurrencyInfo('€', 1.0, 'EUR'),
    'USD': CurrencyInfo('\$', 1.12, 'USD'),
    'GBP': CurrencyInfo('£', 0.85, 'GBP'),
    'CAD': CurrencyInfo('C\$', 1.50, 'CAD'),
    'CHF': CurrencyInfo('CHF', 1.08, 'CHF'),
    'JPY': CurrencyInfo('¥', 160.0, 'JPY'),
    'CNY': CurrencyInfo('¥', 8.0, 'CNY'),
    'BRL': CurrencyInfo('R\$', 5.50, 'BRL'),
    'MXN': CurrencyInfo('\$', 19.0, 'MXN'),
    'INR': CurrencyInfo('₹', 93.0, 'INR'),
    'KRW': CurrencyInfo('₩', 1480.0, 'KRW'),
    'AUD': CurrencyInfo('A\$', 1.65, 'AUD'),
    'NZD': CurrencyInfo('NZ\$', 1.80, 'NZD'),
    'SGD': CurrencyInfo('S\$', 1.50, 'SGD'),
    'HKD': CurrencyInfo('HK\$', 8.80, 'HKD'),
    'NOK': CurrencyInfo('kr', 12.0, 'NOK'),
    'SEK': CurrencyInfo('kr', 11.5, 'SEK'),
    'DKK': CurrencyInfo('kr', 7.45, 'DKK'),
    'PLN': CurrencyInfo('zł', 4.35, 'PLN'),
    'CZK': CurrencyInfo('Kč', 25.0, 'CZK'),
    'RUB': CurrencyInfo('₽', 100.0, 'RUB'),
    'TRY': CurrencyInfo('₺', 32.0, 'TRY'),
    'ZAR': CurrencyInfo('R', 20.5, 'ZAR'),
    'AED': CurrencyInfo('د.إ', 4.12, 'AED'),
    'SAR': CurrencyInfo('ر.س', 4.20, 'SAR'),
    'EGP': CurrencyInfo('ج.م', 50.0, 'EGP'),
    'NGN': CurrencyInfo('₦', 1400.0, 'NGN'),
    'KES': CurrencyInfo('KSh', 150.0, 'KES'),
    'MAD': CurrencyInfo('د.م.', 11.0, 'MAD'),
    'TND': CurrencyInfo('د.ت', 3.40, 'TND'),
    'DZD': CurrencyInfo('د.ج', 150.0, 'DZD'),
  };
  
  /// Détecte automatiquement la devise selon la locale du système
  static CurrencyInfo getLocalCurrency() {
    try {
      // Obtenir la locale du système
      final locale = Platform.localeName;
      final countryCode = locale.split('_').length > 1 ? locale.split('_')[1] : '';
      
      // Mapper les codes pays vers les devises
      final currencyCode = _getCountryCurrency(countryCode);
      return _currencies[currencyCode] ?? _currencies['EUR']!;
    } catch (e) {
      // Fallback sur EUR en cas d'erreur
      return _currencies['EUR']!;
    }
  }
  
  /// Calcule le prix mensuel dans la devise locale
  static PricingInfo getMonthlyPrice([CurrencyInfo? currency]) {
    currency ??= getLocalCurrency();
    double price = _baseMonthlyPriceEUR * currency.exchangeRate;
    
    // Arrondir selon la devise
    if (currency.code == 'JPY' || currency.code == 'KRW') {
      price = price.round().toDouble();
    } else {
      price = (price * 100).round() / 100;
    }
    
    return PricingInfo(
      price: price,
      currency: currency,
      isLifetime: false,
      displayPrice: _formatPrice(price, currency),
      description: _getMonthlyDescription(currency.code),
    );
  }
  
  /// Calcule le prix à vie dans la devise locale
  static PricingInfo getLifetimePrice([CurrencyInfo? currency]) {
    currency ??= getLocalCurrency();
    double price = _baseLifetimePriceEUR * currency.exchangeRate;
    
    // Arrondir selon la devise
    if (currency.code == 'JPY' || currency.code == 'KRW') {
      price = price.round().toDouble();
    } else {
      price = (price * 100).round() / 100;
    }
    
    return PricingInfo(
      price: price,
      currency: currency,
      isLifetime: true,
      displayPrice: _formatPrice(price, currency),
      description: _getLifetimeDescription(currency.code),
    );
  }
  
  /// Obtient toutes les devises disponibles
  static List<CurrencyInfo> getAllCurrencies() {
    return _currencies.values.toList()..sort((a, b) => a.code.compareTo(b.code));
  }
  
  /// Obtient les deux options de prix pour une devise donnée
  static PricingOptions getPricingOptions([CurrencyInfo? currency]) {
    currency ??= getLocalCurrency();
    return PricingOptions(
      monthly: getMonthlyPrice(currency),
      lifetime: getLifetimePrice(currency),
    );
  }
  
  static String _formatPrice(double price, CurrencyInfo currency) {
    if (currency.code == 'JPY' || currency.code == 'KRW') {
      return '${currency.symbol}${price.toInt()}';
    }
    return '${currency.symbol}${price.toStringAsFixed(2)}';
  }
  
  static String _getMonthlyDescription(String currencyCode) {
    switch (currencyCode) {
      case 'EUR': return 'par mois';
      case 'USD': case 'CAD': case 'AUD': case 'NZD': case 'SGD': case 'HKD': 
        return 'per month';
      case 'GBP': return 'per month';
      case 'JPY': return '月額';
      case 'CNY': return '每月';
      case 'KRW': return '월';
      case 'BRL': return 'por mês';
      case 'MXN': return 'por mes';
      case 'INR': return 'प्रति माह';
      case 'AED': case 'SAR': return 'في الشهر';
      case 'RUB': return 'в месяц';
      case 'TRY': return 'aylık';
      default: return 'per month';
    }
  }
  
  static String _getLifetimeDescription(String currencyCode) {
    switch (currencyCode) {
      case 'EUR': return 'achat unique';
      case 'USD': case 'CAD': case 'AUD': case 'NZD': case 'SGD': case 'HKD': 
        return 'one-time purchase';
      case 'GBP': return 'one-time purchase';
      case 'JPY': return '買い切り';
      case 'CNY': return '一次性购买';
      case 'KRW': return '평생 이용';
      case 'BRL': return 'compra única';
      case 'MXN': return 'compra única';
      case 'INR': return 'एकमुश्त खरीदारी';
      case 'AED': case 'SAR': return 'شراء لمرة واحدة';
      case 'RUB': return 'разовая покупка';
      case 'TRY': return 'tek seferlik satın alma';
      default: return 'one-time purchase';
    }
  }
  
  static String _getCountryCurrency(String countryCode) {
    const countryToCurrency = {
      'US': 'USD', 'CA': 'CAD', 'GB': 'GBP', 'AU': 'AUD', 'NZ': 'NZD',
      'JP': 'JPY', 'CN': 'CNY', 'KR': 'KRW', 'IN': 'INR', 'BR': 'BRL',
      'MX': 'MXN', 'CH': 'CHF', 'SG': 'SGD', 'HK': 'HKD', 'NO': 'NOK',
      'SE': 'SEK', 'DK': 'DKK', 'PL': 'PLN', 'CZ': 'CZK', 'RU': 'RUB',
      'TR': 'TRY', 'ZA': 'ZAR', 'AE': 'AED', 'SA': 'SAR', 'EG': 'EGP',
      'NG': 'NGN', 'KE': 'KES', 'MA': 'MAD', 'TN': 'TND', 'DZ': 'DZD',
      // Pays de la zone Euro
      'DE': 'EUR', 'FR': 'EUR', 'IT': 'EUR', 'ES': 'EUR', 'NL': 'EUR',
      'BE': 'EUR', 'AT': 'EUR', 'PT': 'EUR', 'IE': 'EUR', 'FI': 'EUR',
      'GR': 'EUR', 'LU': 'EUR', 'SI': 'EUR', 'SK': 'EUR', 'EE': 'EUR',
      'LV': 'EUR', 'LT': 'EUR', 'CY': 'EUR', 'MT': 'EUR', 'HR': 'EUR',
    };
    
    return countryToCurrency[countryCode] ?? 'EUR';
  }
}

/// Informations sur une devise
class CurrencyInfo {
  final String symbol;
  final double exchangeRate;
  final String code;
  
  const CurrencyInfo(this.symbol, this.exchangeRate, this.code);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyInfo && other.code == code;
  
  @override
  int get hashCode => code.hashCode;
  
  @override
  String toString() => '$code ($symbol)';
}

/// Informations de prix
class PricingInfo {
  final double price;
  final CurrencyInfo currency;
  final bool isLifetime;
  final String displayPrice;
  final String description;
  
  const PricingInfo({
    required this.price,
    required this.currency,
    required this.isLifetime,
    required this.displayPrice,
    required this.description,
  });
  
  String get fullDescription => '$displayPrice $description';
}

/// Options de prix (mensuel + à vie)
class PricingOptions {
  final PricingInfo monthly;
  final PricingInfo lifetime;
  
  const PricingOptions({
    required this.monthly,
    required this.lifetime,
  });
  
  /// Calcule les économies avec l'achat à vie (en mois)
  double get savingsInMonths => lifetime.price / monthly.price;
  
  /// Obtient le message d'économies
  String getSavingsMessage(bool isFrench) {
    final months = savingsInMonths.round();
    if (isFrench) {
      return 'Économisez ${(months - 12)} mois !';
    } else {
      return 'Save ${(months - 12)} months!';
    }
  }
}