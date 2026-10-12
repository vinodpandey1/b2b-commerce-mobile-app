class ApiConfig {
  // Base URL
  //static const String baseUrl = 'http://192.168.18.14:3000/api';
  static const String baseUrl = 'https://api.eazysupplies.com/api';
  static const String profileImgPath = '$baseUrl/file?file=';
  // Endpoints
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';
  static const String brands = '$baseUrl/brands';
  static const String login = '$baseUrl/auth/login';
  static const String passwordReset = '$baseUrl/auth/login_auth';
  static const String tagTogetProduct = '$baseUrl/tags?isAllTagOfProducts=ALL';
  static const String address = '$baseUrl/address/getAddress';
  static const String addressPost = '$baseUrl/address';
  static const String userProfile = '$baseUrl/auth/user';
  static const String order = '$baseUrl/orders/getOrder';
  static const String notificationList = '$baseUrl/notifications';
  static const String profileImg = '$baseUrl/file/profileImg';
  static const String payments = '$baseUrl/payments';
  static const String orders = '$baseUrl/orders';
  static const String benepay = '$baseUrl/payments/benePay/getUrl';

  // Timeouts
  static const Duration timeout = Duration(seconds: 15);
}
