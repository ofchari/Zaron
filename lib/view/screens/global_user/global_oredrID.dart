class GlobalOrderSession {
  static final GlobalOrderSession _instance = GlobalOrderSession._internal();

  factory GlobalOrderSession() => _instance;

  GlobalOrderSession._internal();

  int? orderId;
  int? newOrderId;

  void setOrderId(int id) {
    orderId = id;
  }

  int? getOrderId() => orderId;

  void setNewOrderId(int id) {
    newOrderId = id;
  }

  int? getNewOrderId() => newOrderId;
}
