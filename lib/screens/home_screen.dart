import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/currency_cubit.dart';
import '../models/currency.dart';
import '../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fromCurrency = 'USD';
  String toCurrency = 'RUB';
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CurrencyCubit>().fetchCurrencies();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор обмена'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeCubit>().state == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
        ],
      ),
      body: BlocBuilder<CurrencyCubit, CurrencyState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Выберите валюты')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text('Ошибка: $message')),
            loaded: (currencies) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Для того чтобы произвести обмен посмотрите обменный курс или воспользуйтесь калькулятором.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCurrencyButton(
                          currencies,
                          true,
                          context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                        onPressed: _swapCurrencies,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCurrencyButton(
                          currencies,
                          false,
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '1 $fromCurrency = ${((currencies[toCurrency]?.rate ?? 0) / (currencies[fromCurrency]?.rate ?? 1)).toStringAsFixed(3)} $toCurrency',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Введите сумму',
                    ),
                    onChanged: (_) => _convertCurrency(currencies),
                  ),
                  if (_amountController.text.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppTheme.lightSurface
                            : AppTheme.darkSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Итог:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_buildResult(currencies)} $toCurrency',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? AppTheme.primaryColor
                                      : Colors.blue[400],
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyButton(
    Map<String, Currency> currencies,
    bool isFrom,
    BuildContext context,
  ) {
    final currentCurrency = isFrom ? fromCurrency : toCurrency;
    return InkWell(
      onTap: () => _showCurrencyPicker(currencies, isFrom, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.lightSurface
              : AppTheme.darkSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  getCurrencySymbol(currentCurrency),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                Text(
                  getCurrencyName(currentCurrency),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(
    Map<String, Currency> currencies,
    bool isFrom,
    BuildContext context,
  ) {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Выберите валюту',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final code = currencies.keys.elementAt(index);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Text(
                        getCurrencySymbol(code),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      title: Text(
                        getCurrencyName(code),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: Text(
                        code,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        setState(() {
                          if (isFrom) {
                            fromCurrency = code;
                          } else {
                            toCurrency = code;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'Доллар';
      case 'EUR':
        return 'Евро';
      case 'GBP':
        return 'Фунт';
      case 'RUB':
        return 'Рубль';
      case 'AED':
        return 'Дирхам';
      case 'CNY':
        return 'Юань';
      case 'TRY':
        return 'Лира';
      case 'KZT':
        return 'Тенге';
      case 'UAH':
        return 'Гривна';
      case 'BTC':
        return 'Биткоин';
      default:
        return code;
    }
  }

  String getCurrencySymbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'RUB':
        return '₽';
      case 'AED':
        return 'د.إ';
      case 'CNY':
        return '¥';
      case 'TRY':
        return '₺';
      case 'KZT':
        return '₸';
      case 'UAH':
        return '₴';
      case 'BTC':
        return '₿';
      default:
        return code;
    }
  }

  String _buildResult(Map<String, Currency> currencies) {
    if (_amountController.text.isEmpty) return '';

    final amount = double.tryParse(_amountController.text) ?? 0;
    final fromRate = currencies[fromCurrency]?.rate ?? 1;
    final toRate = currencies[toCurrency]?.rate ?? 1;
    final result = amount * (toRate / fromRate);

    return result.toStringAsFixed(2);
  }

  void _convertCurrency(Map<String, Currency> currencies) {
    setState(() {}); // Trigger rebuild to update the result
  }
}
