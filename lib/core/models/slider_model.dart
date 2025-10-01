// To parse this JSON data, do
//
//     final sliderModel = sliderModelFromJson(jsonString);

import 'dart:convert';

SliderModel? sliderModelFromJson(String str) =>
    SliderModel.fromJson(json.decode(str));

String sliderModelToJson(SliderModel? data) => json.encode(data!.toJson());

class SliderModel {
  final String? id;

  final String? sliderUrl;
  final String? page;
  final dynamic webUrl;
  SliderModel({
    required this.id,
    required this.sliderUrl,
    required this.page,
    required this.webUrl,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
        id: json["id"],
        sliderUrl: json["slider_url"],
        page: json["page"],
        webUrl: json["web_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slider_url": sliderUrl,
        "page": page,
        "web_url": webUrl,
      };
}
