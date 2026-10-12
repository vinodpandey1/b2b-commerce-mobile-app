import '../../../core/routes/app_routes.dart';
import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/views/drawer/components/dashboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/constants/apiCall.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = getUser();
  }

  void refreshUser() {
    setState(() {
      _userFuture = getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ShoppingAppBar(
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: true,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF20362A), fontWeight: FontWeight.bold),
            ),
            FutureBuilder<User>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text(
                    'Failed to load profile',
                    style: TextStyle(color: Colors.white),
                  );
                }

                // return UserData(
                //   user: snapshot.data!,
                //   onProfileUpdated: refreshUser, // ✅ key
                // );
                if (snapshot.data!.id == 0) {
                  return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        const Icon(Icons.person_outline,
                            size: 64, color: Color(0xFF168345)),
                        const SizedBox(height: 16),
                        const Text('Welcome to EazySupplies',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text(
                            'Your guest cart is saved on this device. Sign in to place orders and manage your account.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.introLogin),
                            child: const Text('Sign in or create account'))
                      ]));
                }
                return UserDashboard(
                  name: snapshot.data?.name ?? '',
                  email: snapshot.data?.email ?? '',
                  phone: snapshot.data?.phone ?? '',
                  totalOrders: snapshot.data?.ordersCount ?? 0,
                );
              },
            ),
            // const ProfileHeaderOptions(),
          ],
        ),
      ],
    );
  }
}

class UserData extends StatelessWidget {
  final User user;
  final VoidCallback onProfileUpdated;

  const UserData({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('profile image ${user.profileImagePath}');
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showProfileOptions(context),
            child: SizedBox(
              width: 100,
              height: 100,
              child: ClipOval(
                child: NetworkImageWithLoader(
                  user.profileImagePath != null &&
                          user.profileImagePath!.isNotEmpty
                      ? '${ApiConfig.profileImgPath}${user.profileImagePath!.replaceFirst('/uploads/', '')}'
                      : 'https://www.pngkit.com/png/detail/281-2812821_user-account-management-logo-user-icon-png.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDefaults.padding),
          Expanded(
            child: Text(
              user.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- Bottom Sheet ---------------- */

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tile(Icons.visibility, 'View Photo', () {
              Navigator.pop(context);
              _viewProfileImage(context);
            }),
            _tile(Icons.edit, 'Add Photo', () {
              Navigator.pop(context);
              _editProfileImage(context);
            }),
            _tile(Icons.delete, 'Delete Photo', () {
              Navigator.pop(context);
              _confirmDelete(context);
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap,
      {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
    );
  }

  /// ✅ Helper method must be inside the class
  Widget _optionTile({
    required IconData icon,
    required String title,
    Color iconColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  /* ---------------- Actions ---------------- */

  void _viewProfileImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: ShoppingAppBar(title: const Text('Profile Photo')),
          body: Center(
            child: NetworkImageWithLoader(
              user.profileImagePath != null && user.profileImagePath!.isNotEmpty
                  ? '${ApiConfig.profileImgPath}${user.profileImagePath!.replaceFirst('/uploads/', '')}'
                  : 'https://www.pngkit.com/png/detail/281-2812821_user-account-management-logo-user-icon-png.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _editProfileImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _optionTile(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(
                  ImageSource.camera,
                  context,
                  onProfileUpdated, // refresh callback from parent
                );
              },
            ),
            _optionTile(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(
                  ImageSource.gallery,
                  context,
                  onProfileUpdated, // refresh callback from parent
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source, BuildContext context) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80);
      if (file == null) return;

      _showLoader(context);

      final formData = FormData.fromMap({
        'profileImage':
            await MultipartFile.fromFile(file.path, filename: file.name),
      });

      await ApiClient.dio.put('/user/profile-image', data: formData);

      Navigator.pop(context); // loader
      onProfileUpdated(); // ✅ refresh profile

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated')),
      );
    } catch (e) {
      Navigator.pop(context);
      debugPrint('Upload error: $e');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Profile Photo'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiClient.dio.delete('/user/profile-image');
              onProfileUpdated();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Uploading...'),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickAndUploadImage(
  ImageSource source,
  BuildContext context,
  VoidCallback onProfileUpdated, // pass callback to refresh
) async {
  try {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (file == null) return;

    // Show uploading dialog
    _showUploadingDialog(context);

    // Prepare form data
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.name,
      ),
    });

    // Call API to upload
    await ApiClient.dio.post(
      ApiConfig.profileImg,
      data: formData,
    );

    Navigator.pop(context); // close loader

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image updated')),
    );

    // Refresh profile after successful upload
    onProfileUpdated();
  } catch (e) {
    Navigator.pop(context); // close loader if error
    debugPrint('Upload image error: $e');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to upload image')),
    );
  }
}

/// Show a simple "Uploading..." dialog
void _showUploadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Uploading...'),
        ],
      ),
    ),
  );
}

// class UserData extends StatelessWidget {
//   final User user;

//   const UserData({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(AppDefaults.padding),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(width: AppDefaults.padding),

//           /// Profile Image
//           SizedBox(
//             width: 100,
//             height: 100,
//             child: ClipOval(
//               child: AspectRatio(
//                 aspectRatio: 1 / 1,
//                 child: NetworkImageWithLoader(
//                   user.profileImagePath ?? '',
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(width: AppDefaults.padding),

//           /// Text area MUST be Expanded
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user.name,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
