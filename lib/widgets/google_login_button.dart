// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/auth_service.dart';
//
// class GoogleLoginButton extends ConsumerWidget {
//   const GoogleLoginButton({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: OutlinedButton.icon(
//         icon: Image.asset(
//           'assets/images/google_logo.png',
//           height: 24.0,
//           errorBuilder: (context, error, stackTrace) =>
//           const Icon(Icons.login, color: Colors.white),
//         ),
//         label: const Text('Sign in with Google'),
//         onPressed: () async {
//           // Use the provider we created in auth_service.dart
//           await ref.read(authServiceProvider).signInWithGoogle();
//           // Navigation is handled by the router listening to auth state
//         },
//       ),
//     );
//   }
// }
