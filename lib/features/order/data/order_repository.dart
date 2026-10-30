import '../../../core/constants/api_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/preference_service.dart';
import '../models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getOrders({required int userId});
}

/// Saves orders to the local mock server (json-server) and keeps a copy on
/// the device. The device copy means order history still works when the
/// mock server is not running.
class OrderRepositoryImpl implements OrderRepository {
  final DioClient dioClient;
  final PreferenceService preferenceService;

  OrderRepositoryImpl({
    required this.dioClient,
    required this.preferenceService,
  });

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    await _saveLocally(order);
    try {
      await dioClient.post(ApiConstants.orders, data: order.toMap());
    } on ApiException {
      // Server offline: the order is already safe on the device.
    }
    return order;
  }

  @override
  Future<List<OrderModel>> getOrders({required int userId}) async {
    final byId = <String, OrderModel>{
      for (final order in _localOrders())
        if (order.userId == userId) order.id: order,
    };

    try {
      final response = await dioClient.get(
        ApiConstants.orders,
        queryParameters: {'userId': userId},
      );
      final data = response.data;
      if (data is List) {
        for (final raw in data.whereType<Map>()) {
          final order = OrderModel.fromMap(Map<String, dynamic>.from(raw));
          if (order.userId == userId) byId[order.id] = order;
        }
      }
    } on ApiException {
      // Server offline: show the orders saved on the device.
    }

    final orders = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  List<OrderModel> _localOrders() {
    return preferenceService
        .readJsonList(StorageKeys.orders)
        .map(OrderModel.fromMap)
        .toList();
  }

  Future<void> _saveLocally(OrderModel order) async {
    final orders = _localOrders()
      ..removeWhere((o) => o.id == order.id)
      ..add(order);
    await preferenceService.writeJsonList(
      StorageKeys.orders,
      orders.map((o) => o.toMap()).toList(),
    );
  }
}
