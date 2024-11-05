import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
//import for SKProductWrapper
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/parent_repository.dart';
import '../bloc/dash/dash_bloc.dart';
import '../bloc/subscript/subscript_bloc.dart';
import '../widgets/loadingwidget.dart';
import '../widgets/server_error.dart';
import 'dash.dart';
class AppleSubscriptionPage extends StatefulWidget {
  const AppleSubscriptionPage({super.key});

  @override
  State<AppleSubscriptionPage> createState() => _AppleSubscriptionPageState();
}

class _AppleSubscriptionPageState extends State<AppleSubscriptionPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  List<ProductDetails>? _products;
  final _scrollController = ScrollController();
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

  Future<void> open_website(String url_site) async {
    final Uri _url = Uri.parse(url_site);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }




  Future<void> _onRefresh() async {
    BlocProvider.of<SubscriptBloc>(context).add(SubscriptLoadingData());
    setState(() {
      _products = null;
    });
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      print('In-App Purchases are not available.');
      return;
    }
    else{
      const Set<String> _kIds = <String>{'monthlynew','yearlynew'};
      final ProductDetailsResponse response =
      await _inAppPurchase.queryProductDetails(_kIds);
      if (response.error != null) {
        print("Error bor");
        print(response.toString());
      }
      print(response.notFoundIDs);

      setState(() {
        _products = response.productDetails;
      });
    }
    _refreshController.refreshCompleted();
  }



  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    _purchases = purchaseDetailsList;
    for (var purchaseDetails in purchaseDetailsList) {

      if (purchaseDetails.status == PurchaseStatus.purchased) {
        final String product_id = purchaseDetails.productID;
        final String transactionId = purchaseDetails.purchaseID!;
        print(transactionId);
        bool a = await ParentRepository().set_tarif_apple(transactionId, product_id);
        if(a){
          Dialogs.materialDialog(

              color: Colors.white,
              msg: AppLocalizations.of(context)!.success_info,
              title: AppLocalizations.of(context)!.success,
              lottieBuilder: Lottie.asset(
                'assets/images/cong_example.json',
                fit: BoxFit.contain,
                animate: true,
                repeat: false

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
        }
        else{
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.server_error,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,

              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
        break;
      }
      else if (purchaseDetails.status == PurchaseStatus.error) {
        print("Xatolik qayta urunib ko'ring");
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(  AppLocalizations.of(context)!.subsc_title,style: TextStyle(fontSize: 30 ,color: Colors.blue,fontWeight: FontWeight.bold),),
                      //   ],
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.all(12.0),
                      //   child: Text(  AppLocalizations.of(context)!.subsc_subtitle,style: TextStyle(fontSize: 14,color: Colors.black),textAlign:TextAlign.center),
                      // ),
                      Text("Premium Subscription:",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("- App usage and Block",style: TextStyle(fontSize: 15,fontStyle: FontStyle.italic),),
                          Text("- Sms and Contact information",style: TextStyle(fontSize: 15,fontStyle: FontStyle.italic),),
                          Text("- Location information",style: TextStyle(fontSize: 15,fontStyle: FontStyle.italic),),
                          Text("- Notification and other information from your child",style: TextStyle(fontSize: 15,fontStyle: FontStyle.italic),),
                        ],
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
                              child: Container(
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
                                          child: Icon(Icons.star,size: 20,color: Colors.yellowAccent,),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(product.title,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                        ),
                                        Text(product.description,style: TextStyle(color: Colors.white,fontSize: 20),textAlign: TextAlign.center,),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(product.price,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold,fontStyle:FontStyle.italic),),
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
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          children: [
                            Text("By subscribing to Family Secure, you accept the terms of the ",style: TextStyle(fontSize: 12),),
                            InkWell(child: Text("User Agreement",style: TextStyle(color: Colors.blue,fontSize: 12),),onTap: ()async{
                              await open_website("https://bbpro.me/templates/template31/useragg.html");
                            },),
                            Text(" and the Family Secure ",style: TextStyle(fontSize: 12),),
                            InkWell(child: Text("Privacy Policy",style: TextStyle(color: Colors.blue,fontSize: 12)),onTap: ()async{
                              await open_website("https://bbpro.me/templates/template31/privacy.html");
                            },),
                          ],
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Markdown(
                      //         controller: _scrollController,
                      //         selectable: true,
                      //         styleSheet: MarkdownStyleSheet(
                      //             p: TextStyle(fontSize: 16)
                      //         ),
                      //         data:"By subscribing to Family Secure, you accept the terms of the User Agreement and the Family Secure Privacy Policy.",
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
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
