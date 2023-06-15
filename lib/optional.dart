// ignore_for_file: unnecessary_cast

sealed class Option<T> {
  const Option();

  const factory Option.some(T value) = Some<T>;

  factory Option.none() => _singletonNone as Option<T>;
}

const _singletonNone = None<Never>();

extension ObjectToSome<T> on T {
  Some<T> some() => Some(this);
}

extension NullableObjectToOption<T extends Object> on T? {
  Option<T> toOption() {
    final self = this;
    return self == null ? (_singletonNone as Option<T>) : Some(self);
  }
}

extension OptionExtensions<T> on Option<T> {
  bool get isSome => this is Some<T>;

  bool get isNotEmpty => isSome;

  bool get isNone => this is None<T>;

  bool get isEmpty => isNone;

  Option<T> orElse(Option<T> Function() orElse) => isSome ? this : orElse();

  R fold<R>({
    required R Function(T value) some,
    required R Function() none,
  }) {
    final self = this;
    return switch (self) {
      Some() => some(self.value),
      None() => none(),
    };
  }

  T? valueOrNull() => fold(
        some: (value) => value,
        none: () => null,
      );
}

class Some<T> extends Option<T> {
  final T value;

  const Some(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Some && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some{value: $value}';
}

class None<T> extends Option<T> {
  const None();

  @override
  bool operator ==(Object other) => identical(this, other) || other is None;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';
}
