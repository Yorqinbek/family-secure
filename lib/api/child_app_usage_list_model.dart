class ChildAppUsageListModel {
  bool? status;
  String? message;
  AppsUsage? appsUsage;

  ChildAppUsageListModel({this.status, this.message, this.appsUsage});

  ChildAppUsageListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    appsUsage = json['apps_usage'] != null
        ? new AppsUsage.fromJson(json['apps_usage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.appsUsage != null) {
      data['apps_usage'] = this.appsUsage!.toJson();
    }
    return data;
  }
}

class AppsUsage {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  AppsUsage(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  AppsUsage.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Data {
  int? id;
  String? packageName;
  String? name;
  String? img;
  String? chuid;
  bool? block;
  int? blockTime;
  String? createdAt;
  String? updatedAt;
  int? usageTime;
  String? usageDate;

  Data(
      {this.id,
        this.packageName,
        this.name,
        this.img,
        this.chuid,
        this.block,
        this.blockTime,
        this.createdAt,
        this.updatedAt,
        this.usageTime,
        this.usageDate});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageName = json['package_name'];
    name = json['name'];
    img = json['img'];
    chuid = json['chuid'];
    block = json['block'];
    blockTime = json['block_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    usageTime = json['usage_time'];
    usageDate = json['usage_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['package_name'] = this.packageName;
    data['name'] = this.name;
    data['img'] = this.img;
    data['chuid'] = this.chuid;
    data['block'] = this.block;
    data['block_time'] = this.blockTime;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['usage_time'] = this.usageTime;
    data['usage_date'] = this.usageDate;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}