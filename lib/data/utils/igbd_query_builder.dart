class IgdbQueryBuilder {
  String? _search;
  final List<String> _fields = [];
  String? _where;
  int? _limit;

  IgdbQueryBuilder search(String query) {
    _search = query;
    return this;
  }

  IgdbQueryBuilder fields(List<String> fields) {
    _fields.addAll(fields);
    return this;
  }

  IgdbQueryBuilder where(String condition) {
    _where = condition;
    return this;
  }

  IgdbQueryBuilder limit(int value) {
    _limit = value;
    return this;
  }

  String build() {
    final buffer = StringBuffer();

    if (_search != null) buffer.write('search "$_search"; ');

    if (_fields.isNotEmpty) {
      buffer.write('fields ${_fields.join(", ")}; ');
    } else {
      buffer.write('fields *; ');
    }

    if (_where != null) buffer.write('where $_where; ');
    if (_limit != null) buffer.write('limit $_limit; ');

    return buffer.toString().trim();
  }
}
