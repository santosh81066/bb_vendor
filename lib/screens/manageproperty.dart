import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/providers/addpropertynotifier.dart';
import 'package:bb_vendor/Widgets/tabbar.dart';
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
  bool _isRefreshing = false;

  // Common styling constants
  static const _borderRadius = BorderRadius.all(Radius.circular(16));
  static const _cardElevation = 0.0;
  static const _primaryGradient = LinearGradient(
    colors: [CoustColors.gradientStart, CoustColors.gradientMiddle, CoustColors.primaryPurple, CoustColors.gradientEnd],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshProperties());
  }

  Future<void> _refreshProperties() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await ref.read(propertyNotifierProvider.notifier).getproperty();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyNotifierProvider);
    final isLoading = ref.watch(propertyLoadingProvider);
    final filteredProperties = _getFilteredProperties(propertyState.data ?? []);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      appBar: _buildAppBar(screenWidth),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CoustColors.veryLightPurple, Color(0xFFFAF5FF), Color(0xFFF8FAFF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshProperties,
          color: CoustColors.primaryPurple,
          child: Column(
            children: [
              _buildTabBar(),
              Expanded(child: _buildPropertyList(filteredProperties, screenWidth, isLoading)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth) {
    return AppBar(
      title: const Text('Manage Properties',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.white)),
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: _primaryGradient)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [_buildAddButton(screenWidth)],
    );
  }

  Widget _buildAddButton(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(right: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        tooltip: 'Add Property',
        onPressed: _navigateToAddProperty,
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 50,
      child: CoustTabbar(
        filter: filter,
        length: 4,
        tab0: "All", tab1: "Subscribed", tab2: "Deactivated", tab3: "UnSubscribed",
        onTap: (int? selected) {
          if (selected != null) {
            setState(() {
              filter = ['All', 'Subscribed', 'Deactivated', 'UnSubscribed'][selected];
            });
          }
        },
      ),
    );
  }

  Widget _buildPropertyList(List<Data> properties, double screenWidth, bool isLoading) {
    if (isLoading && properties.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CoustColors.primaryPurple)),
      );
    }

    if (properties.isEmpty) return _buildEmptyState();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: properties.length,
      itemBuilder: (context, index) => _buildPropertyCard(properties[index], screenWidth),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: CoustColors.primaryPurple.withOpacity(0.6)),
          const SizedBox(height: 16),
          const Text('No properties found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CoustColors.darkPurple)),
          const SizedBox(height: 8),
          Text(
            filter == 'All' ? 'Start by adding your first property' : 'No properties match the selected filter',
            style: TextStyle(fontSize: 14, color: CoustColors.primaryPurple.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (filter == 'All')
            ElevatedButton.icon(
              onPressed: _navigateToAddProperty,
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CoustColors.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  List<Data> _getFilteredProperties(List<Data> properties) {
    return properties.where((property) {
      switch (filter) {
        case 'Subscribed': return property.category == 1;
        case 'Deactivated': return property.category == 2;
        case 'UnSubscribed': return property.category == 3;
        default: return true;
      }
    }).toList();
  }

  Widget _buildPropertyCard(Data property, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 8),
      child: Card(
        elevation: _cardElevation,
        shape: const RoundedRectangleBorder(borderRadius: _borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF8F6FF), Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: _borderRadius,
            boxShadow: [
              BoxShadow(color: CoustColors.primaryPurple.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPropertyHeader(property),
              if (property.coverPic != null) _buildPropertyImage(property),
              _buildPropertyActions(property),
              const SizedBox(height: 16),
              _buildHallsSection(property),
              _buildPropertyBottomActions(property),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyHeader(Data property) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3E8FF), Color(0xFFE0E7FF), Color(0xFFDDD6FE), Color(0xFFE5E7EB)],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.propertyName ?? 'No Name',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CoustColors.darkPurple)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: CoustColors.primaryPurple.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(property.address ?? 'No Address',
                          style: TextStyle(fontSize: 14, color: CoustColors.primaryPurple.withOpacity(0.9), fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildCategoryBadge(property.category),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(int? category) {
    final categoryData = switch (category) {
      1 => ('Subscribed', const Color(0xFF10B981), Icons.check_circle_outline),
      2 => ('Deactivated', const Color(0xFFEF4444), Icons.cancel_outlined),
      3 => ('UnSubscribed', const Color(0xFFF59E0B), Icons.access_time_outlined),
      _ => ('Other', CoustColors.primaryPurple, Icons.help_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: categoryData.$2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: categoryData.$2.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryData.$3, size: 14, color: categoryData.$2),
          const SizedBox(width: 4),
          Text(categoryData.$1, style: TextStyle(color: categoryData.$2, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(Data property) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          'http://www.gocodedesigners.com/banquetbookingz/${property.coverPic}',
          width: double.infinity, height: 180, fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child :
          _buildImagePlaceholder(isLoading: true),
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(isLoading: false),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({required bool isLoading}) {
    return Container(
      width: double.infinity, height: 180,
      decoration: BoxDecoration(color: CoustColors.veryLightPurple, borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CoustColors.primaryPurple))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 40, color: CoustColors.primaryPurple.withOpacity(0.6)),
            const SizedBox(height: 8),
            Text('Image not available', style: TextStyle(color: CoustColors.primaryPurple.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyActions(Data property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(child: _buildActionButton('Edit Property', Icons.edit_outlined, CoustColors.primaryPurple, () => _handleEditProperty(property))),
          const SizedBox(width: 12),
          Expanded(child: _buildActionButton('Delete', Icons.delete_outline, CoustColors.rose, () => _showDeleteConfirmation(context, property))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHallsSection(Data property) {
    final groupedHalls = _groupHallsByName(property.halls ?? []);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Halls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CoustColors.primaryPurple)),
              TextButton.icon(
                onPressed: () => _navigateToAddHall(property),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add New Hall"),
                style: TextButton.styleFrom(foregroundColor: CoustColors.primaryPurple),
              ),
            ],
          ),
        ),
        _buildHallsList(groupedHalls, property),
      ],
    );
  }

  Widget _buildHallsList(Map<String, List<Hall>> groupedHalls, Data property) {
    if (groupedHalls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.meeting_room_outlined, size: 48, color: CoustColors.primaryPurple.withOpacity(0.6)),
              const SizedBox(height: 8),
              Text('No halls added yet', style: TextStyle(fontSize: 14, color: CoustColors.primaryPurple.withOpacity(0.8))),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedHalls.length,
      itemBuilder: (context, index) {
        final hallName = groupedHalls.keys.elementAt(index);
        final hallsList = groupedHalls[hallName]!;
        return _buildHallCard(hallName, hallsList, property);
      },
    );
  }

  Widget _buildHallCard(String hallName, List<Hall> hallsList, Data property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2, color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: CoustColors.lightPurple.withOpacity(0.3), width: 1),
        ),
        child: ExpansionTile(
          title: Text(hallName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CoustColors.primaryPurple)),
          subtitle: Text('${hallsList.length} time slot${hallsList.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 12, color: CoustColors.primaryPurple.withOpacity(0.7))),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [CoustColors.veryLightPurple, Color(0xFFE0E7FF)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.meeting_room, color: CoustColors.primaryPurple, size: 20),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: CoustColors.primaryPurple, size: 20),
                onPressed: () => _handleEditHall(property, hallName),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: CoustColors.rose, size: 20),
                onPressed: () => _showDeleteHallConfirmation(context, hallsList.first, property),
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            _buildHallSlots(hallsList),
            if (hallsList.isNotEmpty) _buildHallPricing(hallsList),
          ],
        ),
      ),
    );
  }

  Widget _buildHallSlots(List<Hall> hallsList) {
    final allSlots = hallsList.expand((hall) => hall.slots ?? []).toList();

    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: allSlots.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final slot = allSlots[index];
        return ListTile(
          leading: const Icon(Icons.access_time, color: CoustColors.primaryPurple, size: 20),
          title: Text('Slot #${index + 1}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('From: ${slot.slotFromTime ?? 'N/A'} To: ${slot.slotToTime ?? 'N/A'}',
              style: const TextStyle(fontSize: 12)),
          dense: true,
        );
      },
    );
  }

  Widget _buildHallPricing(List<Hall> hallsList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Base Price:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text('₹${hallsList.first.price ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CoustColors.primaryPurple)),
        ],
      ),
    );
  }

  Widget _buildPropertyBottomActions(Data property) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: const BoxDecoration(gradient: _primaryGradient, borderRadius: _borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToSubscription(property),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_membership, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text("Manage Subscription",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<Hall>> _groupHallsByName(List<Hall> halls) {
    final Map<String, List<Hall>> groupedHalls = {};
    for (var hall in halls) {
      if (hall.name != null) {
        groupedHalls.putIfAbsent(hall.name!, () => []).add(hall);
      }
    }
    return groupedHalls;
  }

  // Navigation Methods
  void _navigateToAddProperty() => Navigator.of(context).pushNamed('/addproperty').then((_) => _refreshProperties());

  void _navigateToAddHall(Data property) {
    Navigator.pushNamed(context, '/addhall', arguments: {
      'propertyid': property.propertyId,
      'propertyname': property.propertyName,
    }).then((_) => _refreshProperties());
  }

  void _navigateToSubscription(Data property) {
    Navigator.pushNamed(context, '/subscriptionScreen', arguments: {'propertyid': property.propertyId});
  }

  void _navigateToFullEdit(Data property) {
    Navigator.of(context).pushNamed('/addproperty', arguments: {
      'property': property, 'isEditing': true,
    }).then((_) => _refreshProperties());
  }

  // Edit and Delete Methods
  void _handleEditProperty(Data property) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => _buildEditOptionsBottomSheet(property),
    );
  }

  Widget _buildEditOptionsBottomSheet(Data property) {
    final editOptions = [
      ('Quick Edit', Icons.edit_outlined, 'Edit name, address, and location only', () => _showEditDialog(property, false)),
      ('Advanced Edit', Icons.tune_outlined, 'Edit all details including category', () => _showEditDialog(property, true)),
      ('Complete Edit', Icons.settings_outlined, 'Full edit with image, location, and all details', () => _navigateToFullEdit(property)),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: CoustColors.primaryPurple.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Edit Property', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CoustColors.primaryPurple)),
          const SizedBox(height: 24),
          ...editOptions.map((option) => Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: CoustColors.veryLightPurple, borderRadius: BorderRadius.circular(8)),
                  child: Icon(option.$2, color: CoustColors.primaryPurple, size: 20),
                ),
                title: Text(option.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(option.$3),
                onTap: () { Navigator.pop(context); option.$4(); },
              ),
              if (option != editOptions.last) const Divider(height: 32),
            ],
          )),
        ],
      ),
    );
  }

  void _showEditDialog(Data property, bool isAdvanced) {
    final controllers = {
      'name': TextEditingController(text: property.propertyName),
      'address': TextEditingController(text: property.address),
      'location': TextEditingController(text: property.location),
    };

    int? selectedCategory = isAdvanced ? (property.category == 1 || property.category == 2 || property.category == 3 ? property.category : 1) : null;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('${isAdvanced ? 'Advanced' : 'Quick'} Edit Property',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CoustColors.primaryPurple)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditTextField(controllers['name']!, 'Property Name', Icons.business,
                      validator: (value) => value?.trim().isEmpty == true ? 'Property name is required' : null),
                  if (isAdvanced) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category', prefixIcon: Icon(Icons.category, color: CoustColors.primaryPurple),
                        border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CoustColors.primaryPurple, width: 2)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Subscribed')),
                        DropdownMenuItem(value: 2, child: Text('Deactivated')),
                        DropdownMenuItem(value: 3, child: Text('UnSubscribed')),
                      ],
                      onChanged: (value) => setState(() => selectedCategory = value!),
                      validator: (value) => value == null ? 'Please select a category' : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildEditTextField(controllers['address']!, 'Address', Icons.location_on, maxLines: 2,
                      validator: (value) => value?.trim().isEmpty == true ? 'Address is required' : null),
                  const SizedBox(height: 16),
                  _buildEditTextField(controllers['location']!, 'Location', Icons.place,
                      validator: (value) => value?.trim().isEmpty == true ? 'Location is required' : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => _handleUpdate(context, property, formKey, controllers, selectedCategory, isAdvanced),
              style: ElevatedButton.styleFrom(backgroundColor: CoustColors.primaryPurple, foregroundColor: Colors.white),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, maxLines: maxLines, validator: validator,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: CoustColors.primaryPurple),
        border: const OutlineInputBorder(), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: CoustColors.primaryPurple, width: 2)),
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context, Data property, GlobalKey<FormState> formKey,
      Map<String, TextEditingController> controllers, int? selectedCategory, bool isAdvanced) async {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(context);

    try {
      await ref.read(propertyNotifierProvider.notifier).updateProperty(
        context, ref, property.propertyId!, controllers['name']!.text.trim(),
        isAdvanced ? selectedCategory : property.category,
        controllers['address']!.text.trim(), null, controllers['location']!.text.trim(),
      );
    } catch (e) {
      if (mounted) _showErrorSnackBar('Failed to update property: ${e.toString()}');
    }
  }

  void _handleEditHall(Data property, String hallName) {
    final hallsList = property.halls?.where((hall) => hall.name == hallName).toList() ?? [];
    if (hallsList.isEmpty) {
      _showErrorSnackBar('Hall data not found');
      return;
    }

    Navigator.pushNamed(context, '/addhall', arguments: {
      'propertyid': property.propertyId, 'propertyname': property.propertyName,
      'isEditing': true, 'hallData': hallsList.first, 'allHallSlots': hallsList,
    }).then((_) => _refreshProperties());
  }

  void _showDeleteConfirmation(BuildContext context, Data property) {
    _showConfirmationDialog(
      context, 'Delete Property', 'Are you sure you want to delete "${property.propertyName}"?',
      'This action cannot be undone and will remove all associated halls and bookings.',
          () => _handleDelete(context, () => ref.read(propertyNotifierProvider.notifier).deleteProperty(context, property.propertyId!)),
    );
  }

  void _showDeleteHallConfirmation(BuildContext context, Hall hall, Data property) {
    _showConfirmationDialog(
      context, 'Delete Hall', 'Are you sure you want to delete "${hall.name}"?',
      'This action cannot be undone.',
          () => _handleDelete(context, () => ref.read(propertyNotifierProvider.notifier).deleteHall(context, hall.hallId!, property.propertyId!)),
    );
  }

  void _showConfirmationDialog(BuildContext context, String title, String message, String subtitle, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 14, color: CoustColors.primaryPurple.withOpacity(0.6)), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, Future<void> Function() deleteFunction) async {
    Navigator.pop(context);
    try {
      await deleteFunction();
      await _refreshProperties();
    } catch (e) {
      print('Delete error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.error, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(message))]),
        backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), duration: const Duration(seconds: 4),
      ),
    );
  }
}