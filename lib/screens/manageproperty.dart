import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/models/get_properties_model.dart';
import 'package:bb_vendor/providers/addpropertynotifier.dart';

class ManagePropertyScreen extends ConsumerStatefulWidget {
  const ManagePropertyScreen({super.key});

  @override
  _ManagePropertyScreenState createState() => _ManagePropertyScreenState();
}

class _ManagePropertyScreenState extends ConsumerState<ManagePropertyScreen> {
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
          return property.category == 1; // Example: Filter for subscribed
        case 'Deactivated':
          return property.category == 2; // Example: Filter for deactivated
        case 'UnSubscribed':
          return property.category == 3; // Example: Filter for unsubscribed
        default:
          return true; // 'All' case
      }
    }).toList();

    return Scaffold(
      backgroundColor: CoustColors.colrFill,
      appBar: AppBar(
        title: const Text('Manage Properties'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            iconSize: 40,
            padding: const EdgeInsets.only(right: 25),
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
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TabBarWidget(
              filter: filter,
              onFilterSelected: (selectedFilter) {
                setState(() {
                  filter = selectedFilter;
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
                      return _buildPlanCard(property);
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

  Widget _buildPlanCard(Data property) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                property.propertyName ?? 'No Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(property.address ?? 'No Address'),
            ),
            if (property.coverPic != null)
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  'https://your-image-url.com/${property.coverPic}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text("Image not found"),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/addhall', arguments: property);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoustColors.colrHighlightedText,
                  ),
                  child: const Text('Add Hall'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to subscription
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoustColors.colrHighlightedText,
                  ),
                  child: const Text('Subscribe'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class TabBarWidget extends StatelessWidget {
  final String filter;
  final Function(String) onFilterSelected;

  const TabBarWidget({
    required this.filter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FilterTab(
          label: 'All',
          isSelected: filter == 'All',
          onTap: () => onFilterSelected('All'),
        ),
        FilterTab(
          label: 'Subscribed',
          isSelected: filter == 'Subscribed',
          onTap: () => onFilterSelected('Subscribed'),
        ),
        FilterTab(
          label: 'Deactivated',
          isSelected: filter == 'Deactivated',
          onTap: () => onFilterSelected('Deactivated'),
        ),
        FilterTab(
          label: 'UnSubscribed',
          isSelected: filter == 'UnSubscribed',
          onTap: () => onFilterSelected('UnSubscribed'),
        ),
      ],
    );
  }
}

class FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
