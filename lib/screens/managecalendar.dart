import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/models/get_properties_model.dart';
import 'package:bb_vendor/providers/property_repository.dart'; // Import your property provider
import 'package:bb_vendor/providers/addpropertynotifier.dart';

class ManageCalendarScreen extends ConsumerStatefulWidget {
  const ManageCalendarScreen({super.key});

  @override
  ConsumerState<ManageCalendarScreen> createState() =>
      _ManageCalendarScreenState();
}

class _ManageCalendarScreenState extends ConsumerState<ManageCalendarScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.read(propertyNotifierProvider.notifier).getproperty();
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyNotifierProvider).data ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 40,
            color: Color.fromARGB(255, 67, 3, 128),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Manage Calendar",
          style: TextStyle(
              color: Color.fromARGB(255, 67, 3, 128),
              fontWeight: FontWeight.w900),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search with property name',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Icon(
                    Icons.search,
                    size: 40,
                    color: Color.fromARGB(255, 67, 3, 128),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),

            const SizedBox(height: 10),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // background color
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // rounded corners
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Properties List",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Select from below properties to manage their calendar",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 32, 32, 32),
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Expanded(
              child: Container(
                child: propertyState.isNotEmpty
                    ? ListView.builder(
                        itemCount: propertyState.length,
                        itemBuilder: (context, index) {
                          final property = propertyState[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[50], // background color
                              border: Border.all(
                                color:
                                    Colors.deepPurple.shade200, // border color
                                width: 1, // border width
                              ),
                              borderRadius:
                                  BorderRadius.circular(12), // rounded corners
                            ),
                            child: PropertyCard(
                              property: property,
                              name: property.propertyName ?? 'No Name',
                              location: property.address ?? 'No Address',
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No properties available',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Data property;

  const PropertyCard(
      {super.key,
      required this.property,
      required String name,
      required String location});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            property.propertyName ?? 'No Name',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            property.address ?? 'No Address',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/hallscalendar',
              arguments: {'property': property},
            );
          },
        ),
      ],
    );
  }
}
