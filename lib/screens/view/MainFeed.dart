import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../bloc/main_feed_bloc.dart';
import '../model/Gener.dart';
import '../model/movie.dart';

class MainFeed extends StatefulWidget {
  const MainFeed({Key? key}) : super(key: key);

  @override
  _MainFeedState createState() => _MainFeedState();
}

class _MainFeedState extends State<MainFeed>
    with AutomaticKeepAliveClientMixin<MainFeed> {
  final _bloc = MainFeedBloc();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc.init();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Movies'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: StreamBuilder<List<Genre>>(
              stream: _bloc.genresStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      final genre = snapshot.data?[index];
                      return GestureDetector(
                        onTap: () {
                          _bloc.changeGenre(genre.name);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Chip(
                            label: Text(genre!.name),
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      );
                    },
                  );


                } else {
                return const CircularProgressIndicator();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 60,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _bloc.search(_searchController.text);
                      String searchTerm = _searchController.text;
                      print('Search Term: $searchTerm');
                      // Perform your search or other actions here
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<List<Movie>>(
              stream: _bloc.moviesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return movieCard(snapshot.data![index]);
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Widget movieCard(Movie movie) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          // Background image
          SizedBox(
            height: 200, // Set the height according to your design
            child: CachedNetworkImage(
              imageUrl: "https://image.tmdb.org/t/p/w500${movie.backdropPath}",
              imageBuilder: (context, imageProvider) =>
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              placeholder: (context, url) =>
                  CachedNetworkImage(
                    imageUrl:
                    "https://image.tmdb.org/t/p/w200${movie.backdropPath}",
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  ),
              errorWidget: (context, url, error) =>
                  Container(
                    color: Colors.transparent,
                  ),
            ),
          ),
          // Movie details
          Container(
            height: 200, // Match the height of the background image
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Release Date: ${movie.releaseDate}',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    Text(
                      '${movie.voteAverage}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
