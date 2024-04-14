import 'package:flutter/material.dart';
import 'package:mobile_shopping_list_app/models/enums/unit-type.dart';
import 'package:mobile_shopping_list_app/models/shopping-list.dart';
import '../services/auth-service.dart';
import '../services/shopping-list-repository.dart';

class ShoppingListProvider extends ChangeNotifier {
  final _shoppingListRepository = ShoppingListRepository();
  final _auth = AuthService();

  final List<ShoppingList> _lists = [];

  List<ShoppingList> get lists => _lists.toList();

  ShoppingList getList(String listId) =>
      _lists.firstWhere((element) => element.id == listId);

  Future<void> fetchLists() async {
    if (_lists.isNotEmpty) return;

    var userId = _auth.currentUser!.uid;
    final lists = await _shoppingListRepository.getAll(userId);

    _lists.clear();
    _lists.addAll(lists);
  }

  Future<void> addShoppingList(String name) async {
    try {
      final shoppingList =
          ShoppingList.create(userId: _auth.currentUser!.uid, name: name);

      await _shoppingListRepository.create(shoppingList);
      _lists.add(shoppingList);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeShoppingList(String listId) async {
    try {
      await _shoppingListRepository.delete(listId);
      _lists.removeWhere((element) => element.id == listId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addItemToShoppingList(
      {required String listId,
      required String name,
      required double quantity,
      required UnitType unityType,
      required String category,
      required String note}) async {
    try {
      final shoppingList = _lists.firstWhere((element) => element.id == listId);
      shoppingList.addItem(
          name: name,
          category: category,
          quantity: quantity,
          unityType: unityType,
          note: note);

      await _shoppingListRepository.update(shoppingList);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeItemFromShoppingList({
    required String listId,
    required String itemName,
  }) async {
    try {
      final shoppingList = _lists.firstWhere((element) => element.id == listId);
      shoppingList.removeItem(itemName);

      await _shoppingListRepository.update(shoppingList);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> completeShoppingList(String id) async {
    try {
      final shoppingList = _lists.firstWhere((element) => element.id == id);
      shoppingList.complete();

      await _shoppingListRepository.update(shoppingList);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> resetShoppingList(String id) async {
    try {
      final shoppingList = _lists.firstWhere((element) => element.id == id);
      shoppingList.reset();

      await _shoppingListRepository.update(shoppingList);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateShoppingListName(String listId, String name) async {
    try {
      final shoppingList = _lists.firstWhere((element) => element.id == listId);
      shoppingList.name = name;

      await _shoppingListRepository.update(shoppingList);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateShoppingItem(
      {required String listId,
      required String previousItemName,
      required String newName,
      required double newQuantity,
      required UnitType newUnityType,
      required String newCategory,
      required String newNote}) async {
    try {
      final shoppingList = _lists.firstWhere((element) => element.id == listId);
      final item = shoppingList.items
          .firstWhere((element) => element.name == previousItemName);

      item.name = newName;
      item.quantity = newQuantity;
      item.unityType = newUnityType;
      item.category = newCategory;
      item.note = newNote;

      await _shoppingListRepository.update(shoppingList);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleItemPurchase(
      String shoppingListId, String itemName) async {
    try {
      final shoppingList =
          _lists.firstWhere((element) => element.id == shoppingListId);
      final item =
          shoppingList.items.firstWhere((element) => element.name == itemName);

      if (item.purchased) {
        item.unPurchase();
      } else {
        item.purchase();
      }

      await _shoppingListRepository.update(shoppingList);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}