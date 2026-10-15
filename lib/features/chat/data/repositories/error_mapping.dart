import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';

/// Runs [body] and converts thrown exceptions into typed failures.
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Success(await body());
  } on NetworkException catch (e) {
    return Err(NetworkFailure(e.message));
  } on ServerException catch (e) {
    return Err(ServerFailure(e.message));
  } catch (e, st) {
    debugPrint('Unexpected error: $e\n$st');
    return const Err(UnexpectedFailure());
  }
}
