import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soqchi/screen/payment_type.dart';

import '../bloc/subscript/subscript_bloc.dart';
import '../payment/purchase_bloc.dart';
import '../screen/subscription.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpgradeWidget extends StatefulWidget {
  const UpgradeWidget({super.key});

  @override
  State<UpgradeWidget> createState() => _UpgradeWidgetState();
}

class _UpgradeWidgetState extends State<UpgradeWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.free_subsr_over,style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),
          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
          Icon(Icons.lock,color: Colors.red,size: 70,),
          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(14))
            ),
            margin: EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width*0.4,
            child: TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BlocProvider(
                      create: (ctx) => SubscriptBloc(),
                      child: PaymentType(
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
                child: Text(AppLocalizations.of(context)!.update,style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
            ),
          )
        ],
      ),
    );
  }
}
