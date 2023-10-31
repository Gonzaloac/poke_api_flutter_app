import 'package:flutter/material.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pokemon;

  PokemonDetailScreen({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon['name']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Hero(
                tag: 'pokemon-${pokemon['name']}',
                child: Container(
                  width: 200, // Ancho deseado
                  height: 200, // Alto deseado
                  decoration: BoxDecoration(
                    color: Colors.white, // Color de fondo del contenedor
                    borderRadius: BorderRadius.circular(10), // Bordes redondeados
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Sombra de color gris
                        spreadRadius: 1, // Radio de propagación de la sombra
                        blurRadius: 4, // Desenfoque de la sombra
                        offset: Offset(0, 2), // Desplazamiento de la sombra (eje X, eje Y)
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      pokemon['image'],
                      fit: BoxFit.cover, // Ajuste la imagen al tamaño del contenedor
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              pokemon['name'],
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
