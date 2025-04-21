import 'package:flutter/material.dart';
import 'package:bb_vendor/models/get_properties_model.dart';

class HallsCalendarScreen extends StatelessWidget {
  const HallsCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    final Data property = args['property'];

    final halls = property.halls ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.propertyName ?? 'No Name',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              property.address ?? 'No Address',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: halls.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: halls.length,
                itemBuilder: (context, index) {
                  final hall = halls[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50], // background color
                      border: Border.all(
                        color: Colors.deepPurple.shade200, // border color
                        width: 1, // border width
                      ),
                      borderRadius:
                          BorderRadius.circular(12), // rounded corners
                    ),
                    child: ListTile(
                      title: Text(hall.hallName ?? 'No Hall Name'),
                      subtitle: Text("ID: ${hall.hallId ?? 'N/A'}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/calendarPropertiesList',
                        );
                        // Handle hall tap
                      },
                    ),
                  );
                },
              ),
            )
          : const Center(
              child: Text('No halls found for this property'),
            ),
    );
  }
}
