import 'package:app_shop/exceptions/exceptions_http.dart';
import 'package:app_shop/models/product_list.dart';
import 'package:app_shop/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem(this.product, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.name),
      trailing: SizedBox(
        width: 100,
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.PRODUCT_FORM,
                arguments: product,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Theme.of(context).errorColor,
            onPressed: () {
              showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Excluir Produto'),
                  content: const Text('Tem certeza?'),
                  actions: [
                    TextButton(
                      child: const Text('Sim'),
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                    TextButton(
                      child: const Text('Não'),
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ],
                ),
              ).then((value) async {
                if (value ?? false) {
                  try {
                    await Provider.of<ProductList>(
                      context,
                      listen: false,
                    ).deleteProduct(product);
                  } on HttpException catch (error) {
                    msg.showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                      ),
                    );
                  }
                }
              });
            },
          )
        ]),
      ),
    );
  }
}
