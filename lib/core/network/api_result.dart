sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  const Failure({required this.message, this.statusCode, this.errors});
}
