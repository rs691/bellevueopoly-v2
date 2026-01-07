import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

/// Provider for AdminService
final adminServiceProvider = Provider((ref) => AdminService());

/// Provider to check if current user is admin
final isAdminProvider = StreamProvider<bool>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.adminStatusStream();
});

/// Provider to get admin status as Future (for one-time checks)
final isAdminFutureProvider = FutureProvider<bool>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.isAdmin();
});
