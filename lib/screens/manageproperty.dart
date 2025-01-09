import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Models/new_subscriptionplan.dart';
import 'package:bb_vendor/providers/property_repository.dart';
import 'package:bb_vendor/Widgets/tabbar.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/Models/get_properties_model.dart';

class ManagePropertyScreen extends ConsumerStatefulWidget {
  const ManagePropertyScreen({super.key});

  @override
  _ManagePropertyScreenState createState() => _ManagePropertyScreenState();
}

class _ManagePropertyScreenState extends ConsumerState<ManagePropertyScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final propertyListAsyncValue = ref.watch(propertyListProvider);

    return Scaffold(
      backgroundColor: CoustColors.colrFill,
      appBar: AppBar(
        title: const coustText(
          sName: 'Manage Properties',
          txtcolor: CoustColors.colrEdtxt2,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: CoustColors.colrHighlightedText,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            iconSize: 40,
            padding: const EdgeInsets.only(right: 25),
            color: CoustColors.colrHighlightedText,
            icon: const Icon(Icons.add),
            tooltip: 'Add Property',
            onPressed: () {
              Navigator.of(context).pushNamed('/addproperty');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: CoustTabbar(
              filter: filter,
              length: 4,
              tab0: "All",
              tab1: "Subscribed",
              tab2: "Deactivated",
              tab3: "UnSubscribed",
              onTap: (selected) {
                setState(() {
                  switch (selected) {
                    case 0:
                      filter = "All";
                      break;
                    case 1:
                      filter = "Subscribed";
                      break;
                    case 2:
                      filter = "Deactivated";
                      break;
                    case 3:
                      filter = "UnSubscribed";
                      break;
                  }
                });
              },
            ),
          ),
          // Expanded(
          //   child: propertyListAsyncValue.when(
          //     data: (properties) {
          //       final filteredProperties = properties
          //           .where((property) => (filter == "All" ||
          //               (filter == "Subscribed" &&
          //                   property.activationStatus == "Subscribed") ||
          //               (filter == "Deactivated" &&
          //                   property.activationStatus == "Deactivated") ||
          //               (filter == "UnSubscribed" &&
          //                   property.activationStatus == "UnSubscribed")))
          //           .toList();

          //       return ListView.builder(
          //         itemCount: filteredProperties.length,
          //         itemBuilder: (context, index) {
          //           final property = filteredProperties[index];
          //           return _buildPlanCard(property);
          //         },
          //       );
          //     },
          //     loading: () => const Center(child: CircularProgressIndicator()),
          //     error: (error, stack) => Center(child: Text('Error: $error')),
          //   ),
          // _buildPlanCard(property);
          // ),
          _buildPlanCard()
        ],

      ),
    );
  }

  Widget _buildPlanCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/plansScreen',
            // arguments: property,
          );
        },
        child: Card(
          color: Colors.white,
          elevation: 4,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            // property.propertyName ?? 'Unknown Name',
                            "swagat grand",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // property.address1 ?? 'Unknown Address',
                      "miyapur",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Revenue Generated: ₹89,928",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Last Subscribed: 28th Feb, 2024 at 06:35 PM",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // ${property.activationStatus ?? 'Unknown Status'}
                      "Status: activate",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // if (property.propertyPic != null)
                Container(
                  width: double.infinity,
                  height: 150, // Adjust height as needed
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(4),
                    ),
                    // image: DecorationImage(
                    //   image: NetworkImage(
                    //     'http://93.127.172.164:8080${property.propertyPic}',
                    //   ),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).pushNamed(
                    //   '/subscriptionScreen',
                    //   arguments: property,
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize:
                        const Size(double.infinity, double.minPositive),
                  ),
                  child: const Text(
                    'Subscribe',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepository(ref);
});

final propertyListProvider = FutureProvider<List<Property>>((ref) async {
  final repository = ref.read(propertyRepositoryProvider);
  return repository.fetchProperties();
});
