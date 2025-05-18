import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_service.dart';

class PersonDetailPage extends StatefulWidget {
  final int personId;
  final String? initialName;
  final String? initialProfilePath;

  const PersonDetailPage({
    Key? key, 
    required this.personId,
    this.initialName,
    this.initialProfilePath,
  }) : super(key: key);

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  final MovieService _movieService = MovieService();
  late Future<Person> _personDetailsFuture;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadPersonDetails();
  }
  
  @override
  void dispose() {
    _movieService.dispose();
    super.dispose();
  }
  
  void _loadPersonDetails() {
    _personDetailsFuture = _movieService.getPersonDetails(personId: widget.personId);
    _personDetailsFuture.then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = error.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Person>(
        future: _personDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          } else if (snapshot.hasError || _hasError) {
            return _buildErrorView(context);
          } else if (snapshot.hasData) {
            final person = snapshot.data!;
            return _buildPersonDetailView(context, person);
          } else {
            // Fallback to a basic view with the initial data
            return _buildBasicView(context);
          }
        },
      ),
    );
  }
  
  Widget _buildLoadingView() {
    return Stack(
      children: [
        // Show a basic view with the initial data while loading
        _buildBasicView(context),
        
        // Overlay with loading indicator
        Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorView(BuildContext context) {
    return Stack(
      children: [
        // Show a basic view with the initial data
        _buildBasicView(context),
        
        // Error overlay
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading person details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _loadPersonDetails();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBasicView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              widget.initialName ?? 'Loading...',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            background: widget.initialProfilePath != null
                ? Image.network(
                    'https://image.tmdb.org/t/p/w500${widget.initialProfilePath}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.person, size: 50),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Loading person details...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonDetailView(BuildContext context, Person person) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              person.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'person-${person.id}',
                  child: Image.network(
                    person.fullProfilePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.person, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay for better text visibility
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Info Section
                _buildPersonalInfoSection(context, person),
                
                const SizedBox(height: 24),
                
                // Biography Section
                Text(
                  'Biography',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  person.biography?.isNotEmpty == true 
                      ? person.biography! 
                      : 'No biography available.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                // Also Known As Section
                if (person.alsoKnownAs != null && person.alsoKnownAs!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Also Known As',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: person.alsoKnownAs!.map((name) {
                      return Chip(
                        label: Text(name),
                        backgroundColor: Colors.grey[800],
                      );
                    }).toList(),
                  ),
                ],
                
                // External Links
                if (person.imdbId != null || person.homepage != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'External Links',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    children: [
                      if (person.imdbId != null)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.movie),
                          label: const Text('IMDb'),
                          onPressed: () {
                            // Launch IMDb URL
                          },
                        ),
                      if (person.homepage != null)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.language),
                          label: const Text('Official Website'),
                          onPressed: () {
                            // Launch URL
                          },
                        ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPersonalInfoSection(BuildContext context, Person person) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Info',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Known For
            _buildInfoRow(
              context,
              'Known For',
              person.knownForDepartment,
              Icons.work,
            ),
            
            const Divider(height: 24),
            
            // Gender
            _buildInfoRow(
              context,
              'Gender',
              person.genderText,
              Icons.person,
            ),
            
            const Divider(height: 24),
            
            // Birthday
            if (person.birthday != null)
              _buildInfoRow(
                context,
                'Birthday',
                '${person.formattedBirthday} (${person.age})',
                Icons.cake,
              ),
              
            if (person.birthday != null)
              const Divider(height: 24),
            
            // Place of Birth
            if (person.placeOfBirth != null)
              _buildInfoRow(
                context,
                'Place of Birth',
                person.placeOfBirth!,
                Icons.location_on,
              ),
              
            if (person.placeOfBirth != null)
              const Divider(height: 24),
              
            // Popularity
            _buildInfoRow(
              context,
              'Popularity',
              person.popularity.toStringAsFixed(1),
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}