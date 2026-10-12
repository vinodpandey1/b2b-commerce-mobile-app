import 'package:EazySupplies/views/drawer/notification_page.dart';
import 'package:EazySupplies/views/profile/order/payment_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/views/cart/components/add_edit_address.dart';
import 'package:EazySupplies/views/cart/components/address.dart';
import 'package:EazySupplies/views/menu/brand_product_list_page.dart';
import 'package:EazySupplies/views/profile/order/components/order_view_page.dart';
import 'package:EazySupplies/views/profile/profile_page.dart';

import '../../views/auth/forget_password_page.dart';
import '../../views/auth/intro_login_page.dart';
import '../../views/auth/login_or_signup_page.dart';
import '../../views/auth/login_page.dart';
import '../../views/auth/number_verification_page.dart';
import '../../views/auth/password_reset_page.dart';
import '../../views/auth/sign_up_page.dart';
import '../../views/cart/cart_page.dart';
import '../../views/cart/checkout_page.dart';
import '../../views/drawer/about_us_page.dart';
import '../../views/drawer/contact_us_page.dart';
import '../../views/drawer/drawer_page.dart';
import '../../views/drawer/faq_page.dart';
import '../../views/drawer/help_page.dart';
import '../../views/drawer/terms_and_conditions_page.dart';
import '../../views/entrypoint/entrypoint_ui.dart';
import '../../views/home/bundle_create_page.dart';
import '../../views/home/bundle_details_page.dart';
import '../../views/home/bundle_product_details_page.dart';
import '../../views/home/new_item_page.dart';
import '../../views/home/order_failed_page.dart';
import '../../views/home/order_successfull_page.dart';
import '../../views/home/popular_pack_page.dart';
import '../../views/home/product_details_page.dart';
import '../../views/home/search_result_page.dart';
import '../../views/menu/category_page.dart';
import '../../views/onboarding/onboarding_page.dart';
import '../../views/profile/address/address_page.dart';
import '../../views/profile/address/new_address_page.dart';
import '../../views/profile/coupon/coupon_details_page.dart';
import '../../views/profile/coupon/coupon_page.dart';
import '../../views/profile/order/my_order_page.dart';
import '../../views/profile/order/order_details.dart';
import '../../views/profile/payment_method/add_new_card_page.dart';
import '../../views/profile/payment_method/payment_method_page.dart';
import '../../views/profile/profile_edit_page.dart';
import '../../views/profile/settings/change_password_page.dart';
import '../../views/profile/settings/change_phone_number_page.dart';
import '../../views/profile/settings/language_settings_page.dart';
import '../../views/profile/settings/notifications_settings_page.dart';
import '../../views/profile/settings/settings_page.dart';
import '../../views/review/review_page.dart';
import '../../views/review/submit_review_page.dart';
import '../../views/save/save_page.dart';
import 'app_routes.dart';
import 'unknown_page.dart';
import '../enums/login_type.dart';

class RouteGenerator {
  static Route? onGenerate(RouteSettings settings) {
    final route = settings.name;

    switch (route) {
      case AppRoutes.introLogin:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const IntroLoginPage());

      case AppRoutes.onboarding:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const OnboardingPage());

      case AppRoutes.entryPoint:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const EntryPointUI());

      case AppRoutes.search:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const SearchResultPage());

      case AppRoutes.searchResult:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const SearchResultPage());

      case AppRoutes.cartPage:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const CartPage());

      case AppRoutes.savePage:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const SavePage());

      case AppRoutes.checkoutPage:
        final checkOutList = settings.arguments as List<Map<String, dynamic>>;
        return CupertinoPageRoute(
            settings: settings,
            builder: (_) => CheckoutPage(checkOutList: checkOutList));

      // case AppRoutes.categoryDetails:
      //   return CupertinoPageRoute(settings: settings, builder: (_) => const CategoryProductPage());

      case AppRoutes.categoryDetails:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args != null &&
            args.containsKey('categoryId') &&
            args.containsKey('categoryName')) {
          return CupertinoPageRoute(
            settings: settings,
            builder: (_) => CategoryProductPage(
              categoryId: args['categoryId'] as int,
              categoryName: args['categoryName'] as String,
            ),
          );
        } else {
          // Fallback if arguments are missing
          return CupertinoPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(child: Text('Category not found')),
            ),
          );
        }

      case AppRoutes.brandDetails:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args != null &&
            args.containsKey('brandId') &&
            args.containsKey('brandName')) {
          return CupertinoPageRoute(
            settings: settings,
            builder: (_) => BrandProductPage(
              brandId: args['brandId'] as int,
              brandName: args['brandName'] as String,
            ),
          );
        } else {
          // Fallback if arguments are missing
          return CupertinoPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(child: Text('Brand not found')),
            ),
          );
        }

      // case AppRoutes.login:
      // final loginType = settings.arguments as String;
      //   return CupertinoPageRoute(settings: settings, builder: (_) =>  LoginPage(loginType));

      case AppRoutes.login:
        final loginType = settings.arguments as LoginType? ?? LoginType.email;

        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => LoginPage(loginType: loginType),
        );

      case AppRoutes.signup:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const SignUpPage());

      case AppRoutes.loginOrSignup:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const LoginOrSignUpPage());

      case AppRoutes.numberVerification:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const NumberVerificationPage());

      case AppRoutes.forgotPassword:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const ForgetPasswordPage());

      case AppRoutes.passwordReset:
        final email = settings.arguments as String? ?? '';
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => PasswordResetPage(email: email),
        );

      case AppRoutes.newItems:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const NewItemsPage());

      // case AppRoutes.popularItems:
      //   return CupertinoPageRoute(settings: settings, builder: (_) => const PopularPackPage());

      case AppRoutes.popularItems:
        final args = settings.arguments;
        if (args == null || args is! TagModel) {
          throw Exception('TagModel argument is required for PopularPackPage!');
        }
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => PopularPackPage(tag: args),
        );

      // case AppRoutes.bundleProduct:
      //   return CupertinoPageRoute(settings: settings,
      //       builder: (_) => const BundleProductDetailsPage());

      case AppRoutes.bundleProduct:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args != null && args.containsKey('productId')) {
          return MaterialPageRoute(
            builder: (_) => BundleProductDetailsPage(
              productId: args['productId'] as int,
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Product not found')),
          ),
        );

      case AppRoutes.bundleDetailsPage:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const BundleDetailsPage());

      // case AppRoutes.productDetails:
      //   return CupertinoPageRoute(settings: settings, builder: (_) => const ProductDetailsPage());

      case AppRoutes.productDetails:
        final productId = settings.arguments as int; // extract argument
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => ProductDetailsPage(productId: productId),
        );

      case AppRoutes.createMyPack:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const BundleCreatePage());

      case AppRoutes.orderSuccessfull:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const OrderSuccessfullPage());

      case AppRoutes.orderFailed:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const OrderFailedPage());

      case AppRoutes.myOrder:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const AllOrderPage());

      case AppRoutes.orderView:
        final orderData = settings.arguments;

        if (orderData is! Order) {
          throw Exception('Expected Order argument for OrderViewPage');
        }
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => OrderViewPage(orderData: orderData),
        );

      case AppRoutes.orderDetails:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const OrderDetailsPage());

      case AppRoutes.coupon:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const CouponAndOffersPage());

      case AppRoutes.couponDetails:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const CouponDetailsPage());

      case AppRoutes.profileEdit:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const ProfileEditPage());

      case AppRoutes.newAddress:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const NewAddressPage());

      case AppRoutes.deliveryAddress:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const AddressPage());

      case AppRoutes.deliveryWidget:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const AddressWidget());

      case AppRoutes.addEditAddressPage:
        final args = settings.arguments;
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => AddEditAddressPage(
            existingAddress: args is Address ? args : null,
          ),
        );

      case AppRoutes.notifications:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const NotificationListPage());

      case AppRoutes.settingsNotifications:
        return CupertinoPageRoute(
            settings: settings,
            builder: (_) => const NotificationSettingsPage());

      case AppRoutes.settings:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const SettingsPage());

      case AppRoutes.settingsLanguage:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const LanguageSettingsPage());

      case AppRoutes.changePassword:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const ChangePasswordPage());

      case AppRoutes.changePhoneNumber:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const ChangePhoneNumberPage());

      case AppRoutes.review:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const ReviewPage());

      case AppRoutes.submitReview:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const SubmitReviewPage());

      case AppRoutes.drawerPage:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const DrawerPage());

      case AppRoutes.aboutUs:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const AboutUsPage());

      case AppRoutes.termsAndConditions:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const TermsAndConditionsPage());

      case AppRoutes.faq:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const FAQPage());

      case AppRoutes.help:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const HelpPage());

      case AppRoutes.contactUs:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const ContactUsPage());

      case AppRoutes.paymentMethod:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const PaymentMethodPage());

      case AppRoutes.paymentCardAdd:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const AddNewCardPage());

      case AppRoutes.profilePage:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const ProfilePage());
      case AppRoutes.notificationList:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const NotificationListPage());
      case AppRoutes.allPaymentPage:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => const AllPaymentPage());

      default:
        return errorRoute();
    }
  }

  static Route? errorRoute() =>
      CupertinoPageRoute(builder: (_) => const UnknownPage());
}
