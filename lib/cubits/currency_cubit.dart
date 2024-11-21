import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

part 'currency_cubit.freezed.dart';

@freezed
class CurrencyState with _$CurrencyState {
  const factory CurrencyState.initial() = _Initial;
  const factory CurrencyState.loading() = _Loading;
  const factory CurrencyState.loaded(Map<String, Currency> currencies) = _Loaded;
  const factory CurrencyState.error(String message) = _Error;
}

class CurrencyCubit extends Cubit<CurrencyState> {
  final CurrencyService _service;

  CurrencyCubit(this._service) : super(const CurrencyState.initial());

  Future<void> fetchCurrencies() async {
    emit(const CurrencyState.loading());
    try {
      final currencies = await _service.fetchCurrencies();
      emit(CurrencyState.loaded(currencies));
    } catch (e) {
      emit(CurrencyState.error(e.toString()));
    }
  }
}
