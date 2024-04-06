import 'package:fpdart/fpdart.dart';
import 'package:reddit_app/core/failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
