class ChildLocationListModel {
  bool? status;
  String? message;
  List<Locations>? locations;

  ChildLocationListModel({this.status, this.message, this.locations});

  ChildLocationListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['locations'] != null) {
      locations = <Locations>[];
      json['locations'].forEach((v) {
        locations!.add(new Locations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Locations {
  int? id;
  String? chuid;
  String? lat;
  String? lon;
  bool? isRead;
  String? time;
  String? createdAt;
  String? updatedAt;

  Locations(
      {this.id,
        this.chuid,
        this.lat,
        this.lon,
        this.isRead,
        this.time,
        this.createdAt,
        this.updatedAt});

  Locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chuid = json['chuid'];
    lat = json['lat'];
    lon = json['lon'];
    isRead = json['is_read'];
    time = json['time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chuid'] = this.chuid;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['is_read'] = this.isRead;
    data['time'] = this.time;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}