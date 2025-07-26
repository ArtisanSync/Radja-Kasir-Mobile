import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarImageCache extends StatelessWidget {
  const AvatarImageCache({
    this.url,
    Key? key,
  }) : super(key: key);
  final String? url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: "$url",
      imageBuilder: (context, imageProvider) => Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => Container(
        height: 100,
        width: 100,
        decoration: const BoxDecoration(color: Colors.black12),
        child: const Center(
          child: Icon(Icons.image),
        ),
      ),
    );
  }
}
