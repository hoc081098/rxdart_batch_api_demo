import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

extension PipeFunction1<T, R> on R Function(T) {
  R2 Function(T) pipe<R2>(R2 Function(R) f) => (T t) => f(this(t));
}

Single<Either<L, R>> retryEitherSingle<L extends Object, R>(
        Single<Either<L, R>> Function() singleFactory,
        [int? count]) =>
    Single.retry(() => singleFactory().map((e) => e.getOrThrow()), count)
        .toEitherSingle((e, s) => e as L);
