import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Assuming you're using Riverpod

class LocationSearchField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? Function(String?) validator;

  const LocationSearchField({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.validator,
  }) : super(key: key);

  @override
  _LocationSearchFieldState createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends ConsumerState<LocationSearchField> {
  List<String> locationSuggestions = [];
  bool showSuggestions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: (value) {
            widget.onChanged(value);
            _fetchSuggestions(value);
          },
          decoration: InputDecoration(
            hintText: "Enter location",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          validator: widget.validator,
        ),
        const SizedBox(height: 10),
        if (showSuggestions && locationSuggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: locationSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    // Set the selected location
                    widget.controller.text = locationSuggestions[index];
                    setState(() {
                      showSuggestions = false;
                    });
                  },
                  title: Text(locationSuggestions[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  void _fetchSuggestions(String query) {
    // Mocked list of locations (can be replaced with API or database call)
    final allLocations = [
      "Go Code Designers",
      "Nithya Multi Speciality Hospital",
      "Samraksha Multi Speciality Hospital Nalgonda",
      "Hospital",
      "Angadipeta",
    ];

    setState(() {
      locationSuggestions = allLocations
          .where((location) =>
              location.toLowerCase().contains(query.toLowerCase()))
          .toList();
      showSuggestions = locationSuggestions.isNotEmpty;
    });
  }
}
