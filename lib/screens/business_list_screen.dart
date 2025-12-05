import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/index.dart';
import '../widgets/business_card.dart';
import '../widgets/gradient_background.dart';

class BusinessListScreen extends ConsumerWidget {
  const BusinessListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Stops'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: businesses.when(
          data: (businessList) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: businessList.length,
              itemBuilder: (context, index) {
                return BusinessCard(business: businessList[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
