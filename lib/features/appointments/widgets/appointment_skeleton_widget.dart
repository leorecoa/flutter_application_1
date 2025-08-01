import 'package:flutter/material.dart';

/// Widget para exibir um skeleton loading para cards de agendamento
class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSkeletonCircle(48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(width: double.infinity, height: 20),
                      const SizedBox(height: 8),
                      _buildSkeletonLine(width: 200, height: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkeletonLine(width: 150, height: 16),
            const SizedBox(height: 8),
            _buildSkeletonLine(width: 100, height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSkeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Widget para exibir uma lista de skeletons durante o carregamento
class AppointmentListSkeleton extends StatelessWidget {
  final int itemCount;

  const AppointmentListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const AppointmentCardSkeleton(),
    );
  }
}