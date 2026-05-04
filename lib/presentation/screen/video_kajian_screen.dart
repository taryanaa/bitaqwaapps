import 'package:flutter/material.dart';
import 'package:flutter_bittaqwa/data/video_data.dart';
import 'package:flutter_bittaqwa/utils/color_constant.dart';
import 'package:flutter_bittaqwa/presentation/screen/detail_video_kajian_screen.dart';

class VideoKajianScreen extends StatelessWidget {
  const VideoKajianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorPrimary,
        title: Text(
          'Video Kajian',
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
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailVideoKajianScreen(
                    url: videos[index]['url']!,
                    account: videos[index]['account']!,
                    ustadz: videos[index]['ustadz']!,
                    title: videos[index]['title']!,
                    description: videos[index]['description']!,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16/9,
                        child: Image.asset(
                          videos[index]['thumbnail']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        top: 0,
                        child: Icon(
                          Icons.play_circle_outline,
                          color: ColorConstant.colorPrimary,
                          size: 60,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      videos[index]['account']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: "PoppinsRegular",
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      videos[index]['ustadz']!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                        fontFamily: "PoppinsMedium",
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      videos[index]['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: "PoppinsSemiBold",
                      ),
                    )
                  ),
                ]
              )
            )
          );
        },
      ),
    );
  }
}
