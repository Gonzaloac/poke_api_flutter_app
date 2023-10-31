import 'package:app_restapi/pokemon_detail_screen.dart';
import 'package:flutter/material.dart';


class SearchResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;

  SearchResultsScreen({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados de la Búsqueda'),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final pokemon = searchResults[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                    ),
                  );
                },
                child: Hero(
                  tag: 'pokemon-${pokemon['name']}',
                  child: Image.network(pokemon['image']),
                ),
              ),
              title: Text(pokemon['name']),
            ),
          );
        },
      ),
    );
  }
}
