import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  List<ProductDetails> _products = [];

  List<PurchaseDetails> _purchases = [];

  PurchaseBloc() : super(PurchaseInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<CheckSubscription>(_onCheckSubscription);


    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    });

  }



  void _onLoadProducts(LoadProducts event, Emitter<PurchaseState> emit) async {
    emit(PurchaseLoading());

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      emit(const PurchaseError('Store is unavailable.'));
      return;
    }

    const Set<String> _kIds = <String>{'monthly','yearly'};
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(_kIds);
    if (response.error != null) {
      emit(PurchaseError(response.error!.message!));
      return;
    }

    _products = response.productDetails;


    // print(_products.first.description.toString());

    emit(PurchaseLoaded(_products));
  }

  void _onPurchaseProduct(
      PurchaseProduct event, Emitter<PurchaseState> emit) async {
    final product = _products.firstWhere((product) => product.id == event.productId);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onRestorePurchases(
      RestorePurchases event, Emitter<PurchaseState> emit) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    _inAppPurchase.restorePurchases(applicationUserName: appName);
  }

  // void _onCheckSubscription(
  //     CheckSubscription event, Emitter<PurchaseState> emit) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final bool isSubscribed = prefs.getBool('is_subscribed') ?? false;
  //
  //   if (isSubscribed) {
  //     emit(SubscriptionActive());
  //   } else {
  //     emit(SubscriptionInactive());
  //   }
  // }

  void _onCheckSubscription(
      CheckSubscription event, Emitter<PurchaseState> emit) {
    final bool isSubscribed = _purchases.any((purchase) =>
    purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored);
    if (isSubscribed) {
      emit(SubscriptionActive());
    } else {
      // add(LoadProducts());
      // emit(SubscriptionInactive());
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    _purchases = purchaseDetailsList;
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_subscribed', true);
        final String purchaseToken = purchaseDetails.verificationData.serverVerificationData;
        final String product_id = purchaseDetails.productID;
        print("purchaseToken:"+purchaseToken);
        print("product_id:"+product_id);
        add(CheckSubscription());
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        add(CheckSubscription());
      }
      else if (purchaseDetails.status == PurchaseStatus.restored) {
        print("Restart qilindi");
        add(CheckSubscription());
      }
    }
  }

  // @override
  // Future<void> close() {
  //   _inAppPurchase.purchaseStream.cancel();
  //   return super.close();
  // }
}