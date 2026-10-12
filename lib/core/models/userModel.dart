class User {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final bool status;
  final String? profileImagePath;
  final DateTime? lastLoginDt;
  final String countryCode;
  final String phone;
  final int otp;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? createdBy;
  final String? wishlist;
  final String? favorite;
  final String? gstn;
  final String? bankDetails;
  final int ordersCount;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.roleId,
      required this.status,
      this.profileImagePath,
      this.lastLoginDt,
      required this.countryCode,
      required this.phone,
      required this.otp,
      required this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.wishlist,
      this.favorite,
      this.gstn,
      this.bankDetails,
      required this.ordersCount});

  // ✅ From API JSON (NULL SAFE)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        roleId: json['roleId'] ?? 0,
        status: json['status'] == true,
        profileImagePath: json['profileImagepath'],
        lastLoginDt: json['lastLoginDt'] != null
            ? DateTime.tryParse(json['lastLoginDt'])
            : null,
        countryCode: json['countryCode']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        otp: json['otp'] ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
        createdBy: json['createdBy'],
        wishlist: json['wishlist'],
        favorite: json['favorite'],
        gstn: json['gstn'],
        bankDetails: json['bankDetails'],
        ordersCount: json['ordersCount']);
  }

  /// ✅ To API JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roleId': roleId,
      'status': status,
      'profileImagepath': profileImagePath,
      'lastLoginDt': lastLoginDt?.toIso8601String(),
      'countryCode': countryCode,
      'phone': phone,
      'otp': otp,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'wishlist': wishlist,
      'favorite': favorite,
      'gstn': gstn,
      'bankDetails': bankDetails,
      'ordersCount': ordersCount
    };
  }

  /// ✅ EMPTY USER (FIXED)
  factory User.empty() {
    return User(
        id: 0,
        name: '',
        email: '',
        roleId: 0,
        status: false,
        countryCode: '',
        phone: '',
        otp: 0,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        ordersCount: 0);
  }
}

class Role {
  final int id;
  final String name;
  final String? permission;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? createdBy;

  Role({
    required this.id,
    required this.name,
    this.permission,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  /// From API JSON
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      permission: json['permission'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['createdBy'],
    );
  }

  /// To API JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permission': permission,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

class Order {
  final int id;
  final int userId;
  final bool approved;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? deliveryAgent;
  final Map<String, dynamic>? jsonData;
  final List<dynamic>? jsonOrderData;
  final String? deliveryAgentAssets;

  /// Optional relations
  final User? user;
  final ShippingModel? shipping;
  final Payment? payment;
  final List<OrderItem> items; // <-- added items

  Order({
    required this.id,
    required this.userId,
    required this.approved,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deliveryAgent,
    this.jsonData,
    this.jsonOrderData,
    this.deliveryAgentAssets,
    this.user,
    this.shipping,
    this.payment,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      //approved: json['approved'] == null ? false : json['approved'] ?? false,
      approved: json['approved'] == true,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      deliveryAgent: json['deliveryAgent'],
      jsonData: json['jsonData'] != null
          ? Map<String, dynamic>.from(json['jsonData'])
          : null,
      jsonOrderData: json['jsonOrderData'] != null
          ? List<dynamic>.from(json['jsonOrderData'])
          : null,
      deliveryAgentAssets: json['deliveryAgentAssets']?.toString(),
      user: json['user'] != null
          ? User.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      shipping: json['shipping'] != null
          ? ShippingModel.fromJson(
              Map<String, dynamic>.from(json['shipping']),
            )
          : null,
      payment: json['payment'] != null
          ? Payment.fromJson(
              Map<String, dynamic>.from(json['payment']),
            )
          : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'approved': approved,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveryAgent': deliveryAgent,
      'jsonData': jsonData,
      'jsonOrderData': jsonOrderData,
      'deliveryAgentAssets': deliveryAgentAssets,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory Order.empty() {
    return Order(
      id: 0,
      userId: 0,
      approved: false,
      status: '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      items: [],
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final int? backlogQuantity;
  final double price;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? productName;

  /// Optional relation
  final Product? product;

  OrderItem(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.quantity,
      this.backlogQuantity,
      required this.price,
      required this.createdAt,
      this.updatedAt,
      this.product,
      this.productName});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? productJson;
    if (json['product'] != null && json['product'] is Map<String, dynamic>) {
      productJson = json['product'] as Map<String, dynamic>;
    }

    return OrderItem(
        id: json['id'] ?? 0,
        orderId: json['orderId'] ?? 0,
        productId: json['productId'] ?? 0,
        quantity: json['quantity'] ?? 0,
        backlogQuantity: json['backlogquantity'] ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
        product: productJson != null ? Product.fromJson(productJson) : null,
        productName: json['productName'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'backlogquantity': backlogQuantity,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'productName': productName.toString()
    };
  }
}

class ShippingModel {
  final int id;
  final int orderId;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final int? deliveryAgent;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assets;

  /// Optional relation
  final Order? order;

  ShippingModel({
    required this.id,
    required this.orderId,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.deliveryAgent,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.assets,
    this.order,
  });

  factory ShippingModel.fromJson(Map<String, dynamic> json) {
    return ShippingModel(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      deliveryAgent: json['deliveryAgent'],
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      assets: json['assets']?.toString(),
      order: json['order'] != null
          ? Order.fromJson(Map<String, dynamic>.from(json['order']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'deliveryAgent': deliveryAgent,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'assets': assets,
    };
  }
}

class Payment {
  final int id;
  final int userId;
  final int orderId;
  final double amount;
  final String? transactionId;
  final String method;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Optional relations
  final User? user;
  final Order? order;

  Payment({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.amount,
    this.transactionId,
    required this.method,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.order,
  });

  /// ✅ COPY WITH
  Payment copyWith({
    int? id,
    int? userId,
    int? orderId,
    double? amount,
    String? transactionId,
    String? method,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    Order? order,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      order: order ?? this.order,
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      orderId: json['orderId'] ?? 0,

      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,

      // nullable in API
      transactionId: json['transectionid']?.toString(),

      // REQUIRED strings → default to ''
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',

      // API uses camelCase, not snake_case
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,

      user: json['user'] != null
          ? User.fromJson(Map<String, dynamic>.from(json['user']))
          : null,

      order: json['order'] != null
          ? Order.fromJson(Map<String, dynamic>.from(json['order']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'amount': amount,
      'transectionid': transactionId,
      'method': method,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final int? categoryId;
  final int? brandId;
  final String? tags;
  final String? sku;
  final String? skuType;
  final int? selfLife; // ✅ FIX
  final String? mfDate;
  final String? expDate;
  final String createdAt;
  final String updatedAt;
  final String? productIcon;
  final String? productImage;
  final int? createdBy; // ✅ FIX
  final String? dimension;
  final String? keyword;
  final int? ordersCount; // ✅ FIX
  final int? tax;
  final String? pkgGwt;
  final String? pkgUnit;
  final double? mrp;
  final double? caseRate;
  final double? unitRate;
  final String? supplier;
  final bool status;
  final dynamic jsonData; // ✅ LIST OR MAP SAFE
  final Category category;
  final Brand brand;
  final List<Supplier> suppliers;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.categoryId,
    this.brandId,
    this.tags,
    this.sku,
    this.skuType,
    this.selfLife,
    this.mfDate,
    this.expDate,
    required this.createdAt,
    required this.updatedAt,
    this.productIcon,
    this.productImage,
    this.createdBy,
    this.dimension,
    this.keyword,
    this.ordersCount,
    this.tax,
    this.pkgGwt,
    this.pkgUnit,
    this.mrp,
    this.caseRate,
    this.unitRate,
    this.supplier,
    required this.status,
    this.jsonData,
    required this.category,
    required this.brand,
    required this.suppliers,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse('${json['price']}') ?? 0,
      stock: int.tryParse('${json['stock']}') ?? 0,
      categoryId: json['categoryId'],
      brandId: json['brandId'],
      tags: json['tags']?.toString(),
      sku: json['sku']?.toString(),
      skuType: json['skuType']?.toString(),
      selfLife: json['selfLife'], // ✅ int
      mfDate: json['mfDate']?.toString(),
      expDate: json['expDate']?.toString(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      productIcon: json['productIcon'],
      productImage: json['productImage'],
      createdBy: json['createdBy'],
      dimension: json['dimension'],
      keyword: json['keyword'],
      ordersCount: json['ordersCount'],
      tax: json['tax'],
      pkgGwt: json['pkgGwt'],
      pkgUnit: json['pkgUnit'],
      mrp: double.tryParse('${json['mrp']}'),
      caseRate: double.tryParse('${json['caseRate']}'),
      unitRate: double.tryParse('${json['unitRate']}'),
      supplier: json['supplier']?.toString(),
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == '1' ||
          json['status'] == 'true',
      jsonData: json['jsonData'], // ✅ LIST SAFE
      category:
          Category.fromJson(Map<String, dynamic>.from(json['category'] ?? {})),
      brand: Brand.fromJson(Map<String, dynamic>.from(json['brand'] ?? {})),
      suppliers: (json['suppliers'] as List<dynamic>? ?? [])
          .map((e) => Supplier.fromJson(e))
          .toList(),
    );
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'categoryId': categoryId,
        'brandId': brandId,
        'tags': tags,
        'sku': sku,
        'skuType': skuType,
        'selfLife': selfLife,
        'mfDate': mfDate,
        'expDate': expDate,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'productIcon': productIcon,
        'productImage': productImage,
        'createdBy': createdBy,
        'dimension': dimension,
        'keyword': keyword,
        'ordersCount': ordersCount,
        'tax': tax,
        'pkgGwt': pkgGwt,
        'pkgUnit': pkgUnit,
        'mrp': mrp,
        'caseRate': caseRate,
        'unitRate': unitRate,
        'supplier': supplier,
        'status': status,
        'jsonData': jsonData,
        'category': category.toJson(),
        'brand': brand.toJson(),
        'suppliers': suppliers.map((e) => e.toJson()).toList(),
      };
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static void empty() {}
}

class Brand {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final String createdAt;
  final String updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: json['image']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'image': image,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static void empty() {}
}

class Supplier {
  final int id;
  final String name;
  final String description;
  final dynamic productList;
  final String gstIn;
  final String address;
  final String pinCode;
  final String city;
  final String phone;
  final String remarks;

  Supplier({
    required this.id,
    required this.name,
    required this.description,
    this.productList,
    required this.gstIn,
    required this.address,
    required this.pinCode,
    required this.city,
    required this.phone,
    required this.remarks,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      productList: json['productList'],
      gstIn: json['gstIn'] as String,
      address: json['address'] as String,
      pinCode: json['pinCode'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      remarks: json['remarks'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'productList': productList,
        'gstIn': gstIn,
        'address': address,
        'pinCode': pinCode,
        'city': city,
        'phone': phone,
        'remarks': remarks,
      };
}

class TagModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<Product> product;

  TagModel(
      {required this.id,
      required this.name,
      required this.slug,
      required this.description,
      required this.createdAt,
      required this.updatedAt,
      required this.product});

  /// ---------------- FROM JSON ----------------
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        description: json['description'] ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
        product: (json['product'] as List<dynamic>?)
                ?.map((e) => Product.fromJson(e))
                .toList() ??
            []);
  }

  /// ---------------- TO JSON ----------------
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'product': product.map((e) => e.toJson()).toList()
      };

  /// ---------------- EMPTY (Optional) ----------------
  factory TagModel.empty() => TagModel(
      id: 0,
      name: '',
      slug: '',
      description: '',
      createdAt: '',
      updatedAt: '',
      product: []);
}

class Address {
  final int id;
  final int userId;
  final String name;
  final String zipcode;
  final String city;
  final String address;
  final String createdAt;
  final String? updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.zipcode,
    required this.city,
    required this.address,
    required this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
      zipcode: json['zipcode'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'zipcode': zipcode,
        'city': city,
        'address': address,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static Address empty() {
    return Address(
      id: 0,
      userId: 0,
      name: '',
      zipcode: '',
      city: '',
      address: '',
      createdAt: '',
      updatedAt: null,
    );
  }
}

class NotificationModel {
  final int id;
  final String name;
  final String? type;
  final dynamic data;
  final String? attachment;
  final String? recepient;
  final bool readStatus;
  final bool sentStatus;
  final String? remarks;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    required this.name,
    this.type,
    this.data,
    this.attachment,
    this.recepient,
    required this.readStatus,
    required this.sentStatus,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      data: json['data'],
      attachment: json['attachment'],
      recepient: json['recepient'],
      readStatus: json['readStatus'] ?? false,
      sentStatus: json['sentStatus'] ?? false,
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class PaymentMethod {
  final String name;
  final String id;

  const PaymentMethod({
    required this.name,
    required this.id,
  });

  static const List<PaymentMethod> values = [
    PaymentMethod(name: 'Online Payment', id: 'NB'),
    PaymentMethod(name: 'Offline Payment', id: 'OFF'),
  ];
}
