import 'package:flutter/material.dart';
import 'package:flutter_daftar_movie/models/movie.dart';

class DetailScreen extends StatelessWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network('https://image.tmdb.org/t/p/w500${movie.posterPath}'),
            const SizedBox(height: 10),
            Text(
              movie.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(movie.overview, textAlign: TextAlign.justify),
            ),
          ],
        ),
      ),
    );
  }
}
