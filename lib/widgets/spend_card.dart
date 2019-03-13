import 'package:broke/models/spend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SpendCard extends StatelessWidget {
  final Spend spend;

  SpendCard({
    this.spend,
  });

  @override
  Widget build(BuildContext context) {

    Padding _buildTitleSection() {
      return Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          // Default value for crossAxisAlignment is CrossAxisAlignment.center.
          // We want to align title and description of recipes left:
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              spend.category,
              style: Theme.of(context).textTheme.title,
            ),
            // Empty space:
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.timer, size: 20.0),
                SizedBox(width: 5.0),
                Text(
                  spend.amount.toString(),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => print("Tapped!"),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // We overlap the image and the button by
              // creating a Stack object:
//              Stack(
//                children: <Widget>[
//                  AspectRatio(
//                    aspectRatio: 16.0 / 9.0,
//                    child: Image.network(
//                      recipe.imageURL,
//                      fit: BoxFit.cover,
//                    ),
//                  ),
//                  Positioned(
//                    child: _buildFavoriteButton(),
//                    top: 2.0,
//                    right: 2.0,
//                  ),
//                ],
//              ),
              _buildTitleSection(),
            ],
          ),
        ),
      ),
    );
  }
}
