import 'package:flutter/material.dart';
import 'package:flutter_daftar_movie/models/movie.dart';
import 'package:flutter_daftar_movie/services/api_services.dart';
import 'package:flutter_daftar_movie/screens/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  List<Movie> _filteredResults = [];

  // Filter variables
  int _minYear = 1990;
  int _maxYear = 2025;
  double _minRating = 0;
  double _maxRating = 10;
  
  DateTime _selectedMinDate = DateTime(1990, 1, 1);
  DateTime _selectedMaxDate = DateTime(2025, 12, 31);
  double _selectedMinRating = 0;
  double _selectedMaxRating = 10;
  
  // Filter type selection
  String _yearFilterType = 'all'; // 'all', 'min', 'max', 'range'
  String _ratingFilterType = 'all'; // 'all', 'min', 'max', 'range'
  
  // Text controllers for rating
  late TextEditingController _minRatingController;
  late TextEditingController _maxRatingController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchMovies);
    _minRatingController = TextEditingController(text: '0.0');
    _maxRatingController = TextEditingController(text: '10.0');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minRatingController.dispose();
    _maxRatingController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredResults = _searchResults.where((movie) {
        final releaseDate = DateTime.tryParse(movie.releaseDate) ?? DateTime(1990);
        final rating = movie.voteAverage;
        
        // Year filter logic
        bool yearFilter = true;
        if (_yearFilterType == 'min') {
          yearFilter = releaseDate.isAfter(_selectedMinDate) || 
                      (releaseDate.year == _selectedMinDate.year && 
                       releaseDate.month == _selectedMinDate.month && 
                       releaseDate.day == _selectedMinDate.day);
        } else if (_yearFilterType == 'max') {
          yearFilter = releaseDate.isBefore(_selectedMaxDate) || 
                      (releaseDate.year == _selectedMaxDate.year && 
                       releaseDate.month == _selectedMaxDate.month && 
                       releaseDate.day == _selectedMaxDate.day);
        } else if (_yearFilterType == 'range') {
          yearFilter = releaseDate.isAfter(_selectedMinDate.subtract(const Duration(days: 1))) && 
                      releaseDate.isBefore(_selectedMaxDate.add(const Duration(days: 1)));
        }
        
        // Rating filter logic
        bool ratingFilter = true;
        if (_ratingFilterType == 'min') {
          ratingFilter = rating >= _selectedMinRating;
        } else if (_ratingFilterType == 'max') {
          ratingFilter = rating <= _selectedMaxRating;
        } else if (_ratingFilterType == 'range') {
          ratingFilter = rating >= _selectedMinRating && rating <= _selectedMaxRating;
        }
        
        return yearFilter && ratingFilter;
      }).toList();
    });
  }

  void _showFilterModal() {
    String tempYearFilterType = _yearFilterType;
    String tempRatingFilterType = _ratingFilterType;
    DateTime tempMinDate = _selectedMinDate;
    DateTime tempMaxDate = _selectedMaxDate;
    double tempMinRating = _selectedMinRating;
    double tempMaxRating = _selectedMaxRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.close, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Year Filter Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Rilis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildFilterChip(
                                  label: 'Semua',
                                  isSelected: tempYearFilterType == 'all',
                                  onSelected: () {
                                    setModalState(() {
                                      tempYearFilterType = 'all';
                                    });
                                  },
                                ),
                                _buildFilterChip(
                                  label: 'Dari Tanggal',
                                  isSelected: tempYearFilterType == 'min',
                                  onSelected: () {
                                    setModalState(() {
                                      tempYearFilterType = 'min';
                                    });
                                  },
                                ),
                                _buildFilterChip(
                                  label: 'Sampai Tanggal',
                                  isSelected: tempYearFilterType == 'max',
                                  onSelected: () {
                                    setModalState(() {
                                      tempYearFilterType = 'max';
                                    });
                                  },
                                ),
                                _buildFilterChip(
                                  label: 'Rentang',
                                  isSelected: tempYearFilterType == 'range',
                                  onSelected: () {
                                    setModalState(() {
                                      tempYearFilterType = 'range';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Date Input Based on Type
                            if (tempYearFilterType == 'min') ...[
                              _buildDateInput(
                                label: 'Dari Tanggal',
                                date: tempMinDate,
                                onDateChanged: (date) {
                                  setModalState(() {
                                    tempMinDate = date;
                                  });
                                },
                              ),
                            ] else if (tempYearFilterType == 'max') ...[
                              _buildDateInput(
                                label: 'Sampai Tanggal',
                                date: tempMaxDate,
                                onDateChanged: (date) {
                                  setModalState(() {
                                    tempMaxDate = date;
                                  });
                                },
                              ),
                            ] else if (tempYearFilterType == 'range') ...[
                              _buildDateInput(
                                label: 'Dari Tanggal',
                                date: tempMinDate,
                                onDateChanged: (date) {
                                  setModalState(() {
                                    tempMinDate = date;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDateInput(
                                label: 'Sampai Tanggal',
                                date: tempMaxDate,
                                onDateChanged: (date) {
                                  setModalState(() {
                                    tempMaxDate = date;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Rating Filter Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildFilterChip(
                                  label: 'Semua',
                                  isSelected: tempRatingFilterType == 'all',
                                  onSelected: () {
                                    setModalState(() {
                                      tempRatingFilterType = 'all';
                                    });
                                  },
                                ),
                                _buildFilterChip(
                                  label: 'Rating ≥',
                                  isSelected: tempRatingFilterType == 'min',
                                  onSelected: () {
                                    setModalState(() {
                                      tempRatingFilterType = 'min';
                                    });
                                  },
                                ),
                                _buildFilterChip(
                                  label: 'Rating ≤',
                                  isSelected: tempRatingFilterType == 'max',
                                  onSelected: () {
                                    setModalState(() {
                                      tempRatingFilterType = 'max';
                                    });
                                  },
                                ),
                                _buildFilterChip(
                                  label: 'Rentang',
                                  isSelected: tempRatingFilterType == 'range',
                                  onSelected: () {
                                    setModalState(() {
                                      tempRatingFilterType = 'range';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Rating Input Based on Type
                            if (tempRatingFilterType == 'min') ...[
                              _buildRatingTextInput(
                                label: 'Rating Minimum',
                                value: tempMinRating,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempMinRating = value;
                                  });
                                },
                              ),
                            ] else if (tempRatingFilterType == 'max') ...[
                              _buildRatingTextInput(
                                label: 'Rating Maksimum',
                                value: tempMaxRating,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempMaxRating = value;
                                  });
                                },
                              ),
                            ] else if (tempRatingFilterType == 'range') ...[
                              _buildRatingTextInput(
                                label: 'Rating Dari',
                                value: tempMinRating,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempMinRating = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildRatingTextInput(
                                label: 'Rating Sampai',
                                value: tempMaxRating,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempMaxRating = value;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    tempYearFilterType = 'all';
                                    tempRatingFilterType = 'all';
                                    tempMinDate = DateTime(1990, 1, 1);
                                    tempMaxDate = DateTime(2025, 12, 31);
                                    tempMinRating = 0;
                                    tempMaxRating = 10;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Colors.grey, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _yearFilterType = tempYearFilterType;
                                    _ratingFilterType = tempRatingFilterType;
                                    _selectedMinDate = tempMinDate;
                                    _selectedMaxDate = tempMaxDate;
                                    _selectedMinRating = tempMinRating;
                                    _selectedMaxRating = tempMaxRating;
                                  });
                                  _applyFilters();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Terapkan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildDateInput({
    required String label,
    required DateTime date,
    required Function(DateTime) onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1990),
              lastDate: DateTime(2025, 12, 31),
            );
            if (picked != null && picked != date) {
              onDateChanged(picked);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.calendar_today, color: Colors.blue, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingTextInput({
    required String label,
    required double value,
    required Function(double) onChanged,
  }) {
    TextEditingController controller = TextEditingController(text: value.toStringAsFixed(1));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.0 - 10.0',
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  onChanged: (val) {
                    final ratingValue = double.tryParse(val) ?? 0.0;
                    final clampedValue = ratingValue.clamp(0.0, 10.0);
                    onChanged(clampedValue);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _searchMovies() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults.clear();
        _filteredResults.clear();
      });
      return;
    }

    final List<Map<String, dynamic>> searchData = await _apiService
        .searchMovies(_searchController.text);

    setState(() {
      _searchResults = searchData.map((e) => Movie.fromJson(e)).toList();
    });
    
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Movies')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search movies...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _searchController.text.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults.clear();
                          _filteredResults.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            
            // Filter Button
            if (_searchResults.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showFilterModal,
                  icon: const Icon(Icons.tune),
                  label: const Text('Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            
            // Results
            Expanded(
              child: _filteredResults.isEmpty && _searchResults.isNotEmpty
                  ? const Center(child: Text('No movies match your filters'))
                  : _searchResults.isEmpty
                      ? const Center(child: Text('Search for movies...'))
                      : ListView.builder(
                          itemCount: _filteredResults.length,
                          itemBuilder: (context, index) {
                            final Movie movie = _filteredResults[index];
                            final releaseYear = movie.releaseDate.split('-')[0];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Image.network(
                                  'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey,
                                      child: const Icon(Icons.image),
                                    );
                                  },
                                ),
                                title: Text(movie.title),
                                subtitle: Text('$releaseYear • Rating: ${movie.voteAverage.toStringAsFixed(1)}/10'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailScreen(movie: movie),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
