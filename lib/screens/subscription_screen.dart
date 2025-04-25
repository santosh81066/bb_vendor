import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:bb_vendor/providers/new_subscription_get.dart";
import "package:bb_vendor/models/new_subscriptionplan.dart";
import 'package:intl/intl.dart';

class Subscription extends ConsumerStatefulWidget {
  const Subscription({super.key});

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends ConsumerState<Subscription> {
  Data? selectedPlan;
  SubPlans? selectedSubPlan;
  int? properid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch subscribers when the widget is loaded
    ref.watch(subscriptionProvider.notifier).getSubscribers();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      properid = args['propertyid'];
    }
  }

  DateTime calculateExpiryTime(
      DateTime startTime, int frequency, String subPlanName) {
    switch (subPlanName.toLowerCase()) {
      case 'daily':
        return startTime.add(Duration(days: frequency));
      case 'monthly':
        return DateTime(startTime.year, startTime.month + frequency,
            startTime.day, startTime.hour, startTime.minute);
      case 'yearly':
        return DateTime(startTime.year + frequency, startTime.month,
            startTime.day, startTime.hour, startTime.minute);
      default:
        throw Exception("Unsupported subPlanName: $subPlanName");
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Subscription",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff6418c3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select a Plan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Display plan cards
              if (subscription.data != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: subscription.data!.map((plan) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPlan = plan;
                            selectedSubPlan = null; // Reset sub-plan selection
                          });
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedPlan == plan
                                ? const Color(0xff6418c3)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xff6418c3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.card_membership,
                                  color: Colors.white),
                              const SizedBox(height: 8),
                              Text(
                                plan.planName ?? "",
                                style: TextStyle(
                                  color: selectedPlan == plan
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 24),
              // Display sub-plans for the selected plan
              if (selectedPlan != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${selectedPlan!.planName} Sub-Plans",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: selectedPlan!.subPlans!.map((subPlan) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSubPlan = subPlan;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedSubPlan == subPlan
                                  ? const Color(0xff6418c3).withOpacity(0.1)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedSubPlan == subPlan
                                    ? const Color(0xff6418c3)
                                    : Colors.grey,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subPlan.subPlanName ?? "",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Most Valued",
                                      style: TextStyle(
                                        color: Colors.red[400],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\₹${subPlan.price}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "freq : ${subPlan.frequency}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "no.of : ${subPlan.numBookings}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Save ${_calculateDiscount(subPlan.price)}%",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Radio<SubPlans>(
                                      value: subPlan,
                                      groupValue: selectedSubPlan,
                                      onChanged: (SubPlans? value) {
                                        setState(() {
                                          selectedSubPlan = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              // Display selected sub-plan at the bottom
              if (selectedSubPlan != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff6418c3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selected ${selectedPlan!.planName} Plan",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "\₹6000",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "\₹${selectedSubPlan!.price}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "/${selectedSubPlan!.frequency}-${selectedSubPlan!.subPlanName}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: selectedPlan == null ||
                                        selectedSubPlan == null
                                    ? null // Disable button if no plan or sub-plan is selected
                                    : () async {
                                        // Validate frequency and convert to int
                                        final parsedFrequency = int.tryParse(
                                            selectedSubPlan!.frequency ?? "");

                                        if (parsedFrequency == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Invalid frequency value")),
                                          );
                                          return;
                                        }
                                        // Get the current time as start_time

                                        DateTime startTime = DateTime.now();

                                        // Calculate expiry_time based on frequency and sub-plan name
                                        DateTime expiryTime =
                                            calculateExpiryTime(
                                          startTime,
                                          parsedFrequency, // Assuming frequency is numeric
                                          selectedSubPlan!
                                              .subPlanName!, // Sub-plan type: daily, monthly, yearly
                                        );

                                        // Format the times for API request
                                        String formattedStartTime =
                                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                                .format(startTime);
                                        String formattedExpiryTime =
                                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                                .format(expiryTime);

                                        await ref
                                            .read(subscriptionProvider.notifier)
                                            .addSubscriptionPlan(
                                              propertyid:
                                                  properid, // Replace with actual property ID
                                              subplanid: selectedSubPlan!
                                                  .subPlanId, // ID of the selected sub-plan
                                              starttime: formattedStartTime,
                                              expirytime: formattedExpiryTime,
                                            );

                                        // Show success message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "plan added to property successfully!",
                                              style: const TextStyle(
                                                color: Colors
                                                    .white, // Set the text color
                                                fontWeight: FontWeight
                                                    .bold, // Optional: Make the text bold
                                              ),
                                            ),
                                            backgroundColor: const Color
                                                .fromARGB(255, 13, 70,
                                                151), // Set the background color
                                            behavior: SnackBarBehavior
                                                .floating, // Optional: Makes the snackbar float
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  12), // Optional: Adds rounded corners
                                            ),
                                            duration: const Duration(
                                                seconds:
                                                    3), // Optional: Set duration for snackbar
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff6418c3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    Text("Buy ${selectedPlan!.planName} Plan"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDiscount(String? price) {
    // Placeholder for discount calculation
    // Replace this with actual logic as needed
    return "20";
  }
}

//  subscriptionPlansAsyncValue.when(
//               data: (subscriptionPlans) {
//                 final groupedPlans = <String, List<SubscriptionPlan>>{};
//                 for (var plan in subscriptionPlans) {
//                   if (!groupedPlans.containsKey(plan.plan)) {
//                     groupedPlans[plan.plan] = [];
//                   }
//                   groupedPlans[plan.plan]!.add(plan as SubscriptionPlan);
//                 }

//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: groupedPlans.length,
//                   itemBuilder: (context, index) {
//                     final planTitle = groupedPlans.keys.elementAt(index);
//                     final plans = groupedPlans[planTitle]!;

//                     return _buildPlanCard(
//                       context,
//                       planTitle,
//                       plans,
//                       // ref,
//                     );
//                   },
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, stackTrace) => Center(
//                 child: Text('Error: $error'),
//               ),
//             ),

//   Widget _buildPlanCard(
//       BuildContext context, String title, List<SubscriptionPlan> plans) {
//     // Extract unique frequencies from the plans
//     final frequencies = plans.map((plan) => plan.frequency).toSet().toList();
//     int? _selectedFrequency;
//     List<SubscriptionPlan> filteredPlans = [];

//     return StatefulBuilder(
//       builder: (context, setState) {
//         if (_selectedFrequency == null && frequencies.isNotEmpty) {
//           _selectedFrequency = frequencies.first;
//         }

//         filteredPlans = plans
//             .where((plan) => plan.frequency == _selectedFrequency)
//             .toList();

//         return GestureDetector(
//           onTap: () {},
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 4,
//             margin: const EdgeInsets.all(8.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 color: Colors.white,
//               ),
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8.0),
//                   Row(
//                     children: [
//                       const Text(
//                         "Frequency: ",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       DropdownButton<int>(
//                         value: _selectedFrequency,
//                         items: frequencies.map((frequency) {
//                           return DropdownMenuItem<int>(
//                             value: frequency,
//                             child: Text(
//                               "$frequency",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (int? value) {
//                           setState(() {
//                             _selectedFrequency = value;
//                             filteredPlans = plans
//                                 .where((plan) =>
//                                     plan.frequency == _selectedFrequency)
//                                 .toList();
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   if (filteredPlans.isNotEmpty) ...[
//                     ...filteredPlans.map((plan) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Bookings: ${plan.bookings}",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           Text(
//                             "Pricing: ${plan.pricing.toStringAsFixed(2)}",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                           ElevatedButton(
//                             onPressed: () {
//                               // Navigator.of(context).pushNamed(
//                               //   '/subscriptionScreen',
//                               // );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               minimumSize: const Size(double.infinity, 0),
//                             ),
//                             child: const Text(
//                               'Purchase',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                         ],
//                       );
//                     }).toList(),
//                   ] else ...[
//                     const Text(
//                       "No data available for the selected frequency",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
