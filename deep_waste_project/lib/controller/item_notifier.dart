import 'dart:collection';
import 'package:deep_waste/models/Item.dart';
import 'package:flutter/material.dart';

class ItemNotifier extends ChangeNotifier {
  List<Item> _items = [
    Item(
        id: "1001",
        name: "Cardboard",
        imageURL: "assets/images/cardboard.png",
        count: 0,
        points: 36),
    Item(
        id: "1004",
        name: "Paper",
        count: 0,
        imageURL: "assets/images/paper.png",
        points: 38),
    Item(
        id: "1002",
        name: "Glass",
        count: 0,
        imageURL: "assets/images/glass.png",
        points: 3),
    Item(
        id: "1003",
        name: "Metal",
        count: 0,
        imageURL: "assets/images/metal.png",
        points: 68),
    Item(
        id: "1005",
        name: "Plastic",
        count: 0,
        imageURL: "assets/images/plastic.png",
        points: 18),
    Item(
        id: "1006",
        name: "Trash",
        count: 2,
        imageURL: "assets/images/trash.png",
        points: 35)
  ];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  Item getCollectedItem() {
    // Returning a default item or empty item if none found
    return _items.firstWhere(
      (_item) => _item.count > 0, 
      orElse: () => Item(id: "", name: "No Item", count: 0, imageURL: "", points: 0)
    );
  }

  void updateCount(String itemName) {
    // Fixing this by checking if the item exists
    var matchedItem = _items.firstWhere(
      (_item) => _item.name.toLowerCase() == itemName, 
      orElse: () => Item(id: "", name: "Not Found", count: 0, imageURL: "", points: 0)
    );
    
    // Only update count if item is found
    if (matchedItem.id.isNotEmpty) {
      matchedItem.count = matchedItem.count + 1;
      notifyListeners();
    }
  }
}
