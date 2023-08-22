import 'dart:async';
import '../../network/helper/api_helper.dart';
import '../model/Gener.dart';
import '../model/movie.dart';

class MainFeedBloc {
  final ApiHelper _apiHelper = ApiHelper();

  final _genresController = StreamController<List<Genre>>.broadcast();
  Stream<List<Genre>> get genresStream => _genresController.stream;

  final _moviesController = StreamController<List<Movie>>.broadcast();
  Stream<List<Movie>> get moviesStream => _moviesController.stream;

  int _page = 1;
  String _selectedGenre = "Action";

  final List<Movie> _movies = [];
  final List<Genre> _genres = [];

  void init() async {
    _genres.addAll(await _apiHelper.fetchGenres());
    _genresController.sink.add(_genres);

    await _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    final movies = await _apiHelper.fetchMovies(_page, _selectedGenre);
    _movies.addAll(movies);
    _moviesController.sink.add(_movies);
    _page++;
  }

  void changeGenre(String genre) async {
    _selectedGenre = genre;
    _page = 1;
    _movies.clear();
    await _fetchMovies();
  }

  void dispose() {
    _genresController.close();
    _moviesController.close();
  }
}