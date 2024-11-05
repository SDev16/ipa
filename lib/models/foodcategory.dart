class FoodCategory {
  String? name;
  String? imageUrl;

  FoodCategory({this.name, this.imageUrl});

  FoodCategory.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}