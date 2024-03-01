// import 'package:ctracker/components/dialog.dart';
// import 'package:ctracker/constant/color.dart';
// import 'package:flutter/material.dart';

// class CDrawer extends StatefulWidget {
//   const CDrawer({
//     super.key,
//   });

//   @override
//   State<CDrawer> createState() => _CDrawerState();
// }

// class _CDrawerState extends State<CDrawer> {
//   @override
//   Widget build(BuildContext context) {
//     int _selectedIndex = 0;

//     void _onItemTapped(int index) {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }

//     return Drawer(
//       backgroundColor: ColorConst.drawerBG,
//       child: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).padding.top + 40,
//               ),
//               children: [
//                 _buildListTile(
//                   title: 'Tracker',
//                   icon: _selectedIndex == 0
//                       ? "fitness_app/tab_1s.png"
//                       : "fitness_app/tab_1.png",
//                   onTap: () => _onItemTapped(0),
//                   selected: _selectedIndex == 0,
//                 ),
//                 _buildListTile(
//                   title: 'Pomodoro',
//                   icon: _selectedIndex == 1
//                       ? "fitness_app/tab_3s.png"
//                       : "fitness_app/tab_3.png",
//                   onTap: () => _onItemTapped(1),
//                   selected: _selectedIndex == 1,
//                 ),
//                 _buildListTile(
//                   title: 'Settings',
//                   icon: _selectedIndex == 2
//                       ? "fitness_app/tab_4s.png"
//                       : "fitness_app/tab_4.png",
//                   onTap: () => _onItemTapped(2),
//                   selected: _selectedIndex == 2,
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: Container(
//               color: ColorConst.primary,
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.keyboard_arrow_left, color: Colors.white),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListTile({
//     required String title,
//     required String icon,
//     required VoidCallback onTap,
//     required bool selected,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: ListTile(
//         selectedColor: ColorConst.primary,
//         title: Text(
//           title,
//           selectionColor: ColorConst.drawerTextColor,
//         ),
//         leading: SizedBox(
//           height: 30,
//           width: 30,
//           child: Image.asset(icon),
//         ),
//         selected: selected,
//         onTap: onTap,
//       ),
//     );
//   }
// }
