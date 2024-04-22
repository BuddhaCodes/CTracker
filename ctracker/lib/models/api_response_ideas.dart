class ApiResponse<T> {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<T> items;

  ApiResponse({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });
}
