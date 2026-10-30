import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../cart/models/cart_item.dart';
import '../../../cart/presentation/widgets/price_summary.dart';
import '../../../cart/provider/cart_provider.dart';
import '../../../payment/models/payment_result.dart';
import '../../models/payment_method.dart';
import '../../models/shipping_address.dart';
import '../../provider/order_provider.dart';
import '../widgets/payment_method_tile.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressKey = GlobalKey();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    final initial = context.read<OrderProvider>().addressFor(user);
    _nameController = TextEditingController(text: initial.fullName);
    _phoneController = TextEditingController(text: initial.phone);
    _addressController = TextEditingController(text: initial.address);
    _cityController = TextEditingController(text: initial.city);
    _postalController = TextEditingController(text: initial.postalCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  ShippingAddress get _address => ShippingAddress(
    fullName: _nameController.text.trim(),
    phone: _phoneController.text.replaceAll(RegExp(r'[\s-]'), ''),
    address: _addressController.text.trim(),
    city: _cityController.text.trim(),
    postalCode: _postalController.text.trim(),
  );

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      // Show errors as the user types from now on, and bring the
      // address form into view so the highlighted field is visible.
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      final addressContext = _addressKey.currentContext;
      if (addressContext != null) {
        Scrollable.ensureVisible(
          addressContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
      _showMessage('Please check your delivery details.', isError: true);
      return;
    }

    final user = context.read<AuthProvider>().user;
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    if (user == null || cart.isEmpty) return;

    final address = _address;
    String? transactionId;

    // 1. Online payment first: only paid orders are placed.
    if (orders.paymentMethod.isOnline) {
      final session = await orders.startOnlinePayment(
        amount: cart.total,
        address: address,
        user: user,
        itemCount: cart.itemCount,
      );
      if (!mounted) return;
      if (session == null) {
        _showMessage(
          orders.checkoutError ?? 'Could not open the payment page.',
          isError: true,
        );
        return;
      }

      final result = await context.push<PaymentResult>(
        AppRouter.payment,
        extra: session,
      );
      if (!mounted) return;
      if (result == null || !result.isSuccess) {
        _showMessage(
          result?.outcome == PaymentOutcome.failed
              ? 'Payment failed. You have not been charged.'
              : 'Payment cancelled.',
          isError: true,
        );
        return;
      }
      transactionId = result.transactionId;
    }

    // 2. Save the order.
    final order = await orders.placeOrder(
      user: user,
      items: cart.items,
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      total: cart.total,
      address: address,
      transactionId: transactionId,
    );
    if (!mounted) return;

    if (order == null) {
      _showMessage(
        orders.checkoutError ?? 'Could not place your order.',
        isError: true,
      );
      return;
    }

    // 3. Show the confirmation, then empty the cart.
    context.go(AppRouter.orderSuccess(order.id));
    await cart.clear();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrderProvider>();

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: StateMessage(
          icon: Icons.shopping_bag_outlined,
          title: 'Nothing to check out',
          message: 'Your cart is empty.',
          actionLabel: 'Browse products',
          onAction: () => context.go(AppRouter.home),
        ),
      );
    }

    final addressSection = SectionCard(
      key: _addressKey,
      title: 'Delivery address',
      icon: Icons.location_on_outlined,
      child: _AddressForm(
        nameController: _nameController,
        phoneController: _phoneController,
        addressController: _addressController,
        cityController: _cityController,
        postalController: _postalController,
      ),
    );

    final paymentSection = SectionCard(
      title: 'Payment method',
      icon: Icons.payment_outlined,
      child: Column(
        children: [
          for (final method in PaymentMethod.values) ...[
            PaymentMethodTile(
              method: method,
              selected: orders.paymentMethod == method,
              onSelected: orders.isBusy ? null : orders.selectPaymentMethod,
            ),
            if (method != PaymentMethod.values.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );

    final summarySection = SectionCard(
      title: 'Order summary',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          for (final item in cart.items) _SummaryLine(item: item),
          const Divider(height: 24),
          PriceSummary(
            itemCount: cart.itemCount,
            subtotal: cart.subtotal,
            deliveryFee: cart.deliveryFee,
            total: cart.total,
          ),
          const SizedBox(height: 16),
          LoadingButton(
            icon: orders.paymentMethod.isOnline
                ? Icons.lock_outline
                : Icons.check_circle_outline,
            label: orders.paymentMethod.isOnline
                ? 'Pay ${Formatters.price(cart.total)}'
                : 'Place order',
            isLoading: orders.isBusy,
            onPressed: _placeOrder,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              addressSection,
                              const SizedBox(height: 16),
                              paymentSection,
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 400,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                          child: summarySection,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // A Column (not a lazy ListView) keeps every form field
            // mounted, so validation checks fields scrolled off-screen too.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  addressSection,
                  const SizedBox(height: 16),
                  paymentSection,
                  const SizedBox(height: 16),
                  summarySection,
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddressForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController postalController;

  const _AddressForm({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
    required this.postalController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => Validators.required(v, field: 'Name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Mobile number',
            hintText: '01XXXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: Validators.bdPhone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'House, road, area',
            prefixIcon: Icon(Icons.home_outlined),
          ),
          validator: (v) => Validators.required(v, field: 'Address'),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: cityController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (v) => Validators.required(v, field: 'City'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: postalController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Postal code'),
                validator: Validators.postalCode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final CartItem item;

  const _SummaryLine({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: AppNetworkImage(
                url: item.product.thumbnail,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${item.product.title}  ×${item.quantity}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatters.price(item.lineTotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
