
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class GenerateMock{
  Firestore _firestore = Firestore.instance;

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> saveProductMockData(String name,String category,String subCategory,int available,int ordered,int price, String image) async{
    await _firestore.collection('products').add({
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'availableQuantity': available,
      'orderedQuantity': ordered,
      'price': price,
      'image': image
    }).then((value){
      print('Addeed successfully');
    });
  }

  Future<void> saveCategoryMockData(String key, dynamic value) async{
    await _firestore.collection('category').add({
      'categoryName':key,
      'subCategory': value
    });
  }

  void generateProductMockData() async{
   loadAsset('assets/csv/PRODUCTS_MOCK_DATA.csv').then((dynamic output) async{
     List<List<dynamic>> productsdata = const CsvToListConverter().convert(output);
     int i;
     for(i=1;i<productsdata.length;i++){
       String name = productsdata[i][0];
       String category = productsdata[i][1];
       String subCategory = productsdata[i][2];
       var available = productsdata[i][3];
       var ordered = productsdata[i][4];
       var price = productsdata[i][5];
       String image = productsdata[i][6];

       await saveProductMockData(name, category, subCategory, available, ordered, price, image);
     }
   });
  }

  void generateCategoryMockData() async{
    HashMap hashMap = new HashMap<String,dynamic>();
    loadAsset('assets/csv/CATEGORY_MOCK_DATA.csv').then((dynamic output) async{
      List<List<dynamic>> categorydata = const CsvToListConverter().convert(output);
      int i;
      for(i=1;i<categorydata.length;i++){
        String key = categorydata[i][0];
        var value = categorydata.where((test) => test[0] == key).toList();
        hashMap[key] = value;
      }

      for(String key in hashMap.keys){
        List <String> subCategory = List<String>();
        for(var j in hashMap[key]){
          subCategory.add(j[1]);
        }
        await saveCategoryMockData(key, subCategory);
      }
    });
  }
}