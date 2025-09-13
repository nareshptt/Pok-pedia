import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class PokedexScreen extends StatefulWidget {
  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  List<Pokemon> _pokemons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
  }

  Future<void> _fetchPokemons() async {
    final response = await http.get(
      Uri.parse("https://pokeapi.co/api/v2/pokemon?limit=40"),
    );
    if (response.statusCode == 200) {
      final pokeList = json.decode(response.body)['results'];
      setState(() {
        _pokemons = pokeList.map<Pokemon>((e) => Pokemon.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Poképedia",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoading
          ? Center(child: SpinKitFadingCube(color: Colors.redAccent, size: 60))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _pokemons.length,
              itemBuilder: (context, i) {
                return PokemonCard(pokemon: _pokemons[i]);
              },
            ),
    );
  }
}

// Pokémon Entity
class Pokemon {
  final String name;
  final String url;
  String imgUrl;

  Pokemon({required this.name, required this.url, this.imgUrl = ""});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final uri = Uri.parse(json['url']);
    final segments = uri.pathSegments;
    final id = segments[segments.length - 2];
    final img =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    return Pokemon(name: json['name'], url: json['url'], imgUrl: img);
  }
}

// Pokémon Card Widget
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonCard({required this.pokemon});

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: pokemon.name,
              child: Image.network(
                pokemon.imgUrl,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pokémon Detail Screen
class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonDetailScreen({required this.pokemon});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map _details = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final response = await http.get(Uri.parse(widget.pokemon.url));
    if (response.statusCode == 200) {
      setState(() {
        _details = json.decode(response.body);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.redAccent,
        title: Text(
          widget.pokemon.name[0].toUpperCase() +
              widget.pokemon.name.substring(1),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.pokemon.name,
                    child: Image.network(
                      widget.pokemon.imgUrl,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Abilities',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  Wrap(
                    children: List.generate(_details['abilities'].length, (i) {
                      final ability =
                          _details['abilities'][i]['ability']['name'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Chip(
                          label: Text(
                            ability,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.deepOrange,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Types',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  Wrap(
                    children: List.generate(_details['types'].length, (i) {
                      final type = _details['types'][i]['type']['name'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Chip(
                          label: Text(
                            type,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
    );
  }
}
