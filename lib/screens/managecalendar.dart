import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageCalendarScreen extends ConsumerStatefulWidget {
  const ManageCalendarScreen({super.key});

  @override
  ConsumerState<ManageCalendarScreen> createState() => _ManageCalendarScreenState();
}

class _ManageCalendarScreenState extends ConsumerState<ManageCalendarScreen>{

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20.0),
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
            // Properties List Header
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  // Properties List Header

                  Text(
                    "Properties List",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Select from below properties to manage their calendar",
                    style: TextStyle(
                        fontSize: 10, color: Color.fromARGB(255, 32, 32, 32)),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(height: 0),

            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                child: ListView(
                  children: List.generate(4, (index) {
                    return PropertyCard(
                      name: "Swagat Grand Banquet Hall",
                      location: "Bachupally, Hyderabad",
                      status: index == 1 ? "Deactivated" : "Subscribed to Pro",
                    );
                  }),
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
  final String name;
  final String location;
  final String status;

  PropertyCard({
    required this.name,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location, style: const TextStyle(color: Colors.grey)),
              // const SizedBox(height: 20),
              Text(
                status,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/calendarPropertiesList');
          },
        ),
        Divider(),
      ],
    );
  }
}


