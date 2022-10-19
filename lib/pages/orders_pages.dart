import 'package:app_shop/components/app_drawer.dart';
import 'package:app_shop/components/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_list.dart';

class OrdersPages extends StatefulWidget {
  const OrdersPages({Key? key}) : super(key: key);

  @override
  State<OrdersPages> createState() => _OrdersPagesState();
}

class _OrdersPagesState extends State<OrdersPages> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<OrderList>(context, listen: false).loadOrders().then((_) {
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final OrderList orders = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus pedidos'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.itemsCount,
              itemBuilder: (ctx, i) => OrderWidget(order: orders.items[i]),
            ),
    );
  }
}
