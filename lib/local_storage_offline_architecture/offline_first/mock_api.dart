import 'dart:async';

/// Simulates a remote API that takes time to fetch data.
class MockApi {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate data returning from a server
    return [
      {"id": "api1", "name": "Cloud Server", "price": 5000.0},
      {"id": "api2", "name": "API Gateway", "price": 200.0},
      {"id": "api3", "name": "Load Balancer", "price": 1200.0},
    ];
  }
}
