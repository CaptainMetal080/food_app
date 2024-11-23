class FoodItem {
  int id;
  String foodName;
  double cost;

  FoodItem(this.foodName, this.cost, {this.id = 0}); // Default ID of 0 for new items

  Map<String, dynamic> toMap() {
    return {
      'food': foodName,
      'cost': cost,
    };
  }
}
