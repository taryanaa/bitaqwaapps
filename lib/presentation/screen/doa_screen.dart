import 'package:flutter/material.dart';
import 'package:flutter_bittaqwa/presentation/screen/doa_list_screen.dart';
import 'package:flutter_bittaqwa/utils/color_constant.dart';
import 'package:flutter_bittaqwa/presentation/widgets/card_doa.dart';

class DoaScreen extends StatelessWidget {
  const DoaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorPrimary,
        title: Text(
          'Doa-doa',
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
      body: Column(
        children: [
          Image.asset(
            'assets/images/bg_header_doa.png',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisSpacing: 12,
                mainAxisSpacing: 24,
                crossAxisCount: 3,
                children: [
                  CardDoa(
                    image: 'assets/images/ic_doa_pagi_malam.png',
                    title: "Pagi & Malam",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DoaListScreen(category: "Pagi & Malam"),
                        ),
                      );
                    },
                  ),
                  CardDoa(
                    image: 'assets/images/ic_doa_rumah.png',
                    title: "Rumah",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DoaListScreen(category: "Rumah"),
                        ),
                      );
                    },
                  ),
                  CardDoa(
                    image: 'assets/images/ic_doa_makanan_minuman.png',
                    title: "Makanan & Minuman",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoaListScreen(
                              category: "Makanan & Minuman"),
                        ),
                      );
                    },
                  ),
                  CardDoa(
                    image: 'assets/images/ic_doa_perjalanan.png',
                    title: "Perjalanan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DoaListScreen(category: "Perjalanan"),
                        ),
                      );
                    },
                  ),
                  CardDoa(
                    image: 'assets/images/ic_doa_sholat.png',
                    title: "Sholat",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DoaListScreen(category: "Sholat"),
                        ),
                      );
                    },
                  ),
                  CardDoa(
                    image: 'assets/images/ic_doa_etika_baik.png',
                    title: "Etika Baik",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DoaListScreen(category: "Etika Baik"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
