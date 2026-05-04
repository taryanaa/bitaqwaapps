import 'package:flutter/material.dart';
import 'package:flutter_bittaqwa/data/doa_data.dart';
import 'package:flutter_bittaqwa/utils/color_constant.dart';
import 'package:flutter_bittaqwa/presentation/screen/detail_doa_screen.dart';

class DoaListScreen extends StatelessWidget {
  final String category;

  const DoaListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> doaList = getDoaList(category);

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: ColorConstant.colorPrimary,
        title: Text(
          category,
          style: TextStyle(
            color: ColorConstant.colorWhite,
            fontFamily: "PoppinsMedium",
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: ColorConstant.colorWhite,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: doaList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: ColorConstant.colorWhite,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!,
                    blurRadius: 3.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: ListTile(
                leading: Image.asset(doaList[index]['image']!),
                title: Text(
                  doaList[index]['title']!,
                  style: const TextStyle(fontFamily: "PoppinsMedium"),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailDoaScreen(
                        title:doaList[index]['title']!,
                        arabicText: doaList[index]['arabicText']!,
                        translation: doaList[index]['translation']!,
                        reference: doaList[index]['reference']!
                      )
                    )
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
