import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_bittaqwa/utils/color_constant.dart';

class DetailVideoKajianScreen extends StatefulWidget {
  final String url;
  final String account;
  final String ustadz;
  final String title;
  final String description;
  const DetailVideoKajianScreen({
    super.key,
    required this.url,
    required this.account,
    required this.ustadz,
    required this.title,
    required this.description,
  });

  @override
  State<DetailVideoKajianScreen> createState() =>
      _DetailVideoKajianScreenState();
}

class _DetailVideoKajianScreenState extends State<DetailVideoKajianScreen> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorPrimary,
        title: Text(
          widget.title,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayer(
              controller: _youtubePlayerController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
              onReady: () {
                _youtubePlayerController.addListener(() {
                  setState(() {});
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.account,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'PoppinsRegular',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.ustadz,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.deepOrange,
                  fontFamily: 'PoppinsMedium',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'PoppinsSemiBold',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'PoppinsRegular',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
