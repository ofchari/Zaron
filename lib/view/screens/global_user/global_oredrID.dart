// Create a singleton class to manage global order ID
class GlobalOrderManager {
  static final GlobalOrderManager _instance = GlobalOrderManager._internal();
  factory GlobalOrderManager() => _instance;
  GlobalOrderManager._internal();

  int? _globalOrderId;
  String? _globalOrderNo;

  // Getter for order ID
  int? get globalOrderId => _globalOrderId;

  // Getter for order number
  String? get globalOrderNo => _globalOrderNo;

  // Set the global order ID (called when first order is created)
  void setGlobalOrderId(int orderId, String orderNo) {
    _globalOrderId = orderId;
    _globalOrderNo = orderNo;
    print("Global Order ID set to: $_globalOrderId");
    print("Global Order No set to: $_globalOrderNo");
  }

  // Clear the global order ID (called when user goes back to dashboard)
  void clearGlobalOrderId() {
    _globalOrderId = null;
    _globalOrderNo = null;
    print("Global Order ID cleared");
  }

  // Check if we have a global order ID
  bool hasGlobalOrderId() {
    return _globalOrderId != null;
  }
}
