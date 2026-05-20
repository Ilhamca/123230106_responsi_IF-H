import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/controllers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6FED),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final avatar = controller.avatarFile.value;
            final ImageProvider<Object> imageProvider = avatar != null
                ? FileImage(avatar)
                : const CachedNetworkImageProvider(
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4B8BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 54,
                              backgroundImage: imageProvider,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 4,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _showImageSourceSheet(context, controller),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.camera_alt_rounded, color: Color(0xFF6C63FF), size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        controller.fullName.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.username.value.isEmpty
                            ? 'Loading username...'
                            : '@${controller.username.value}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _InfoCard(
                  icon: Icons.badge_rounded,
                  label: 'NIM',
                  value: controller.nim.value,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.person_rounded,
                  label: 'Username',
                  value: controller.username.value.isEmpty ? 'Not available' : controller.username.value,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.account_circle_rounded,
                  label: 'Full name',
                  value: controller.fullName.value,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    onPressed: () => Get.dialog(
                      AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Do you want to log out of this account?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Get.find<AuthController>().logout(),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, ProfileController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF6C63FF)),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFF6C63FF)),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1F2A37),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
