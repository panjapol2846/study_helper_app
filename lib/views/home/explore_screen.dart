import 'package:flutter/material.dart';
import 'package:mobile_final/widgets/explore_note_tile.dart';
import 'package:mobile_final/widgets/explore_deck_tile.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Notes'),
              Tab(text: 'Decks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ExploreNoteTile(),
            ExploreDeckTile(),
          ],
        ),
      ),
    );
  }
}
