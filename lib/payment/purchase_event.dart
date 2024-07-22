part of 'purchase_bloc.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends PurchaseEvent {}

class PurchaseProduct extends PurchaseEvent {
  final String productId;

  const PurchaseProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

class RestorePurchases extends PurchaseEvent {}

class CheckSubscription extends PurchaseEvent {}
