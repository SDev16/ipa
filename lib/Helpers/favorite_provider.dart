import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:faap/models/cart_model.dart';

class FavoritesProvider extends ChangeNotifier {
  List<CartItem> _favorites = [];

  List<CartItem> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  bool isFavorite(String name) {
    return _favorites.any((item) => item.name == name);
  }

  void addFavorite(CartItem item) {
    _favorites.add(item);
    notifyListeners();
    _saveFavorites();
  }

  void removeFavorite(String name) {
    _favorites.removeWhere((item) => item.name == name);
    notifyListeners();
    _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getString('favorites') ?? '[]';
    final List<dynamic> favoritesJson = json.decode(favoritesString);

    _favorites = favoritesJson
        .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> favoritesJson =
        _favorites.map((item) => item.toMap()).toList();
    prefs.setString('favorites', json.encode(favoritesJson));
  }
}
