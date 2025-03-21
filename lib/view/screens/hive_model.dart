import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class AccessoriesModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String brand;

  @HiveField(2)
  String color;

  @HiveField(3)
  String thickness;

  @HiveField(4)
  String coatingMass;

  AccessoriesModel({
    required this.name,
    required this.brand,
    required this.color,
    required this.thickness,
    required this.coatingMass,
  });
}
