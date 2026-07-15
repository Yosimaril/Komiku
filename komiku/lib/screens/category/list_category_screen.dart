import 'package:flutter/material.dart';

class ListCategoryScreen extends StatefulWidget {
  const ListCategoryScreen({super.key});

  @override
  State<ListCategoryScreen> createState() => _ListCategoryScreenState();
}

class _ListCategoryScreenState extends State<ListCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// import '../../models/category.dart';
// import '../../services/api_service.dart';
// import '../comic_list_screen.dart';
//
// class ListCategoryScreen extends StatefulWidget {
//   const ListCategoryScreen({super.key});
//
//   @override
//   State<ListCategoryScreen> createState() => _ListCategoryScreenState();
// }
//
// class _ListCategoryScreenState extends State<ListCategoryScreen> {
//   late Future<List<Category>> _futureCategories;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//       ),
//       body: FutureBuilder<List<Category>>(
//         future: _futureCategories,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState != ConnectionState.done) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Failed to load categories: ${snapshot.error}'));
//           }
//           final categories = snapshot.data ?? const [];
//           if (categories.isEmpty) {
//             return const Center(child: Text('No categories found'));
//           }
//
//           return Padding(
//             padding: const EdgeInsets.all(12),
//             child: GridView.builder(
//               itemCount: categories.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 1.1,
//               ),
//               itemBuilder: (context, index) {
//                 final c = categories[index];
//                 return InkWell(
//                   borderRadius: BorderRadius.circular(12),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ComicListWidget(categoryId: c.id, categoryName: c.name),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           c.name,
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         if (c.description != null && c.description!.isNotEmpty)
//                           const SizedBox(height: 6),
//                         if (c.description != null && c.description!.isNotEmpty)
//                           Text(
//                             c.description!,
//                             style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
