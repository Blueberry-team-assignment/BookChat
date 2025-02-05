import 'dart:convert';
import 'book_model.dart';

List<Book> parseBook(String responseBody){
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Book>((json) => Book.fromJson(json)).toList();
}