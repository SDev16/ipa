class FoodTrending {
  String? name;         // Name of the food item
  String? review;       // Review for the food item
  double? price;        // Price of the food item
  String? description;  // Description of the food item
  String? imageUrl;     // Image URL for the food item

  FoodTrending({
    this.name,
    this.review,
    this.price,
    this.imageUrl,
  });

  // Factory constructor to create a FoodTrending object from JSON
  FoodTrending.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    review = json['rating'];
    price = (json['price'] ?? 0.0).toDouble(); // Ensure price is double
    imageUrl = json['imageUrl'];
    description = json['description']; // Add description parsing
  }

  String? get id => null; // You may want to include an ID for unique identification

  // Method to convert FoodTrending object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': review,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
