import 'package:flutter/material.dart';
import 'package:flutter_bittaqwa/utils/color_constant.dart';

class DetailDoaScreen extends StatelessWidget {
  final String title;
  final String arabicText;
  final String translation;
  final String reference;

  const DetailDoaScreen({
    super.key,
    required this.title,
    required this.arabicText,
    required this.translation,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorPrimary,
        title: Text(
          title,
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
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        decoration: const BoxDecoration(
          image:DecorationImage(
            image: AssetImage('assets/images/bg_detail_doa.png'),
            fit: BoxFit.cover,
          )
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity (0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  )
                ]
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24, 
                      fontFamily: "PoppinsBold",
                      color: ColorConstant.colorText,
                    )
                  ),
                  const SizedBox(height: 16),
                  Text(
                    arabicText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24, 
                      fontFamily: "PoppinsRegular",
                      color: ColorConstant.colorText,
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, 
                      fontFamily: "PoppinsRegular",
                      color: Colors.blue[200],
                    )
                  ),
                  const SizedBox(height: 16),
                  Text(
                    reference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12, 
                      fontFamily: "PoppinsRegular",
                      color: Colors.grey,
                    )
                  ),
                ]
              )
            )
          )
        )
      ),
    );
  }
}
