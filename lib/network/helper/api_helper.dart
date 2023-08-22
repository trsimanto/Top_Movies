import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:topmovies/network/server_information/server_constant.dart';

import '../../screens/model/Gener.dart';
import '../../screens/model/movie.dart';
import '../server_information/server_info.dart';


class ApiHelper {
  Future<List<Genre>> fetchGenres() async {
    final dio = Dio();
    const baseUrl = ServerInfo.baseUrl;
    const token = ServerConstant.token;
    const url = '/genre/movie/list?language=en';
    final dioCacheManager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    dio.interceptors.add(dioCacheManager.interceptor);
    dio.interceptors.add(PrettyDioLogger());


    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await dio.get(
        baseUrl+url,
        options: buildCacheOptions(Duration(days: 7), forceRefresh: false,
            options: Options(headers: headers)),
      );

      if (response.statusCode == 200) {
        final List<Genre> genres = parseGenres(response.data);
        return genres;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Dio error: $error');
    }
  }

  List<Genre> parseGenres(Map<String, dynamic> responseData) {
    final List<dynamic> genreList = responseData['genres'];
    return genreList.map<Genre>((json) => Genre.fromJson(json)).toList();
  }

  Future<List<Movie>> fetchMovies(int page,
      String selectedGener) async {

    final dio = Dio();
    const baseUrl = ServerInfo.baseUrl;
    const token = ServerConstant.token;
    final url = 'discover/movie?include_adult=false&include_video=false&language=en-US&page=$page&sort_by=popularity.desc&with_genres=$selectedGener';
    final dioCacheManager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    dio.interceptors.add(dioCacheManager.interceptor);
    dio.interceptors.add(PrettyDioLogger());

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await dio.get(
        baseUrl+url,
        options: buildCacheOptions(Duration(days: 7), forceRefresh: false,
            options: Options(headers: headers)),
      );

      if (response.statusCode == 200) {
        final List<Movie> movies = parseMovies(response.data);
        return movies;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Dio error: $error');
    }
  }

  List<Movie> parseMovies(Map<String, dynamic> responseData) {
    final List<dynamic> results = responseData['results'];
    return results.map<Movie>((json) => Movie.fromJson(json)).toList();
  }


}


