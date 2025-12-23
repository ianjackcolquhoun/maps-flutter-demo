import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/ride_request.dart';
import '../models/route.dart' as route_model;

/// Info card showing details about assigned cart and route
class CartInfoCard extends StatelessWidget {
  final Cart cart;
  final RideRequest request;
  final route_model.Route route;

  const CartInfoCard({
    super.key,
    required this.cart,
    required this.request,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart name and status
            Row(
              children: [
                // Cart icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.golf_course,
                    color: _getStatusColor(request.status),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Cart info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cart.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusMessage(request.status),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(request.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Divider
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            // Route details
            Row(
              children: [
                // Distance
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.route,
                    label: 'Distance',
                    value: '${route.estimatedDistanceMiles.toStringAsFixed(1)} mi',
                  ),
                ),
                // ETA
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.access_time,
                    label: 'Arriving in',
                    value: '${route.estimatedDurationMinutes} min',
                  ),
                ),
                // Party size
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.person,
                    label: 'Party',
                    value: '${request.partySize}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.grey;
      case RequestStatus.assigned:
        return Colors.orange; // En route to pickup
      case RequestStatus.inProgress:
        return Colors.blue; // Taking you to stadium
      case RequestStatus.completed:
        return Colors.green; // Arrived!
      case RequestStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.assigned:
        return 'En Route';
      case RequestStatus.inProgress:
        return 'In Transit';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusMessage(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Finding nearest cart...';
      case RequestStatus.assigned:
        return 'Cart is coming to pick you up';
      case RequestStatus.inProgress:
        return 'Heading to Great American Ball Park';
      case RequestStatus.completed:
        return 'Arrived at stadium. Enjoy the game!';
      case RequestStatus.cancelled:
        return 'Request cancelled';
    }
  }
}
