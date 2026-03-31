import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_daftar_movie/models/movie.dart';
import 'package:flutter_daftar_movie/screens/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Movie> _favoriteMovies = [];

  Future<void> _loadFavoriteMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> favoriteMovieIds =
        prefs.getStringList('favoriteMovies') ?? [];

    setState(() {
      _favoriteMovies = favoriteMovieIds
          .map((id) {
            final String? movieJson = prefs.getString('movie_$id');
            if (movieJson != null && movieJson.isNotEmpty) {
              final Map<String, dynamic> movieData = jsonDecode(movieJson);
              return Movie.fromJson(movieData);
            }
            return null;
          })
          .where((movie) => movie != null)
          .cast<Movie>()
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  Future<void> _removeFavorite(Movie movie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('movie_${movie.id}');

    List<String> favoriteMovieIds = prefs.getStringList('favoriteMovies') ?? [];
    favoriteMovieIds.remove(movie.id.toString());
    await prefs.setStringList('favoriteMovies', favoriteMovieIds);

    _loadFavoriteMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Movies')),
      body: _favoriteMovies.isEmpty
          ? const Center(child: Text('No favorite movies'))
          : ListView.builder(
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {
                final Movie movie = _favoriteMovies[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(movie.title),
                    subtitle: Text(
                      'Rating: ${movie.voteAverage.toStringAsFixed(1)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFavorite(movie),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(movie: movie),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
