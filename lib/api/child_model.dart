class ChildModel {
  bool? status;
  String? message;
  List<Childs>? childs;

  ChildModel({this.status, this.message, this.childs});

  ChildModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['childs'] != null) {
      childs = <Childs>[];
      json['childs'].forEach((v) {
        childs!.add(new Childs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.childs != null) {
      data['childs'] = this.childs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Childs {
  int? id;
  int? pid;
  String? name;
  int? jins;
  int? old;
  String? uid;
  String? createdAt;
  String? updatedAt;

  Childs(
      {this.id,
        this.pid,
        this.name,
        this.jins,
        this.old,
        this.uid,
        this.createdAt,
        this.updatedAt});

  Childs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pid = json['pid'];
    name = json['name'];
    jins = json['jins'];
    old = json['old'];
    uid = json['uid'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pid'] = this.pid;
    data['name'] = this.name;
    data['jins'] = this.jins;
    data['old'] = this.old;
    data['uid'] = this.uid;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}