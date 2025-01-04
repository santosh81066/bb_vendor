import 'package:flutter/material.dart';
import 'package:bb_vendor/models/new_subscriptionplan.dart';

class Subpackages extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final String title;
  final Color cardColor;

  const Subpackages({
    Key? key,
    required this.plans,
    required this.title,
    required this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title Subscriptions'),
        backgroundColor: cardColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.plan,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Frequency: ${plan.frequency}'),
                          Text('Bookings: ${plan.bookings}'),
                          Text('Pricing: ${plan.pricing.toString()}'),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         EditSubscriptionScreen(plan: plan),
                            //   ),
                            // );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, plan, index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, SubscriptionPlan plan, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Subscription'),
          content: Text(
              'Are you sure you want to delete the subscription plan "${plan.plan}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete action here
                _deleteSubscriptionPlan(context, plan, index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubscriptionPlan(
      BuildContext context, SubscriptionPlan plan, int index) {
    plans.removeAt(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted subscription plan "${plan.plan}"'),
      ),
    );

    (context as Element).rebuild();
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:banquetbookingz/views.dart/subscription.dart';
// import 'package:banquetbookingz/models/new_subscriptionplan.dart';

// class Subpackages extends StatelessWidget {
//   final List<SubscriptionPlan> plans;
//   final String title;
//   final Color cardColor;

//   const Subpackages({
//     Key? key,
//     required this.plans,
//     required this.title,
//     required this.cardColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$title Subscriptions'),
//         backgroundColor: cardColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: plans.length,
//           itemBuilder: (context, index) {
//             final plan = plans[index];
//             return Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               elevation: 4,
//               margin: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             plan.plan,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text('Frequency: ${plan.frequency}'),
//                           Text('Bookings: ${plan.bookings}'),
//                           Text('Pricing: ${plan.pricing.toString()}'),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     EditSubscriptionScreen(plan: plan),
//                               ),
//                             );
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () {
//                             _showDeleteConfirmationDialog(context, plan, index);
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmationDialog(
//       BuildContext context, SubscriptionPlan plan, int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Subscription'),
//           content: Text(
//               'Are you sure you want to delete the subscription plan "${plan.plan}"?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Perform the delete action here
//                 _deleteSubscriptionPlan(context, plan, index);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _deleteSubscriptionPlan(
//       BuildContext context, SubscriptionPlan plan, int index) {
//     // Remove the plan from the list
//     plans.removeAt(index);

//     // Optionally, make an API call to delete the plan from the backend
//     // Example:
//     // await apiService.deleteSubscriptionPlan(plan.id);

//     // Show a Snackbar to indicate the deletion
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Deleted subscription plan "${plan.plan}"'),
//       ),
//     );

//     // Trigger UI update
//     (context as Element).rebuild();
//   }
// }

// class EditSubscriptionScreen extends StatelessWidget {
//   final SubscriptionPlan plan;

//   const EditSubscriptionScreen({Key? key, required this.plan})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Subscription Plan'),
//         backgroundColor: Colors.blue[900],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextFormField(
//               initialValue: plan.plan,
//               decoration: const InputDecoration(labelText: 'Plan'),
//             ),
//             TextFormField(
//               initialValue: plan.frequency.toString(),
//               decoration: const InputDecoration(labelText: 'Frequency'),
//             ),
//             TextFormField(
//               initialValue: plan.bookings.toString(),
//               decoration: const InputDecoration(labelText: 'Bookings'),
//             ),
//             TextFormField(
//               initialValue: plan.pricing.toString(),
//               decoration: const InputDecoration(labelText: 'Pricing'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Handle saving the edited subscription details
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
