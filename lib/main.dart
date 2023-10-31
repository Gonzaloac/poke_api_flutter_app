import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pokemon_detail_screen.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class CustomSearch extends SearchDelegate<Map<String, dynamic>> {
  final List<Map<String, dynamic>> data;

  CustomSearch(this.data);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

@override
Widget buildLeading(BuildContext context) {
  return IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}


  @override
  Widget buildResults(BuildContext context) {
    final results = data.where((pokemon) {
      return pokemon['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text('No se encontraron resultados.'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final pokemon = results[index];
        return ListTile(
          leading: Image.network(pokemon['image']),
          title: Text(pokemon['name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemonDetailScreen(pokemon: pokemon),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchPokemonNames(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final suggestions = snapshot.data;

          if (suggestions == null || suggestions.isEmpty) {
            return Center(
              child: Text('No se encontraron resultados.'),
            );
          } else {
            final filteredData = data.where((pokemon) {
              final name = pokemon['name'].toLowerCase();
              return suggestions.any((query) => name.contains(query.toLowerCase()));
            }).toList();

            return ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final pokemon = filteredData[index];
                return ListTile(
                  leading: Image.network(pokemon['image']),
                  title: Text(pokemon['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                      ),
                    );
                  },
                );
              },
            );
          }
        }
      },
    );
  }
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> pokemonData = [];
  int currentPage = 1;
  int itemsPerPage = 25;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        currentPage++;
        fetchData();
      }
    });
    fetchData();
  }

  Future<void> fetchData() async {
    String apiUrl = 'https://pokeapi.co/api/v2/pokemon?limit=$itemsPerPage&offset=${(currentPage - 1) * itemsPerPage}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      for (var result in results) {
        final name = result['name'];
        final detailsResponse = await http.get(Uri.parse(result['url']));
        final detailsData = json.decode(detailsResponse.body);
        final imageUrl = detailsData['sprites']['front_default'];
        pokemonData.add({
          'name': name,
          'image': imageUrl,
        });
      }

      setState(() {});
    } else {
      print('Error al obtener datos de la API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Pokémon List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final selectedPokemon = await showSearch(
                context: context,
                delegate: CustomSearch(pokemonData),
              );

              // Cuando se cierra la búsqueda, puedes realizar acciones con selectedPokemon si es necesario.
            },
          ),
        ],
      ),
       body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos columnas
          crossAxisSpacing: 8, // Espacio horizontal entre elementos
          mainAxisSpacing: 8, // Espacio vertical entre elementos
        ),
        itemCount: pokemonData.length,
        itemBuilder: (context, index) {
          final pokemon = pokemonData[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
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
                child: Image.network(
                  pokemon['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),


    );
  }
}

Future<List<String>> fetchPokemonNames(String query) async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1000'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'] as List<dynamic>;

    final names = results
        .where((result) {
          if (result is Map<String, dynamic> && result['name'] is String && query is String) {
            final name = result['name'].toString();
            return name.toLowerCase().contains(query.toLowerCase());
          }
          return false;
        })
        .map((result) => result['name'].toString())
        .toList();

    return names;
  } else {
    throw Exception('Failed to load Pokémon names');
  }
}

