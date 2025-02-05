import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../services/image_service.dart';
import '../providers/user_profile_provider.dart';
import 'user_avatar_edit.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final VoidCallback onTap;
  final bool isEditable;
  final bool inAppBar;

  const UserAvatar({
    super.key,
    this.size = 64,
    required this.onTap,
    this.isEditable = false,
    this.inAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    
    Widget avatar = profileProvider.profileImage != null
        ? Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: onTap,
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundImage: FileImage(profileProvider.profileImage!),
                ),
              ),
              if (isEditable)
                Positioned(
                  right: 20,
                  bottom: -20,
                  child: Material(
                    color: Colors.transparent,
                    child: AvatarEditMenu(),
                  ),
                ),
            ],
          )
        : FutureBuilder<String?>(
            future: ImageService().getImageBase64(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: onTap,
                    child: snapshot.hasData && snapshot.data != null
                        ? CircleAvatar(
                            radius: size / 2,
                            backgroundImage: MemoryImage(base64Decode(snapshot.data!)),
                          )
                        : Icon(
                            Icons.account_circle_outlined,
                            size: size,
                            color: Colors.grey,
                          ),
                  ),
                  if (isEditable)
                    Positioned(
                      right: 20,
                      bottom: -20,
                      child: Material(
                        color: Colors.transparent,
                        child: AvatarEditMenu(),
                      ),
                    ),
                ],
              );
            },
          );

    if (!inAppBar) {
      avatar = Center(
        child: SizedBox(
          width: size + 200,
          height: size + 60,
          child: avatar,
        ),
      );
    }

    return avatar;
  }
}