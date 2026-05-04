import 'package:flutter_bittaqwa/utils/color_constant.dart';
import 'package:flutter/material.dart';

class Time extends StatelessWidget {
  final String pray;
  final String time;
  final String image;
  const Time({
    required this.pray,
    required this.time,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            pray,
            style: TextStyle(
              color: ColorConstant.colorText,
              fontFamily: 'PoppinsMedium',
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            time,
            style: TextStyle(
              color: ColorConstant.colorPrimary,
              fontFamily: 'PoppinsSemiBold',
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Image.asset(
            image,
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}