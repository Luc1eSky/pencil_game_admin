// import 'package:flutter/material.dart';
// import 'package:pencil_game_admin/features/experiments/presentation/widgets/app_bar.dart';
//
// import '../domain/experiment.dart';
//
// class ExperimentScreen extends StatelessWidget {
//   const ExperimentScreen({
//     super.key,
//     required this.experiment,
//   });
//
//   final Experiment experiment;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(),
//       body: Container(
//         color: Colors.orange,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 600),
//               child: ListView.separated(
//                 itemCount: experiment.tableCount,
//                 itemBuilder: (context, index) {
//                   index++;
//                   return Card(
//                     child: ListTile(
//                       titleTextStyle: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       title: Text('Table $index'),
//                       contentPadding: const EdgeInsets.all(10.0),
//                       subtitle: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           //color: Colors.green,
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // const Icon(
//                               //   Icons.person,
//                               //   size: 75,
//                               // ),
//                               Column(
//                                 children: [
//                                   Container(
//                                     height: 75,
//                                     width: 75,
//                                     decoration: const BoxDecoration(
//                                       color: Colors.grey,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Center(
//                                         child: Text(
//                                       'P1',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 30,
//                                       ),
//                                     )),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Container(
//                                     height: 40,
//                                     width: 100,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Container(
//                                 height: 140,
//                                 width: 200,
//                                 //color: Colors.pink,
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.brown,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               Column(
//                                 children: [
//                                   const Padding(
//                                     padding: EdgeInsets.zero,
//                                     child: Icon(
//                                       Icons.person,
//                                       size: 75,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Container(
//                                     height: 40,
//                                     width: 100,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) {
//                   return const SizedBox(height: 20);
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
