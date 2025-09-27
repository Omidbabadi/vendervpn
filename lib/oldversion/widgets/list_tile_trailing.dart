import 'package:flutter/material.dart';

class ListTileTraling extends StatelessWidget {
  const ListTileTraling({
    super.key,
    required this.onDelete,
    //  required this.onShare,
  });
  final void Function() onDelete;
  // final void Function() onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_forever, color: Colors.black),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          /*
          child: IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.share, color: Colors.black),
          ),*/
        ),
      ],
    );
  }
}
