//
//  Suggestion.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-24.
//

import SwiftData

@Model
final class Suggestion {
  var id: Int
  var searchKey: String
  var suggestions: [String]
  
  init(id: Int, searchKey: String, suggestions: [String]) {
    self.id = id
    self.searchKey = searchKey
    self.suggestions = suggestions
  }
}

extension Suggestion: DataPreloader {
  static var defaults: [Suggestion] {
    [
      Suggestion(id: 1, searchKey: "mil", suggestions: ["Milk", "Almond Milk", "Soy Milk"]),
      Suggestion(id: 2, searchKey: "milk", suggestions: ["Milk", "Almond Milk", "Soy Milk"]),
      Suggestion(id: 3, searchKey: "bre", suggestions: ["White Bread, Whole Wheat Bread", "Gluten-Free Bread"]),
      Suggestion(id: 4, searchKey: "brea", suggestions: ["White Bread, Whole Wheat Bread", "Gluten-Free Bread"]),
      Suggestion(id: 5, searchKey: "bread", suggestions: ["White Bread, Whole Wheat Bread", "Gluten-Free Bread"]),
      Suggestion(id: 6, searchKey: "app", suggestions: ["Apples", "Apple Juice", "Apple Puree", "Apple Snacks"]),
      Suggestion(id: 7, searchKey: "appl", suggestions: ["Apples", "Apple Juice", "Apple Puree", "Apple Snacks"]),
      Suggestion(id: 8, searchKey: "apple", suggestions: ["Apples", "Apple Juice", "Apple Puree", "Apple Snacks"]),
      Suggestion(id: 9, searchKey: "jui", suggestions: ["Juice", "Apple Juice", "Orange Juice", "Cramberry Juice"]),
      Suggestion(id: 10, searchKey: "juic", suggestions: ["Juice", "Apple Juice", "Orange Juice", "Cramberry Juice"]),
      Suggestion(id: 11, searchKey: "juice", suggestions: ["Juice", "Apple Juice", "Orange Juice", "Cramberry Juice"]),
      
      Suggestion(id: 12, searchKey: "apple j", suggestions: ["Apple Juice", "Apple Juice Concentrated", "Apple Juice Box", "Apple Juice Bottle"]),
      Suggestion(id: 13, searchKey: "ora", suggestions: ["Orange", "Orange Juice", "Orange Marmalade", "Orange Slices"]),
      Suggestion(id: 14, searchKey: "oran", suggestions: ["Orange", "Orange Juice", "Orange Marmalade", "Orange Slices"]),
      Suggestion(id: 15, searchKey: "orange", suggestions: ["Orange", "Orange Juice", "Orange Marmalade", "Orange Slices"]),
      Suggestion(id: 16, searchKey: "cer", suggestions: ["Cereal", "Cereal Bars", "Cereal Bowls"]),
      Suggestion(id: 17, searchKey: "cere", suggestions: ["Cereal", "Cereal Bars", "Cereal Bowls"]),
      Suggestion(id: 18, searchKey: "cereal", suggestions: ["Cereal", "Cereal Bars", "Cereal Bowls"]),
      Suggestion(id: 19, searchKey: "eg", suggestions: ["Eggs", "Egg Whites", "Boiled Eggs", "Scrambled Eggs"]),
      Suggestion(id: 20, searchKey: "egg", suggestions: ["Eggs", "Egg Whites", "Boiled Eggs", "Scrambled Eggs"]),
      Suggestion(id: 21, searchKey: "yog", suggestions: ["Yogurt", "Greek Yogurt", "Low-Fat Yogurt", "Flavored Yogurt"]),
      Suggestion(id: 22, searchKey: "yogu", suggestions: ["Yogurt", "Greek Yogurt", "Low-Fat Yogurt", "Flavored Yogurt"]),
      Suggestion(id: 23, searchKey: "yogurt", suggestions: ["Yogurt", "Greek Yogurt", "Low-Fat Yogurt", "Flavored Yogurt"]),
      Suggestion(id: 24, searchKey: "che", suggestions: ["Cheese", "Cheddar Cheese", "Swiss Cheese", "Cream Cheese"]),
      Suggestion(id: 25, searchKey: "chee", suggestions: ["Cheese", "Cheddar Cheese", "Swiss Cheese", "Cream Cheese"]),
      Suggestion(id: 26, searchKey: "cheese", suggestions: ["Cheese", "Cheddar Cheese", "Swiss Cheese", "Cream Cheese"]),
      Suggestion(id: 27, searchKey: "but", suggestions: ["Butter", "Peanut Butter", "Almond Butter", "Salted Butter"]),
      Suggestion(id: 28, searchKey: "butt", suggestions: ["Butter", "Peanut Butter", "Almond Butter", "Salted Butter"]),
      Suggestion(id: 29, searchKey: "butte", suggestions: ["Butter", "Peanut Butter", "Almond Butter", "Salted Butter"]),
      Suggestion(id: 30, searchKey: "butter", suggestions: ["Butter", "Peanut Butter", "Almond Butter", "Salted Butter"]),
      Suggestion(id: 31, searchKey: "ri", suggestions: ["Rice", "Brown Rice", "Basmati Rice", "Jasmine Rice"]),
      Suggestion(id: 32, searchKey: "ric", suggestions: ["Rice", "Brown Rice", "Basmati Rice", "Jasmine Rice"]),
      Suggestion(id: 33, searchKey: "rice", suggestions: ["Rice", "Brown Rice", "Basmati Rice", "Jasmine Rice"]),
      Suggestion(id: 34, searchKey: "pasta", suggestions: ["Pasta", "Spaghetti", "Macaroni", "Penne"]),
      Suggestion(id: 35, searchKey: "pas", suggestions: ["Pasta", "Spaghetti", "Macaroni", "Penne"]),
      Suggestion(id: 36, searchKey: "past", suggestions: ["Pasta", "Spaghetti", "Macaroni", "Penne"]),
      Suggestion(id: 37, searchKey: "chi", suggestions: ["Chicken", "Chicken Breast", "Chicken Thigh", "Grilled Chicken"]),
      Suggestion(id: 38, searchKey: "chic", suggestions: ["Chicken", "Chicken Breast", "Chicken Thigh", "Grilled Chicken"]),
      Suggestion(id: 39, searchKey: "chick", suggestions: ["Chicken", "Chicken Breast", "Chicken Thigh", "Grilled Chicken"]),
      Suggestion(id: 40, searchKey: "chicke", suggestions: ["Chicken", "Chicken Breast", "Chicken Thigh", "Grilled Chicken"]),
      Suggestion(id: 41, searchKey: "chicken", suggestions: ["Chicken", "Chicken Breast", "Chicken Thigh", "Grilled Chicken"]),
      Suggestion(id: 42, searchKey: "veg", suggestions: ["Vegetables", "Fresh Vegetables", "Frozen Vegetables", "Mixed Vegetables"]),
      Suggestion(id: 43, searchKey: "vege", suggestions: ["Vegetables", "Fresh Vegetables", "Frozen Vegetables", "Mixed Vegetables"]),
      Suggestion(id: 44, searchKey: "veggies", suggestions: ["Vegetables", "Fresh Vegetables", "Frozen Vegetables", "Mixed Vegetables"]),
      Suggestion(id: 45, searchKey: "sal", suggestions: ["Salad", "Salad Mix", "Salad Dressing", "Chicken Salad"]),
      Suggestion(id: 46, searchKey: "sala", suggestions: ["Salad", "Salad Mix", "Salad Dressing", "Chicken Salad"]),
      Suggestion(id: 47, searchKey: "salad", suggestions: ["Salad", "Salad Mix", "Salad Dressing", "Chicken Salad"]),
      Suggestion(id: 48, searchKey: "bev", suggestions: ["Beverages", "Soft Drinks", "Energy Drinks", "Iced Tea"]),
      Suggestion(id: 49, searchKey: "beve", suggestions: ["Beverages", "Soft Drinks", "Energy Drinks", "Iced Tea"]),
      Suggestion(id: 50, searchKey: "beverages", suggestions: ["Beverages", "Soft Drinks", "Energy Drinks", "Iced Tea"]),
      Suggestion(id: 51, searchKey: "snac", suggestions: ["Snacks", "Chips", "Popcorn", "Granola Bars"]),
      Suggestion(id: 52, searchKey: "snack", suggestions: ["Snacks", "Chips", "Popcorn", "Granola Bars"]),
      Suggestion(id: 53, searchKey: "snacks", suggestions: ["Snacks", "Chips", "Popcorn", "Granola Bars"])
    ]
  }
}
