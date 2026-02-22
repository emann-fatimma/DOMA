import 'package:flutter/material.dart';

// 1. YOUR CATEGORIES
final List<Map<String, dynamic>> dummyCategories = [
  {"title": "Living Room", "icon": Icons.weekend},
  {"title": "Bedroom", "icon": Icons.bed},
  {"title": "Office", "icon": Icons.chair_alt},
  {"title": "Decor", "icon": Icons.light},
  {"title": "Kitchen", "icon": Icons.kitchen},
];

// 2. YOUR PRODUCTS (With Vendors and Descriptions)
final List<Map<String, dynamic>> dummyProducts = [
  {
    "id": "1",
    "name": "Emerald Velvet Sofa",
    "category": "Living Room",
    "price": 85000,
    "image": "assets/images/sofa_emerald.png",
    "isAvailable": true,
    "rating": 4.8,
    "vendor": "Luxe Decor",
    "description": "A luxurious emerald green velvet sofa featuring a tufted back and gold-finished metal legs. Perfect for adding a touch of elegance to your modern living room."
  },
  {
    "id": "2",
    "name": "Oak Study Table",
    "category": "Office",
    "price": 22000,
    "image": "assets/images/study_table.png",
    "isAvailable": true,
    "rating": 4.5,
    "vendor": "OfficePro",
    "description": "A sturdy, minimalist oak wood study table with two built-in storage drawers. Designed for maximum productivity and wire management."
  },
  {
    "id": "3",
    "name": "Arched Floor Lamp",
    "category": "Decor",
    "price": 12500,
    "image": "assets/images/floor_lamp.png",
    "isAvailable": true,
    "rating": 4.2,
    "vendor": "Nordic Home",
    "description": "A sleek, modern arched floor lamp with a matte black finish and a heavy marble base. Provides excellent overhead reading light."
  },
  {
    "id": "4",
    "name": "King Size Ottoman Bed",
    "category": "Bedroom",
    "price": 110000,
    "image": "assets/images/king_bed.png",
    "isAvailable": false,
    "rating": 4.9,
    "vendor": "Urban Living",
    "description": "A premium king-size bed featuring a gas-lift ottoman base for hidden under-bed storage. Upholstered in soft grey linen."
  },
  {
    "id": "5",
    "name": "Minimalist Bookshelf",
    "category": "Office",
    "price": 18000,
    "image": "assets/images/bookshelf.png",
    "isAvailable": true,
    "rating": 4.3,
    "vendor": "OfficePro",
    "description": "A 5-tier open bookshelf combining black steel framing with rustic wood panels. Ideal for displaying books, plants, and office decor."
  },
  {
    "id": "6",
    "name": "Marble Dining Table",
    "category": "Kitchen",
    "price": 65000,
    "image": "assets/images/dining_table.png",
    "isAvailable": true,
    "rating": 4.7,
    "vendor": "Luxe Decor",
    "description": "An elegant dining table featuring a thick faux-marble top and a geometric metal base. Comfortably seats up to 6 people."
  },
  {
    "id": "7",
    "name": "Rattan Accent Chair",
    "category": "Living Room",
    "price": 15500,
    "image": "assets/images/accent_chair.png",
    "isAvailable": true,
    "rating": 4.6,
    "vendor": "Nordic Home",
    "description": "A bohemian-style accent chair made from natural handwoven rattan. Lightweight, durable, and comes with a plush white seating cushion."
  },
  {
    "id": "8",
    "name": "Wall Art",
    "category": "Decor",
    "price": 8000,
    "image": "assets/images/wall_art.png",
    "isAvailable": true,
    "rating": 4.0,
    "vendor": "Artify",
    "description": "A set of two abstract canvas wall art pieces featuring warm earth tones. Comes pre-framed in natural oak wood."
  },
  {
    "id": "9",
    "name": "Ceramic Vase Set",
    "category": "Decor",
    "price": 4500,
    "image": "assets/images/vases.png",
    "isAvailable": true,
    "rating": 4.4,
    "vendor": "Urban Living",
    "description": "A matching trio of unglazed ceramic vases in varying heights. Perfect for dried pampas grass or as standalone shelf decor."
  },
  {
    "id": "10",
    "name": "Ergonomic Office Chair",
    "category": "Office",
    "price": 32000,
    "image": "assets/images/office_chair.png",
    "isAvailable": true,
    "rating": 4.8,
    "vendor": "OfficePro",
    "description": "A fully adjustable ergonomic office chair with breathable mesh backing, 3D armrests, and dynamic lumbar support for long working hours."
  },
];