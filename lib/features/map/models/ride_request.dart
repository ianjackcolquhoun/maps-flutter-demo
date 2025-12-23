import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Status of a ride request
enum RequestStatus {
  pending,    // Request created, waiting for assignment
  assigned,   // Cart assigned, on the way to pickup
  inProgress, // User picked up, en route to destination
  completed,  // Dropoff complete
  cancelled,  // Request cancelled
}

/// Represents a user's request for a ride to the stadium
class RideRequest {
  final String id;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final int partySize;
  final DateTime requestTime;
  final RequestStatus status;
  final String? assignedCartId;

  const RideRequest({
    required this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.partySize,
    required this.requestTime,
    this.status = RequestStatus.pending,
    this.assignedCartId,
  });

  /// Create a copy with updated fields
  RideRequest copyWith({
    String? id,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    int? partySize,
    DateTime? requestTime,
    RequestStatus? status,
    String? assignedCartId,
  }) {
    return RideRequest(
      id: id ?? this.id,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      partySize: partySize ?? this.partySize,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
      assignedCartId: assignedCartId ?? this.assignedCartId,
    );
  }

  /// Get status as human-readable string
  String get statusText {
    switch (status) {
      case RequestStatus.pending:
        return 'Finding cart...';
      case RequestStatus.assigned:
        return 'Cart on the way';
      case RequestStatus.inProgress:
        return 'En route to stadium';
      case RequestStatus.completed:
        return 'Arrived!';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  String toString() {
    return 'RideRequest(id: $id, status: $status, cartId: $assignedCartId)';
  }
}
