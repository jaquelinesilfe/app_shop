import 'package:app_shop/components/app_drawer.dart';
import 'package:app_shop/components/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_list.dart';

class OrdersPages extends StatelessWidget {
  const OrdersPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderList orders = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus pedidos'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: orders.itemsCount,
        itemBuilder: (ctx, i) => OrderWidget(order: orders.items[i]),
      ),
    );
  }
}
