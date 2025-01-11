import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Models/new_subscriptionplan.dart';
import 'package:bb_vendor/providers/addpropertynotifier.dart';
import 'package:bb_vendor/providers/property_repository.dart';
import 'package:bb_vendor/Widgets/tabbar.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/models/get_properties_model.dart';

class ManagePropertyScreen extends ConsumerStatefulWidget {
  const ManagePropertyScreen({Key? key}) : super(key: key);

  @override
  ManagePropertyScreenState createState() => ManagePropertyScreenState();
}

class ManagePropertyScreenState extends ConsumerState<ManagePropertyScreen> {
  String filter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch properties when the widget is loaded
    ref.read(propertyNotifierProvider.notifier).getproperty();
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyNotifierProvider).data ?? [];

    // Apply filter
    final filteredProperties = propertyState.where((property) {
      switch (filter) {
        case 'Subscribed':
          return property.category == 1; // Subscribed properties
        case 'Deactivated':
          return property.category == 2; // Deactivated properties
        case 'UnSubscribed':
          return property.category == 3; // Unsubscribed properties
        default:
          return true; // All properties
      }
    }).toList();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            iconSize: 40,
            padding: EdgeInsets.only(right: screenWidth * 0.05),
            color: CoustColors.colrHighlightedText,
            icon: const Icon(Icons.add),
            tooltip: 'Add Property',
            onPressed: () => Navigator.of(context).pushNamed('/addproperty'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
              height: 50, // Specify a fixed height for TabBar
              child: CoustTabbar(
                filter: filter,
                length: 4,
                tab0: "All",
                tab1: "Subscribed",
                tab2: "Deactivated",
                tab3: "UnSubscribed",
                onTap: (int? selected) {
                  setState(() {
                    if (selected != null) {
                      filter = ['All', 'Subscribed', 'Deactivated', 'UnSubscribed'][selected];
                    }
                  });
                },
              ),
            ),

          Expanded(
            child: filteredProperties.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredProperties.length,
                    itemBuilder: (context, index) {
                      final property = filteredProperties[index];
                      return _buildPlanCard(property, screenWidth, screenHeight);
                    },
                  )
                : const Center(
                    child: Text(
                      'No properties found for the selected filter',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

 Widget _buildPlanCard(Data property, double screenWidth, double screenHeight) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: screenWidth * 0.05,
      vertical: screenHeight * 0.01,
    ),
    child: GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/plansScreen',
          arguments: property,
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                property.propertyName ?? 'No Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(property.address ?? 'No Address'),
            ),
            if (property.coverPic != null)
              Container(
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: 200, // Fixed height
                ),
                child: Image.network(
                  'https://your-image-url.com/${property.coverPic}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text("Image not found")),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Handle edit
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color.fromARGB(167, 88, 11, 181)),
                  ),
                  child: const Text("Edit"),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Handle delete
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color.fromARGB(167, 88, 11, 181)),
                  ),
                  child: const Text("Delete"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                  context,
                  '/addhall',
                  arguments: {
                    'propertyid': property.propertyId,
                    'propertyname': property.propertyName,
                    
                  },
                );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6418c3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Add Hall"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle subscribe
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6418c3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Subscribe"),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
