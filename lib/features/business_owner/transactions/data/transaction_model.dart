class TransactionModel {
  String? next;
  String? previous;
  Results? results;

  TransactionModel({this.next, this.previous, this.results});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    next = json['next'];
    previous = json['previous'];
    results =
    json['results'] != null ? Results.fromJson(json['results']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['next'] = next;
    data['previous'] = previous;
    if (results != null) {
      data['results'] = results!.toJson();
    }
    return data;
  }
}

class Results {
  String? status;
  List<Transaction>? data;

  Results({this.status, this.data});

  Results.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Transaction>[];
      json['data'].forEach((v) {
        data!.add(Transaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transaction {
  int? id;
  String? transactionType;
  int? payment;
  int? refund;
  int? user;
  int? shop;
  String? shopName;
  int? slot;
  String? slotTime;
  int? service;
  String? serviceTitle;
  String? amount;
  String? currency;
  String? status;
  String? createdAt;
  String? userName; // New field for user's name
  String? userEmail; // New field for user's email

  Transaction(
      {this.id,
        this.transactionType,
        this.payment,
        this.refund,
        this.user,
        this.shop,
        this.shopName,
        this.slot,
        this.slotTime,
        this.service,
        this.serviceTitle,
        this.amount,
        this.currency,
        this.status,
        this.createdAt,
        this.userName,
        this.userEmail});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionType = json['transaction_type'];
    payment = json['payment'];
    refund = json['refund'];
    user = json['user'];
    shop = json['shop'];
    shopName = json['shop_name'];
    slot = json['slot'];
    slotTime = json['slot_time'];
    service = json['service'];
    serviceTitle = json['service_title'];
    amount = json['amount'];
    currency = json['currency'];
    status = json['status'];
    createdAt = json['created_at'];
    userName = json['user_name']; // Parsing user's name
    userEmail = json['user_email']; // Parsing user's email
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_type'] = transactionType;
    data['payment'] = payment;
    data['refund'] = refund;
    data['user'] = user;
    data['shop'] = shop;
    data['shop_name'] = shopName;
    data['slot'] = slot;
    data['slot_time'] = slotTime;
    data['service'] = service;
    data['service_title'] = serviceTitle;
    data['amount'] = amount;
    data['currency'] = currency;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['user_name'] = userName; // Including user's name
    data['user_email'] = userEmail; // Including user's email
    return data;
  }
  
}