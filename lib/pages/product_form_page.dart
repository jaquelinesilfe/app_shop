// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:app_shop/models/product_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageURLFocus = FocusNode();
  final _imageURLController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState(); //
    _imageURLFocus.addListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageURLController.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageURLFocus.removeListener(updateImage);
    _imageURLFocus.dispose();
  }

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');
    return isValidUrl && endsWithFile;
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(_formData);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro para salvar o produto'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Produto'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _formData['name']?.toString(),
                        decoration: const InputDecoration(labelText: 'Nome'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocus);
                        },
                        onSaved: (name) => _formData['name'] = name ?? '',
                        validator: (_name) {
                          final name = _name ?? '';

                          if (name.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }

                          if (name.trim().length < 3) {
                            return 'Nome precisa no mínimo 3 letras';
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['price']?.toString(),
                        decoration: const InputDecoration(labelText: 'Preço'),
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocus);
                        },
                        onSaved: (price) =>
                            _formData['price'] = double.parse(price ?? '0'),
                        validator: (_price) {
                          final priceString = _price ?? '';
                          final price = double.tryParse(priceString) ?? -1;

                          if (price <= 0) {
                            return 'Informe um preço válido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['description']?.toString(),
                        decoration:
                            const InputDecoration(labelText: 'Descrição'),
                        focusNode: _descriptionFocus,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        onSaved: (description) =>
                            _formData['description'] = description ?? '',
                        validator: (_description) {
                          final name = _description ?? '';

                          if (name.trim().isEmpty) {
                            return 'Descrição é obrigatório';
                          }

                          if (name.trim().length < 10) {
                            return 'Descrição precisa no mínimo 10 letras';
                          }

                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'URL da Imagem'),
                              focusNode: _imageURLFocus,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageURLController,
                              onFieldSubmitted: (_) => _submitForm(),
                              onSaved: (imageUrl) =>
                                  _formData['imageUrl'] = imageUrl ?? '',
                              validator: (_imageUrl) {
                                final imageUrl = _imageUrl ?? '';
                                if (!isValidImageUrl(imageUrl)) {
                                  return 'Informe uma URL válida';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(
                              right: 10,
                              left: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: _imageURLController.text.isEmpty
                                ? const Text('Informe a URL')
                                : Image.network(_imageURLController.text),
                          )
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
