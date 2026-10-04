import 'package:spiiiq/controllers/contact_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class ContactsScreen extends StatelessWidget {
//   const ContactsScreen({super.key});

//   /// 🔹 Fetch verified status for the user
//   Future<bool> _isUserVerified(String uid) async {
//     try {
//       final doc =
//           await FirebaseFirestore.instance.collection('e-users').doc(uid).get();

//       if (!doc.exists) return false;

//       return doc.data()?['verified'] == true;
//     } catch (e) {
//       print('❌ Error fetching verified status: $e');
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ContactsController controller = Get.put(ContactsController());
//     final ThemeController themeCtrl = Get.find<ThemeController>();

//     String obfuscateEmail(String email) {
//       final parts = email.split('@');
//       if (parts.isEmpty) return email;

//       final name = parts[0];
//       final domain = parts.length > 1 ? '@${parts[1]}' : '';

//       if (name.length <= 4) {
//         final first = name.substring(0, 1);
//         final last = name.length > 1 ? name.substring(name.length - 1) : '';
//         return '$first....$last$domain';
//       }

//       final firstTwo = name.substring(0, 2);
//       final lastTwo = name.substring(name.length - 2);
//       return '$firstTwo....$lastTwo$domain';
//     }

//     return Obx(() {
//       final isDark = themeCtrl.isDarkMode.value;

//       //final users = controller.filteredUsers;

//       // ✅ CREATE A STABLE COPY HERE
//       final users = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
//         controller.filteredUsers,
//       );

//       if (users.isEmpty) {
//         return Center(
//           child: Text(
//             'No users found',
//             style: TextStyle(
//               color: isDark ? Colors.white54 : Colors.black54,
//               fontSize: 16,
//             ),
//           ),
//         );
//       }

//       return Scaffold(
//         backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
//         appBar: AppBar(
//           backgroundColor: isDark ? Colors.black : Colors.white,
//           elevation: 0,
//           iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
//           titleSpacing: 0,
//           title: Obx(() => controller.isSearching.value
//               ? Container(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: TextField(
//                     autofocus: true,
//                     style: TextStyle(
//                         color: isDark ? Colors.white : Colors.black,
//                         fontSize: 16),
//                     decoration: InputDecoration(
//                       hintText: 'Search users...',
//                       hintStyle: TextStyle(
//                           color: isDark ? Colors.grey : Colors.black38),
//                       prefixIcon: Icon(Icons.search,
//                           color: isDark ? Colors.white38 : Colors.black38),
//                       filled: true,
//                       fillColor:
//                           isDark ? Colors.grey.shade900 : Colors.grey.shade200,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 0, horizontal: 12),
//                     ),
//                     onChanged: (v) => controller.searchQuery.value = v,
//                   ),
//                 )
//               : Text(
//                   'Select Users',
//                   style: TextStyle(
//                       color: isDark ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20),
//                 )),
//           actions: [
//             Obx(() => IconButton(
//                   icon: Icon(
//                       controller.isSearching.value ? Icons.close : Icons.search,
//                       color: isDark ? Colors.white : Colors.black),
//                   onPressed: () {
//                     controller.isSearching.toggle();
//                     if (!controller.isSearching.value) {
//                       controller.searchQuery.value = '';
//                     }
//                   },
//                 ))
//           ],
//         ),
//         body: ListView.separated(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//           itemCount: users.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 8),
//           itemBuilder: (_, index) {
//             final userDoc = users[index];
//             final name = controller.getName(userDoc);
//             final email = controller.getEmail(userDoc);
//             final avatar = controller.getAvatar(userDoc);
//             final initial =
//                 name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

//             // Use FutureBuilder for verified badge
//             return FutureBuilder<bool>(
//               future: _isUserVerified(userDoc.id),
//               builder: (context, snapshot) {
//                 final verified = snapshot.data ?? false;

//                 return GestureDetector(
//                   onTap: () {
//                     Get.to(() => ChatScreen(
//                           userId: userDoc.id,
//                           userName: name,
//                         ));
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey.shade900 : Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: isDark
//                               ? Colors.black.withOpacity(0.25)
//                               : Colors.grey.withOpacity(0.15),
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         // Avatar
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             borderRadius: BorderRadius.circular(12),
//                             image: avatar.isNotEmpty
//                                 ? DecorationImage(
//                                     image:
//                                         AssetImage('assets/images/$avatar.png'),
//                                     fit: BoxFit.cover,
//                                   )
//                                 : null,
//                           ),
//                           // child: avatar.isEmpty
//                           //     ? Center(
//                           //         child: Text(
//                           //           name[0].toUpperCase(),
//                           //           style: const TextStyle(
//                           //               color: Colors.white,
//                           //               fontWeight: FontWeight.bold,
//                           //               fontSize: 20),
//                           //         ),
//                           //       )
//                           //     : null,
//                           child: avatar.isEmpty
//                               ? Center(
//                                   child: Text(
//                                     initial,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 20,
//                                     ),
//                                   ),
//                                 )
//                               : null,
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Name + verified badge
//                               Row(
//                                 children: [
//                                   Text(
//                                     name,
//                                     style: TextStyle(
//                                         color: isDark
//                                             ? Colors.white
//                                             : Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   if (verified)
//                                     Image.asset(
//                                       'assets/images/verified.png',
//                                       width: 16,
//                                       height: 16,
//                                     ),
//                                 ],
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 obfuscateEmail(email),
//                                 style: TextStyle(
//                                     color: isDark
//                                         ? Colors.grey.shade400
//                                         : Colors.black54,
//                                     fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.arrow_forward_ios,
//                             size: 16,
//                             color: isDark ? Colors.white38 : Colors.black38),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       );
//     });
//   }
// }

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactsController controller = Get.put(ContactsController());
    final ThemeController themeCtrl = Get.find<ThemeController>();

    String obfuscateEmail(String email) {
      if (email.isEmpty || !email.contains('@')) return '';

      final parts = email.split('@');
      if (parts.length < 2) return '';

      final name = parts[0];
      final domain = parts[1];

      if (name.isEmpty) return '@$domain';

      if (name.length <= 2) {
        return '${name[0]}…@$domain';
      }

      if (name.length <= 4) {
        return '${name[0]}…${name[name.length - 1]}@$domain';
      }

      return '${name.substring(0, 2)}…${name.substring(name.length - 2)}@$domain';
    }

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      // ✅ STABLE SNAPSHOT (CRITICAL)
      final users = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
        controller.filteredUsers,
      );

      // if (users.isEmpty) {
      //   return Center(
      //     child: Text(
      //       'No users found',
      //       style: TextStyle(
      //         color: isDark ? Colors.white54 : Colors.black54,
      //         fontSize: 16,
      //       ),
      //     ),
      //   );
      // }

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          titleSpacing: 0,
          title: Obx(
            () => controller.isSearching.value
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      autofocus: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (v) => controller.searchQuery.value = v,
                    ),
                  )
                : Text(
                    'Select Users',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
          ),
          actions: [
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  controller.isSearching.toggle();
                  if (!controller.isSearching.value) {
                    controller.searchQuery.value = '';
                  }
                },
              ),
            ),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          // itemCount: users.length,
          itemCount: users.isEmpty ? 1 : users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            if (users.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Text(
                  controller.searchQuery.value.trim().isNotEmpty
                      ? 'User not found'
                      : 'No users found',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              );
            }
            final userDoc = users[index];

            final name = controller.getName(userDoc);
            final email = controller.getEmail(userDoc);
            final avatar = controller.getAvatar(userDoc);
            final verified = controller.isVerified(userDoc);

            final initial = name.trim().isNotEmpty
                ? name.trim()[0].toUpperCase()
                : '?';

            return GestureDetector(
              onTap: () {
                // Get.to(
                //   () => ChatScreen(
                //     userId: userDoc.id,
                //     userName: name,
                //   ),
                // );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.25)
                          : Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                        image: avatar.isNotEmpty
                            ? DecorationImage(
                                image: AssetImage('assets/images/$avatar.png'),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatar.isEmpty
                          ? Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (verified)
                                Image.asset(
                                  'assets/images/verified.png',
                                  width: 16,
                                  height: 16,
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            obfuscateEmail(email),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
