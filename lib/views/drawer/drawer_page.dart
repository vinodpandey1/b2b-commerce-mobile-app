import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/constants/apiCall.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_icons.dart';
import '../../core/routes/app_routes.dart';
import '../../core/components/app_settings_tile.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = getUser();
  }

  void refreshUser() {
    setState(() {
      _futureUser = getUser();
    });
  }

  Future<void> _openExternalUri(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        leading: const AppBackButton(),
        title: const Text('Menu'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              FutureBuilder<User>(
                future: _futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Failed to load user');
                  } else if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  } else {
                    final user = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          // CircleAvatar(
                          //   radius: 30,
                          //   backgroundImage: user.profileImagePath != null &&
                          //           user.profileImagePath!.isNotEmpty
                          //       ? NetworkImage(
                          //           '${ApiConfig.profileImgPath}${user.profileImagePath!.replaceFirst('/uploads/', '')}',
                          //         )
                          //       : const NetworkImage(
                          //           'https://www.pngkit.com/png/detail/281-2812821_user-account-management-logo-user-icon-png.png',
                          //         ),
                          // ),
                          CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  Colors.green[300], // fallback background
                              // backgroundImage: (user.profileImagePath != null &&
                              //         user.profileImagePath!.isNotEmpty)
                              //     ? NetworkImage(
                              //         '${ApiConfig.profileImgPath}${user.profileImagePath!.replaceFirst('/uploads/', '')}',
                              //       )
                              //     : null,
                              // child: (user.profileImagePath == null ||
                              //         user.profileImagePath!.isEmpty)
                              //?
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                              // : null,
                              ),

                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  user.email,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              AppSettingsListTile(
                label: 'Dashboard',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.home),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.profilePage),
              ),
              AppSettingsListTile(
                label: 'Notifications',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.profileNotification),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notificationList),
              ),
              AppSettingsListTile(
                label: 'My Orders',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.voucher),
                onTap: () => Navigator.pushNamed(context, AppRoutes.myOrder),
              ),
              AppSettingsListTile(
                label: 'Payments',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.profilePayment),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.allPaymentPage),
              ),
              AppSettingsListTile(
                label: 'Saved Address',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.location),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.deliveryWidget),
              ),
              AppSettingsListTile(
                label: 'Terms & Conditions',
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.termsAndConditions),
              ),
              AppSettingsListTile(
                label: 'Privacy Policy',
                icons: SvgPicture.asset(AppIcons.dashboardIcon),
                trailing: SvgPicture.asset(AppIcons.right),
                onTap: () => _openExternalUri(
                  Uri.parse(
                    'https://eazysupplies.com/pages?name=website-policy',
                  ),
                ),
              ),
              AppSettingsListTile(
                label: 'Request Account Deletion',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.profileLogout),
                onTap: () => _openExternalUri(
                  Uri(
                    scheme: 'mailto',
                    path: 'info@eazysupplies.com',
                    queryParameters: const {
                      'subject': 'EazySupplies account deletion request',
                      'body':
                          'Please permanently delete my EazySupplies account and associated personal data. My registered email or phone is: ',
                    },
                  ),
                ),
              ),
              AppSettingsListTile(
                label: 'Contact Us',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.contactMap),
                onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
              ),
              const SizedBox(height: AppDefaults.padding * 3),
              AppSettingsListTile(
                label: 'Logout',
                trailing: SvgPicture.asset(AppIcons.right),
                icons: SvgPicture.asset(AppIcons.profileLogout),
                onTap: () async {
                  final success = await logout();

                  if (success) {
                    await ApiClient.cookieJar.deleteAll();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.loginOrSignup,
                      (_) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout failed')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: ShoppingAppBar(
  //       leading: const AppBackButton(),
  //       title: const Text('Menu'),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(AppDefaults.padding),
  //       child: Column(
  //         children: [
  //           FutureBuilder<User>(
  //             future: _futureUser,
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return const Center(child: CircularProgressIndicator());
  //               } else if (snapshot.hasError) {
  //                 return const Text('Failed to load user');
  //               } else if (!snapshot.hasData) {
  //                 return SizedBox.shrink();
  //               } else {
  //                 final user = snapshot.data!;
  //                 return Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 4),
  //                   child: Row(
  //                     children: [
  //                       CircleAvatar(
  //                         radius: 30,
  //                         backgroundImage: user.profileImagePath != null &&
  //                                 user.profileImagePath!.isNotEmpty
  //                             ? NetworkImage(
  //                                 '${ApiConfig.profileImgPath}${user.profileImagePath!.replaceFirst('/uploads/', '')}')
  //                             : const NetworkImage(
  //                                 'https://www.pngkit.com/png/detail/281-2812821_user-account-management-logo-user-icon-png.png'),
  //                       ),
  //                       SizedBox(width: 16),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               user.name ?? 'User',
  //                               style: Theme.of(context)
  //                                   .textTheme
  //                                   .titleMedium
  //                                   ?.copyWith(fontWeight: FontWeight.bold),
  //                             ),
  //                             if (user.email != null)
  //                               Text(
  //                                 user.email!,
  //                                 style: Theme.of(context).textTheme.bodyMedium,
  //                               ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
  //           const Divider(),
  //           AppSettingsListTile(
  //             label: 'Dashboard',
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             icons: SvgPicture.asset(AppIcons.home),
  //             onTap: () => Navigator.pushNamed(context, AppRoutes.profilePage),
  //           ),
  //           AppSettingsListTile(
  //             label: 'Notifications',
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             icons: SvgPicture.asset(AppIcons.profileNotification),
  //             onTap: () =>
  //                 Navigator.pushNamed(context, AppRoutes.notificationList),
  //           ),
  //           AppSettingsListTile(
  //             label: 'My Orders',
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             icons: SvgPicture.asset(AppIcons.voucher),
  //             onTap: () => Navigator.pushNamed(context, AppRoutes.myOrder),
  //           ),
  //           AppSettingsListTile(
  //             label: 'Payments',
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             icons: SvgPicture.asset(AppIcons.profilePayment),
  //             onTap: () => Navigator.pushNamed(context, AppRoutes.faq),
  //           ),
  //           AppSettingsListTile(
  //             label: 'Saved Address',
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             icons: SvgPicture.asset(AppIcons.location),
  //             onTap: () =>
  //                 Navigator.pushNamed(context, AppRoutes.deliveryWidget),
  //           ),
  //           AppSettingsListTile(
  //             label: 'Terms & Conditions',
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             onTap: () =>
  //                 Navigator.pushNamed(context, AppRoutes.termsAndConditions),
  //           ),
  //           AppSettingsListTile(
  //             label: 'Privacy Policy',
  //             icons: SvgPicture.asset(AppIcons.dashboardIcon),
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             // onTap: () => Navigator.pushNamed(context, AppRoutes.),
  //           ),
  //           AppSettingsListTile(
  //             label: 'Contact Us',
  //             trailing: SvgPicture.asset(AppIcons.right),
  //             icons: SvgPicture.asset(AppIcons.contactMap),
  //             onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
  //           ),
  //           SizedBox(height: AppDefaults.padding * 3),
  //           AppSettingsListTile(
  //               label: 'Logout',
  //               trailing: SvgPicture.asset(AppIcons.right),
  //               icons: SvgPicture.asset(AppIcons.profileLogout),
  //               onTap: () async {
  //                 final success = await logout();

  //                 if (success) {
  //                   // Clear local storage if needed
  //                   await ApiClient.cookieJar.deleteAll();

  //                   Navigator.pushNamedAndRemoveUntil(
  //                     context,
  //                     AppRoutes.loginOrSignup,
  //                     (_) => false,
  //                   );
  //                 } else {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('Logout failed')),
  //                   );
  //                 }
  //               }),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
