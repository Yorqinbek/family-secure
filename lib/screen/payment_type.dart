import 'dart:io';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:soqchi/bloc/subscript/subscript_bloc.dart';
import 'package:soqchi/screen/apple_subscription.dart';
import 'package:soqchi/screen/payment_type2.dart';
import 'package:soqchi/screen/subscription.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/dash/dash_bloc.dart';
import '../payment/purchase_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/loadingwidget.dart';
import '../widgets/server_error.dart';
class PaymentType extends StatefulWidget {
  const PaymentType({super.key});

  @override
  State<PaymentType> createState() => _PaymentTypeState();
}

class _PaymentTypeState extends State<PaymentType> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  @override
  void initState(){
    super.initState();
    BlocProvider.of<SubscriptBloc>(context).add(SubscriptLoadingData());
  }

  Future<void> open_admin() async {
    final Uri _url = Uri.parse('https://t.me/family_secure_admin');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<SubscriptBloc>(context).add(SubscriptLoadingData());
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text(AppLocalizations.of(context)!.payment_title),
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
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
        child: BlocBuilder<SubscriptBloc, SubscriptState>(
        builder: (context, state) {
      if (state is SubscriptSuccess) {
        return Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.08,),
              Icon(Icons.check_circle_outline_sharp,size: 120,color: Colors.blue,),
              SizedBox(height: MediaQuery.of(context).size.height*0.08,),
              Text(AppLocalizations.of(context)!.sub_active_text,style: TextStyle(color: Colors.black,fontSize: 29,fontWeight: FontWeight.bold),),
              SizedBox(height: MediaQuery.of(context).size.height*0.08,),
              // Card(
              //   margin: EdgeInsets.all(15),
              //   color: Colors.blueAccent,
              //   child: Column(
              //
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.all(10.0),
              //         child: Text("Plan: Monthly",style: TextStyle(color: Colors.white,fontSize: 29,fontWeight: FontWeight.bold),),
              //       ),
              //       SizedBox(height: 10,),
              //
              //       // Padding(
              //       //   padding: const EdgeInsets.all(15.0),
              //       //   child: ListTile(
              //       //     title: Text(product.description,style: TextStyle(color: Colors.white),),
              //       //     // subtitle: Text(product.description),
              //       //     trailing: TextButton(
              //       //       child: Text(product.price),
              //       //       onPressed: () {
              //       //         context
              //       //             .read<PurchaseBloc>()
              //       //             .add(PurchaseProduct(product.id));
              //       //       },
              //       //     ),
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.check_circle_sharp,size: 35,color: Colors.blue,),
                      SizedBox(height: 10,),
                      Text( state.userModel.user!.tarif == 1
                          ? "Monthly"
                          : state.userModel.user!.tarif == 2
                          ? "Yearly"
                          : "Free",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      Text(AppLocalizations.of(context)!.tarif,style: TextStyle(fontSize: 20,color: Colors.grey)),

                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.info,size: 35,color: Colors.amber,),
                      SizedBox(height: 10,),
                      Text(state.userModel.user!.expTime.toString()+AppLocalizations.of(context)!.kun,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      Text(AppLocalizations.of(context)!.validaty,style: TextStyle(fontSize: 20,color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.1,),
              TextButton(
                  style: ButtonStyle(

                    backgroundColor: MaterialStateProperty.all(
                        Colors.blueAccent)
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return BlocProvider(
                        create: (ctx) => SubscriptBloc(),
                        child: PaymentType2(
                        ),
                      );
                    }));
                    // Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //   return PaymentType();
                    // }));
                    // Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //   return BlocProvider(
                    //     create: (ctx) => PurchaseBloc(),
                    //     child: ParentSubscribePage(
                    //       // childuid: widget.childuid,
                    //     ),
                    //   );
                    // }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50,right: 50),
                    child: Text(AppLocalizations.of(context)!.update,style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
                  )
              ),
              // Padding(
              //   padding: const EdgeInsets.all(12.0),
              //   child: Divider(color: Colors.blue,),
              // ),
              // SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              // Flex(
              //   direction: Axis.horizontal,
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     Column(
              //       children: [
              //         Icon(Icons.check_circle_sharp,size: 35,color: Colors.blue,),
              //         SizedBox(height: 10,),
              //         Text("Monthly",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              //         SizedBox(height: 10,),
              //         Text("Plan",style: TextStyle(fontSize: 20,color: Colors.grey)),
              //
              //       ],
              //     ),
              //     Column(
              //       children: [
              //         Icon(Icons.date_range,size: 35,color: Colors.blue,),
              //         SizedBox(height: 10,),
              //         Text("30 kun",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              //         SizedBox(height: 10,),
              //         Text("validity period",style: TextStyle(fontSize: 20,color: Colors.grey)),
              //       ],
              //     ),
              //   ],
              // )
            ],
          ),
        );
      }
      if(state is SubscriptError){
        return ServerErrorWidget();
      }
      if(state is SubscriptExpired){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.04,),
            Platform.isAndroid?Text(AppLocalizations.of(context)!.payment_method,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),):SizedBox(),
            Platform.isAndroid?Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(AppLocalizations.of(context)!.payment_info,style: TextStyle(fontSize: 16),textAlign: TextAlign.center,),
            ):SizedBox(),
            SizedBox(height: MediaQuery.of(context).size.height*0.18,),
            Platform.isAndroid?InkWell(
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BlocProvider(
                    create: (ctx) => SubscriptBloc(),
                    child: ParentSubscribePage(
                    ),
                  );
                }));
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.black,size: 20,),

                  title: Text(AppLocalizations.of(context)!.payment_google, style: TextStyle(
                      color:  Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),),
                  leading:  Image.asset('assets/images/google.png',width: MediaQuery.of(context).size.width*0.08,),
                ),
              ),
            ):SizedBox(),
            SizedBox(height: MediaQuery.of(context).size.height*0.015,),
            Platform.isIOS?InkWell(
              onTap: () async {
                // Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return BlocProvider(
                //     create: (ctx) => PurchaseBloc(),
                //     child: ParentSubscribePage(
                //       // childuid: widget.childuid,
                //     ),
                //   );
                // }));

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BlocProvider(
                    create: (ctx) => SubscriptBloc(),
                    child: AppleSubscriptionPage(
                    ),
                  );
                }));
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.black,size: 20,),

                  title: Text(AppLocalizations.of(context)!.payment_apple, style: TextStyle(
                      color:  Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),),
                  // leading: Icon(Icons.apple,color: Colors.black,size: MediaQuery.of(context).size.width*0.08,),
                  // leading:  Image.asset('assets/images/google.png',width: MediaQuery.of(context).size.width*0.08,),
                ),
              ),
            ):SizedBox(),
            SizedBox(height: MediaQuery.of(context).size.height*0.015,),
            Platform.isAndroid ? InkWell(
              onTap: () async {
                await open_admin();
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  // tileColor:  Colors.blueAccent,
                  title: Text(AppLocalizations.of(context)!.payment_another, style: TextStyle(
                      color:  Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),),
                  leading: Icon(Icons.monetization_on_outlined,color: Colors.blue,size: MediaQuery.of(context).size.width*0.08,),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.black,size: 20,),

                ),
              ),
            ):SizedBox(),
          ],
        );
      }

      return  LoadingWidget();
        },
),
        ),
      ),
    );
  }
}
