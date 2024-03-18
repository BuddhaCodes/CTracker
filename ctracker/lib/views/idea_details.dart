import 'package:ctracker/constant/color.dart';
import 'package:ctracker/models/idea.dart';
import 'package:flutter/material.dart';

class IdeaDetailsPage extends StatelessWidget {
  final int ideaId;

  const IdeaDetailsPage({super.key, required this.ideaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: fetchIdeaFromDatabase(ideaId),
        builder: (BuildContext context, AsyncSnapshot<Idea?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              Idea? idea = snapshot.data;
              if (idea != null) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return buildSingleColumnLayout(idea,
                          true); // Pass true to indicate it's a small screen
                    } else {
                      return buildTwoColumnLayout(idea);
                    }
                  },
                );
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            }
          }
        },
      ),
    );
  }

  Future<Idea?> fetchIdeaFromDatabase(int ideaId) {
    return Future.delayed(const Duration(seconds: 2), () {
      return IdeaData.getById(ideaId);
    });
  }

  Widget buildSingleColumnLayout(Idea idea, bool smallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idea.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ColorConst
                            .textColor, // Using the idea color from the palette
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          idea.category,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .black, // Using the textColor from the palette
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      idea.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors
                            .black, // Using the textColor from the palette
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tags:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .black, // Using the textColor from the palette
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: idea.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white, // Using white for contrast
                            ),
                          ),
                          backgroundColor: ColorConst
                              .tagColor, // Using the idea color from the palette
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTwoColumnLayout(Idea idea) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: buildSingleColumnLayout(
              idea, false), // Pass false to indicate it's not a small screen
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[200],
            child: const Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
