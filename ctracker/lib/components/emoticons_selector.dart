// import 'package:ctracker/constant/icons.dart';
// import 'package:flutter/material.dart';

// class EmotionSelector extends StatelessWidget {
//   final List<String> emotions = [
//     IconlyC.bandaged,
//     IconlyC.calm,
//     IconlyC.confused,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4, // Adjust the number of icons in a row as needed
//         crossAxisSpacing: 4.0,
//         mainAxisSpacing: 4.0,
//       ),
//       itemCount: emotions.length,
//       itemBuilder: (BuildContext context, int index) {
//         return GestureDetector(
//           onTap: () {
//             // Handle emotion selection here
//             print('Selected emotion: $index');
//           },
//           child: Image.asset(
//             emotions[index],
//             fit: BoxFit.cover,
//           ),
//         );
//       },
//     );
//   }
// }
