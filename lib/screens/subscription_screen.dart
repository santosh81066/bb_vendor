import 'dart:convert';
import 'package:bb_vendor/Models/authstate.dart';
import 'package:bb_vendor/Providers/stateproviders.dart';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bb_vendor/Widgets/stackwidget.dart';
import 'package:bb_vendor/Models/new_subscriptionplan.dart';
import 'package:bb_vendor/Providers/auth.dart';
import 'package:bb_vendor/providers/new_subscription_get.dart';

class Subscription extends ConsumerStatefulWidget {
  const Subscription({super.key});
  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends ConsumerState<Subscription> {
  @override
  Widget build(BuildContext context) {
    final subscriptionPlansAsyncValue = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StackWidget(
              text: "Subscription",
              onTap: () {
                Navigator.of(context).pushNamed("addsubscriber");
              },
            ),
            subscriptionPlansAsyncValue.when(
              data: (subscriptionPlans) {
                final groupedPlans = <String, List<SubscriptionPlan>>{};
                for (var plan in subscriptionPlans) {
                  if (!groupedPlans.containsKey(plan.plan)) {
                    groupedPlans[plan.plan] = [];
                  }
                  groupedPlans[plan.plan]!.add(plan as SubscriptionPlan);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedPlans.length,
                  itemBuilder: (context, index) {
                    final planTitle = groupedPlans.keys.elementAt(index);
                    final plans = groupedPlans[planTitle]!;

                    return _buildPlanCard(
                      context,
                      planTitle,
                      plans,
                      // ref,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, String title, List<SubscriptionPlan> plans) {
    // Extract unique frequencies from the plans
    final frequencies = plans.map((plan) => plan.frequency).toSet().toList();
    int? _selectedFrequency;
    List<SubscriptionPlan> filteredPlans = [];

    return StatefulBuilder(
      builder: (context, setState) {
        if (_selectedFrequency == null && frequencies.isNotEmpty) {
          _selectedFrequency = frequencies.first;
        }

        filteredPlans = plans
            .where((plan) => plan.frequency == _selectedFrequency)
            .toList();

        return GestureDetector(
          onTap: () {},
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Text(
                        "Frequency: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton<int>(
                        value: _selectedFrequency,
                        items: frequencies.map((frequency) {
                          return DropdownMenuItem<int>(
                            value: frequency,
                            child: Text(
                              "$frequency",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedFrequency = value;
                            filteredPlans = plans
                                .where((plan) =>
                                    plan.frequency == _selectedFrequency)
                                .toList();
                          });
                        },
                      ),
                    ],
                  ),
                  if (filteredPlans.isNotEmpty) ...[
                    ...filteredPlans.map((plan) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bookings: ${plan.bookings}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Pricing: ${plan.pricing.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.of(context).pushNamed(
                              //   '/subscriptionScreen',
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                            child: const Text(
                              'Purchase',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      );
                    }).toList(),
                  ] else ...[
                    const Text(
                      "No data available for the selected frequency",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

