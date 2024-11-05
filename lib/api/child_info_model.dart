class ChildInfoModel {
  bool? status;
  String? message;
  Loc? loc;
  Counts? counts;
  int? online;

  ChildInfoModel({this.status, this.message, this.loc, this.counts,this.online});

  ChildInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    online = json['online'];
    loc = json['loc'] != null ? new Loc.fromJson(json['loc']) : null;
    counts =
    json['counts'] != null ? new Counts.fromJson(json['counts']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['online'] = this.online;
    if (this.loc != null) {
      data['loc'] = this.loc!.toJson();
    }
    if (this.counts != null) {
      data['counts'] = this.counts!.toJson();
    }
    return data;
  }
}

class Loc {
  int? id;
  String? chuid;
  String? lat;
  String? lon;
  bool? isRead;
  String? time;
  String? createdAt;
  String? updatedAt;

  Loc(
      {this.id,
        this.chuid,
        this.lat,
        this.lon,
        this.isRead,
        this.time,
        this.createdAt,
        this.updatedAt});

  Loc.fromJson(Map<String, dynamic> json) {
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

class Counts {
  int? locCount;
  int? callCount;
  int? smsCount;
  int? appCount;
  int? notifCount;
  int? contactCount;
  int? webCount;

  Counts(
      {this.locCount,
        this.callCount,
        this.smsCount,
        this.appCount,
        this.notifCount,
        this.contactCount,
        this.webCount
        });

  Counts.fromJson(Map<String, dynamic> json) {
    locCount = json['loc_count'];
    callCount = json['call_count'];
    smsCount = json['sms_count'];
    appCount = json['app_count'];
    notifCount = json['notif_count'];
    contactCount = json['contact_count'];
    webCount = json['web_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loc_count'] = this.locCount;
    data['call_count'] = this.callCount;
    data['sms_count'] = this.smsCount;
    data['app_count'] = this.appCount;
    data['notif_count'] = this.notifCount;
    data['contact_count'] = this.contactCount;
    data['web_count'] = this.webCount;
    return data;
  }
}