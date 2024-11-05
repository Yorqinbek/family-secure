import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:soqchi/api/parent_repository.dart';
import 'package:soqchi/bloc/dash/dash_bloc.dart';
import 'package:soqchi/bloc/subscript/subscript_bloc.dart';
import 'package:soqchi/screen/dash.dart';

import '../widgets/loadingwidget.dart';
import '../widgets/server_error.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ParentSubscribePage extends StatefulWidget {
  const ParentSubscribePage({super.key});

  @override
  State<ParentSubscribePage> createState() => _ParentSubscribePageState();
}

class _ParentSubscribePageState extends State<ParentSubscribePage> {

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  List<ProductDetails>? _products;

  List<PurchaseDetails> _purchases = [];

  @override
  void initState(){
    super.initState();
    BlocProvider.of<SubscriptBloc>(context).add(SubscriptLoadingData());
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    });
    _onRefresh();
  }

  @override
  void dispose() {
    super.dispose();
  }




  Future<void> _onRefresh() async {
    BlocProvider.of<SubscriptBloc>(context).add(SubscriptLoadingData());
    setState(() {
      _products = null;
    });
    const Set<String> _kIds = <String>{'monthly','yearly'};
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(_kIds);
    if (response.error != null) {

    }

    setState(() {
      _products = response.productDetails;
    });
    _refreshController.refreshCompleted();
  }
  


  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    _purchases = purchaseDetailsList;
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        final String purchaseToken = purchaseDetails.verificationData.serverVerificationData;
        final String product_id = purchaseDetails.productID;
        await ParentRepository().set_tarif(purchaseToken, product_id);
        Dialogs.materialDialog(

            color: Colors.white,
            msg: AppLocalizations.of(context)!.success_info,
            title: AppLocalizations.of(context)!.success,
            lottieBuilder: Lottie.asset(
              'assets/images/cong_example.json',
              fit: BoxFit.contain,

            ),
            onClose: (a){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                return BlocProvider(
                  create: (ctx) => DashBloc(),
                  child: DashboardPage(),
                );
              }));
            },
            customView: SizedBox(),
            customViewPosition: CustomViewPosition.BEFORE_ACTION,
            context: context,
            actions: [
              IconsButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return BlocProvider(
                      create: (ctx) => DashBloc(),
                      child: DashboardPage(),
                    );
                  }));
                },
                text: 'Ok',
                iconData: Icons.done,
                color: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
                iconColor: Colors.white,
              ),
            ]);
        // add(CheckSubscription());
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // add(CheckSubscription());
      }
      else if (purchaseDetails.status == PurchaseStatus.restored) {
        print("Restart qilindi");
        // add(CheckSubscription());
      }
    }
  }

  Future<void> _onPurchaseProduct(String product_id) async {
    final product = _products!.firstWhere((product) => product.id == product_id);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: BlocBuilder<SubscriptBloc, SubscriptState>(
  builder: (context, state) {
    if(state is SubscriptError){
      return ServerErrorWidget();
    }
    if(state is SubscriptExpired || state is SubscriptSuccess){
      return _products == null ? SizedBox():_products!.isEmpty ? Center(child:Text("Empty")):Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(  AppLocalizations.of(context)!.subsc_title,style: TextStyle(fontSize: 30 ,color: Colors.blue,fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(  AppLocalizations.of(context)!.subsc_subtitle,style: TextStyle(fontSize: 14,color: Colors.black),textAlign:TextAlign.center),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _products!.length,
                itemBuilder: (context, index) {
                  final product = _products![index];
                  return InkWell(
                    onTap: ()async{
                      print(product.id);
                      await _onPurchaseProduct(product.id);

                    },
                    child: Card(
                      margin: EdgeInsets.all(15),
                      color: Colors.blueAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(

                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(Icons.star,size: 50,color: Colors.yellowAccent,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(product.description,style: TextStyle(color: Colors.white,fontSize: 29,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(product.price,style: TextStyle(color: Colors.white,fontSize: 29,fontWeight: FontWeight.bold,fontStyle:FontStyle.italic),),
                            ),
                            SizedBox(height: 10,),

                            // Padding(
                            //   padding: const EdgeInsets.all(15.0),
                            //   child: ListTile(
                            //     title: Text(product.description,style: TextStyle(color: Colors.white),),
                            //     // subtitle: Text(product.description),
                            //     trailing: TextButton(
                            //       child: Text(product.price),
                            //       onPressed: () {
                            //         context
                            //             .read<PurchaseBloc>()
                            //             .add(PurchaseProduct(product.id));
                            //       },
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    return  LoadingWidget();
  },
),
        ),
      );
  }
}
