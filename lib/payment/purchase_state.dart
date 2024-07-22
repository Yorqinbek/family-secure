part of 'purchase_bloc.dart';

abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object> get props => [];
}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseLoaded extends PurchaseState {
  final List<ProductDetails> products;

  const PurchaseLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class PurchaseError extends PurchaseState {
  final String message;

  const PurchaseError(this.message);

  @override
  List<Object> get props => [message];
}

class PurchaseCompleted extends PurchaseState {}

class SubscriptionActive extends PurchaseState {}

class SubscriptionInactive extends PurchaseState {}

