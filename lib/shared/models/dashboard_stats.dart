class DashboardStats {
  final int todayAppointments;
  final int activeClients;
  final double todayRevenue;
  final int pendingPayments;

  const DashboardStats({
    required this.todayAppointments,
    required this.activeClients,
    required this.todayRevenue,
    required this.pendingPayments,
  });
}