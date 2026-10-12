import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/network_image.dart';
import '../../core/constants/constants.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04; // 4% of screen width
    final iconSize = width * 0.07; // scalable icon size

    return Scaffold(
      appBar: ShoppingAppBar(
        leading: const AppBackButton(),
        title: const Text('Contact Us'),
      ),
      backgroundColor: AppColors.cardColor,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(padding),
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              /// Title
              Text(
                'Contact Us',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              SizedBox(height: padding * 1.5),

              /// Email
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.contactEmail,
                    width: iconSize,
                    height: iconSize,
                  ),
                  SizedBox(width: padding),
                  Flexible(
                    child: Text(
                      'info@eazysupplies.com',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: padding),

              /// Website
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppIcons.dashboardIcon,
                    width: iconSize,
                    height: iconSize,
                  ),
                  SizedBox(width: padding),
                  Flexible(
                    child: Text(
                      'https://eazysupplies.com',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: padding),

              /// Map Image
              const SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: NetworkImageWithLoader(
                    'https://i.imgur.com/nys3Bxw.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
