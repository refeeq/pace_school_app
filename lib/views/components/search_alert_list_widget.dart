import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/models/admission_det_model.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/custom_text_field.dart';

class DataSearch extends SearchDelegate<String> {
  final List<Grade> _data;
  final List<Grade> _filteredData;

  DataSearch(this._data, this._filteredData);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          Navigator.pop(context);
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _filteredData.clear();
    if (query.isNotEmpty) {
      for (var item in _data) {
        if (item.listValue.contains(query)) {
          _filteredData.add(item);
        }
      }
    }
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _filteredData.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(_filteredData[index].listValue));
      },
    );
  }
}

class SearchAlertListWidget extends StatefulWidget {
  final bool showSearch;
  final String hintText;
  final List<Grade> items;
  final Function(Grade?) callback;
  final TextEditingController searchController;
  const SearchAlertListWidget({
    super.key,
    required this.items,
    required this.hintText,
    required this.callback,
    this.showSearch = true,
    required this.searchController,
  });

  @override
  SearchAlertListWidgetState createState() => SearchAlertListWidgetState();
}

class SearchAlertListWidgetState extends State<SearchAlertListWidget> {
  List<Grade> _filteredItems = [];

  @override
  Widget build(BuildContext context) {
    return CustomtextFormFieldBorder(
      readOnly: true,
      hintText: widget.hintText,
      textEditingController: widget.searchController,
      onTap: () {
        Provider.of<LeaveProvider>(context, listen: false).getLeaveReaonsList();
        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => Center(
              child: Dialog(
                child: widget.showSearch
                    ? Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: widget.searchController,
                              decoration: InputDecoration(
                                hintText: "Search",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: ConstColors.secondary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _filteredItems = widget.items
                                      .where(
                                        (item) => item.listValue
                                            .toLowerCase()
                                            .contains(value.toLowerCase()),
                                      )
                                      .toList();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    widget.callback(_filteredItems[index]);
                                    setState(() {
                                      widget.searchController.text =
                                          _filteredItems[index].listValue;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: _filteredItems.length - 1 == index
                                          ? null
                                          : Border(
                                              bottom: BorderSide(
                                                //                    <--- top side
                                                color: Colors.grey.shade300,
                                                width: 1.0,
                                              ),
                                            ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                        _filteredItems[index].listValue,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              widget.callback(_filteredItems[index]);
                              setState(() {
                                widget.searchController.text =
                                    _filteredItems[index].listValue;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: _filteredItems.length - 1 == index
                                    ? null
                                    : Border(
                                        bottom: BorderSide(
                                          //                    <--- top side
                                          color: Colors.grey.shade300,
                                          width: 1.0,
                                        ),
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text(_filteredItems[index].listValue),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        );
        // showSearch(
        //   context: context,
        //   delegate:
        //       DataSearch(widget.items, widget.searchController, _filteredItems),
        //  );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }
}
