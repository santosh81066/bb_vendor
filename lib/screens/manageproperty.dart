import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/providers/addpropertynotifier.dart';
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
                    filter = [
                      'All',
                      'Subscribed',
                      'Deactivated',
                      'UnSubscribed'
                    ][selected];
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
                return _buildPropertyCard(
                    property, screenWidth, screenHeight);
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

  Widget _buildPropertyCard(
      Data property, double screenWidth, double screenHeight) {
    // Group halls by their name
    final Map<String, List<Hall>> groupedHalls = {};
    for (var hall in property.halls ?? []) {
      if (hall.name != null) {
        groupedHalls.putIfAbsent(hall.name!, () => []).add(hall);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.01,
      ),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F3FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.propertyName ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6418C3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          property.address ?? 'No Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCategoryBadge(property.category),
                ],
              ),
            ),

            // Property Image
            if (property.coverPic != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'http://www.gocodedesigners.com/banquetbookingz/${property.coverPic}',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Property Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/addproperty',
                          arguments: {
                            'property': property,
                            'isEditing': true,
                          },
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit Property"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6418C3),
                        side: const BorderSide(color: Color(0xFF6418C3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context, property);
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text("Delete"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Halls Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Halls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6418C3),
                    ),
                  ),
                  TextButton.icon(
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
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add New Hall"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6418C3),
                    ),
                  ),
                ],
              ),
            ),

            // Halls List
            groupedHalls.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedHalls.length,
              itemBuilder: (context, index) {
                final hallName = groupedHalls.keys.elementAt(index);
                final hallsList = groupedHalls[hallName]!;
                return _buildHallCard(hallName, hallsList, property);
              },
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No halls added yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Property Bottom Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/subscriptionScreen',
                      arguments: {
                        'propertyid': property.propertyId,
                      });
                },
                icon: const Icon(Icons.card_membership),
                label: const Text("Manage Subscription"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6418C3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHallCard(String hallName, List<Hall> hallsList, Data property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ExpansionTile(
          title: Text(
            hallName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6418C3),
            ),
          ),
          subtitle: Text(
            '${hallsList.length} time slot${hallsList.length == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF0EAFF),
            child: Icon(
              Icons.meeting_room,
              color: const Color(0xFF6418C3),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF6418C3),
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/addhall',
                    arguments: {
                      'propertyid': property.propertyId,
                      'propertyname': property.propertyName,
                      'hallName': hallName,
                      'isEditing': true,
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  _showDeleteHallConfirmation(context, hallsList.first, property);
                },
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hallsList.expand((hall) => hall.slots ?? []).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final allSlots = hallsList.expand((hall) => hall.slots ?? []).toList();
                final slot = allSlots[index];
                return ListTile(
                  leading: const Icon(
                    Icons.access_time,
                    color: Color(0xFF6418C3),
                    size: 20,
                  ),
                  title: Text(
                    'Slot #${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'From: ${slot.slotFromTime ?? 'N/A'} To: ${slot.slotToTime ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  dense: true,
                );
              },
            ),
            if (hallsList.isNotEmpty && hallsList.first.slots != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Base Price:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${hallsList.first.slots}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6418C3),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Data property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text(
          'Are you sure you want to delete "${property.propertyName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete property logic here
              // ref.read(propertyNotifierProvider.notifier).deleteProperty(property.propertyId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteHallConfirmation(BuildContext context, Hall hall, Data property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hall'),
        content: Text(
          'Are you sure you want to delete "${hall.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete hall logic here
              // ref.read(propertyNotifierProvider.notifier).deleteHall(hall.hallId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(int? category) {
    String text;
    Color color;

    switch (category) {
      case 1:
        text = 'Subscribed';
        color = Colors.green;
        break;
      case 2:
        text = 'Deactivated';
        color = Colors.red;
        break;
      case 3:
        text = 'UnSubscribed';
        color = Colors.orange;
        break;
      default:
        text = 'Unknown';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}