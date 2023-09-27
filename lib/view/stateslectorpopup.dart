import 'package:flutter/material.dart';

class StateSelectorPopup extends StatefulWidget {
  final List<String> states;
  final Function(String) onSelect;

  StateSelectorPopup({
    required this.states,
    required this.onSelect,
  });

  @override
  _StateSelectorPopupState createState() => _StateSelectorPopupState();
}

class _StateSelectorPopupState extends State<StateSelectorPopup> {
  late TextEditingController searchController;
  List<String> filteredStates = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    filteredStates.addAll(widget.states);
    searchController.addListener(() {
      filterStates(searchController.text);
    });
  }

  void filterStates(String query) {
    setState(() {
      filteredStates = widget.states
          .where((state) => state.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStates.length,
                itemBuilder: (context, index) {
                  final state = filteredStates[index];
                  return ListTile(
                    title: Text(state),
                    onTap: () {
                      widget.onSelect(state); // Notify the parent widget
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
