// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fitness_trainer_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FitnessDashboardModel {

@JsonKey(name: 'weekly_schedule') WeeklySchedule get schedule; Revenue get revenue; Packages get packages;@JsonKey(name: 'shop_settings') ShopSettings get shopSettings;
/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FitnessDashboardModelCopyWith<FitnessDashboardModel> get copyWith => _$FitnessDashboardModelCopyWithImpl<FitnessDashboardModel>(this as FitnessDashboardModel, _$identity);

  /// Serializes this FitnessDashboardModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FitnessDashboardModel&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.packages, packages) || other.packages == packages)&&(identical(other.shopSettings, shopSettings) || other.shopSettings == shopSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schedule,revenue,packages,shopSettings);

@override
String toString() {
  return 'FitnessDashboardModel(schedule: $schedule, revenue: $revenue, packages: $packages, shopSettings: $shopSettings)';
}


}

/// @nodoc
abstract mixin class $FitnessDashboardModelCopyWith<$Res>  {
  factory $FitnessDashboardModelCopyWith(FitnessDashboardModel value, $Res Function(FitnessDashboardModel) _then) = _$FitnessDashboardModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'weekly_schedule') WeeklySchedule schedule, Revenue revenue, Packages packages,@JsonKey(name: 'shop_settings') ShopSettings shopSettings
});


$WeeklyScheduleCopyWith<$Res> get schedule;$RevenueCopyWith<$Res> get revenue;$PackagesCopyWith<$Res> get packages;$ShopSettingsCopyWith<$Res> get shopSettings;

}
/// @nodoc
class _$FitnessDashboardModelCopyWithImpl<$Res>
    implements $FitnessDashboardModelCopyWith<$Res> {
  _$FitnessDashboardModelCopyWithImpl(this._self, this._then);

  final FitnessDashboardModel _self;
  final $Res Function(FitnessDashboardModel) _then;

/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schedule = null,Object? revenue = null,Object? packages = null,Object? shopSettings = null,}) {
  return _then(_self.copyWith(
schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as WeeklySchedule,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Revenue,packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as Packages,shopSettings: null == shopSettings ? _self.shopSettings : shopSettings // ignore: cast_nullable_to_non_nullable
as ShopSettings,
  ));
}
/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyScheduleCopyWith<$Res> get schedule {
  
  return $WeeklyScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueCopyWith<$Res> get revenue {
  
  return $RevenueCopyWith<$Res>(_self.revenue, (value) {
    return _then(_self.copyWith(revenue: value));
  });
}/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackagesCopyWith<$Res> get packages {
  
  return $PackagesCopyWith<$Res>(_self.packages, (value) {
    return _then(_self.copyWith(packages: value));
  });
}/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopSettingsCopyWith<$Res> get shopSettings {
  
  return $ShopSettingsCopyWith<$Res>(_self.shopSettings, (value) {
    return _then(_self.copyWith(shopSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [FitnessDashboardModel].
extension FitnessDashboardModelPatterns on FitnessDashboardModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FitnessDashboardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FitnessDashboardModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FitnessDashboardModel value)  $default,){
final _that = this;
switch (_that) {
case _FitnessDashboardModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FitnessDashboardModel value)?  $default,){
final _that = this;
switch (_that) {
case _FitnessDashboardModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'weekly_schedule')  WeeklySchedule schedule,  Revenue revenue,  Packages packages, @JsonKey(name: 'shop_settings')  ShopSettings shopSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FitnessDashboardModel() when $default != null:
return $default(_that.schedule,_that.revenue,_that.packages,_that.shopSettings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'weekly_schedule')  WeeklySchedule schedule,  Revenue revenue,  Packages packages, @JsonKey(name: 'shop_settings')  ShopSettings shopSettings)  $default,) {final _that = this;
switch (_that) {
case _FitnessDashboardModel():
return $default(_that.schedule,_that.revenue,_that.packages,_that.shopSettings);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'weekly_schedule')  WeeklySchedule schedule,  Revenue revenue,  Packages packages, @JsonKey(name: 'shop_settings')  ShopSettings shopSettings)?  $default,) {final _that = this;
switch (_that) {
case _FitnessDashboardModel() when $default != null:
return $default(_that.schedule,_that.revenue,_that.packages,_that.shopSettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FitnessDashboardModel implements FitnessDashboardModel {
  const _FitnessDashboardModel({@JsonKey(name: 'weekly_schedule') required this.schedule, required this.revenue, required this.packages, @JsonKey(name: 'shop_settings') required this.shopSettings});
  factory _FitnessDashboardModel.fromJson(Map<String, dynamic> json) => _$FitnessDashboardModelFromJson(json);

@override@JsonKey(name: 'weekly_schedule') final  WeeklySchedule schedule;
@override final  Revenue revenue;
@override final  Packages packages;
@override@JsonKey(name: 'shop_settings') final  ShopSettings shopSettings;

/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FitnessDashboardModelCopyWith<_FitnessDashboardModel> get copyWith => __$FitnessDashboardModelCopyWithImpl<_FitnessDashboardModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FitnessDashboardModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FitnessDashboardModel&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.packages, packages) || other.packages == packages)&&(identical(other.shopSettings, shopSettings) || other.shopSettings == shopSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schedule,revenue,packages,shopSettings);

@override
String toString() {
  return 'FitnessDashboardModel(schedule: $schedule, revenue: $revenue, packages: $packages, shopSettings: $shopSettings)';
}


}

/// @nodoc
abstract mixin class _$FitnessDashboardModelCopyWith<$Res> implements $FitnessDashboardModelCopyWith<$Res> {
  factory _$FitnessDashboardModelCopyWith(_FitnessDashboardModel value, $Res Function(_FitnessDashboardModel) _then) = __$FitnessDashboardModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'weekly_schedule') WeeklySchedule schedule, Revenue revenue, Packages packages,@JsonKey(name: 'shop_settings') ShopSettings shopSettings
});


@override $WeeklyScheduleCopyWith<$Res> get schedule;@override $RevenueCopyWith<$Res> get revenue;@override $PackagesCopyWith<$Res> get packages;@override $ShopSettingsCopyWith<$Res> get shopSettings;

}
/// @nodoc
class __$FitnessDashboardModelCopyWithImpl<$Res>
    implements _$FitnessDashboardModelCopyWith<$Res> {
  __$FitnessDashboardModelCopyWithImpl(this._self, this._then);

  final _FitnessDashboardModel _self;
  final $Res Function(_FitnessDashboardModel) _then;

/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schedule = null,Object? revenue = null,Object? packages = null,Object? shopSettings = null,}) {
  return _then(_FitnessDashboardModel(
schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as WeeklySchedule,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as Revenue,packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as Packages,shopSettings: null == shopSettings ? _self.shopSettings : shopSettings // ignore: cast_nullable_to_non_nullable
as ShopSettings,
  ));
}

/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyScheduleCopyWith<$Res> get schedule {
  
  return $WeeklyScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueCopyWith<$Res> get revenue {
  
  return $RevenueCopyWith<$Res>(_self.revenue, (value) {
    return _then(_self.copyWith(revenue: value));
  });
}/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackagesCopyWith<$Res> get packages {
  
  return $PackagesCopyWith<$Res>(_self.packages, (value) {
    return _then(_self.copyWith(packages: value));
  });
}/// Create a copy of FitnessDashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopSettingsCopyWith<$Res> get shopSettings {
  
  return $ShopSettingsCopyWith<$Res>(_self.shopSettings, (value) {
    return _then(_self.copyWith(shopSettings: value));
  });
}
}


/// @nodoc
mixin _$WeeklySchedule {

 int get classes;@JsonKey(name: 'one_to_one') int get oneToOne; int get total;
/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyScheduleCopyWith<WeeklySchedule> get copyWith => _$WeeklyScheduleCopyWithImpl<WeeklySchedule>(this as WeeklySchedule, _$identity);

  /// Serializes this WeeklySchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklySchedule&&(identical(other.classes, classes) || other.classes == classes)&&(identical(other.oneToOne, oneToOne) || other.oneToOne == oneToOne)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classes,oneToOne,total);

@override
String toString() {
  return 'WeeklySchedule(classes: $classes, oneToOne: $oneToOne, total: $total)';
}


}

/// @nodoc
abstract mixin class $WeeklyScheduleCopyWith<$Res>  {
  factory $WeeklyScheduleCopyWith(WeeklySchedule value, $Res Function(WeeklySchedule) _then) = _$WeeklyScheduleCopyWithImpl;
@useResult
$Res call({
 int classes,@JsonKey(name: 'one_to_one') int oneToOne, int total
});




}
/// @nodoc
class _$WeeklyScheduleCopyWithImpl<$Res>
    implements $WeeklyScheduleCopyWith<$Res> {
  _$WeeklyScheduleCopyWithImpl(this._self, this._then);

  final WeeklySchedule _self;
  final $Res Function(WeeklySchedule) _then;

/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? classes = null,Object? oneToOne = null,Object? total = null,}) {
  return _then(_self.copyWith(
classes: null == classes ? _self.classes : classes // ignore: cast_nullable_to_non_nullable
as int,oneToOne: null == oneToOne ? _self.oneToOne : oneToOne // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklySchedule].
extension WeeklySchedulePatterns on WeeklySchedule {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklySchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklySchedule value)  $default,){
final _that = this;
switch (_that) {
case _WeeklySchedule():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklySchedule value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int classes, @JsonKey(name: 'one_to_one')  int oneToOne,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that.classes,_that.oneToOne,_that.total);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int classes, @JsonKey(name: 'one_to_one')  int oneToOne,  int total)  $default,) {final _that = this;
switch (_that) {
case _WeeklySchedule():
return $default(_that.classes,_that.oneToOne,_that.total);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int classes, @JsonKey(name: 'one_to_one')  int oneToOne,  int total)?  $default,) {final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that.classes,_that.oneToOne,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklySchedule implements WeeklySchedule {
  const _WeeklySchedule({required this.classes, @JsonKey(name: 'one_to_one') required this.oneToOne, required this.total});
  factory _WeeklySchedule.fromJson(Map<String, dynamic> json) => _$WeeklyScheduleFromJson(json);

@override final  int classes;
@override@JsonKey(name: 'one_to_one') final  int oneToOne;
@override final  int total;

/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyScheduleCopyWith<_WeeklySchedule> get copyWith => __$WeeklyScheduleCopyWithImpl<_WeeklySchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklySchedule&&(identical(other.classes, classes) || other.classes == classes)&&(identical(other.oneToOne, oneToOne) || other.oneToOne == oneToOne)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classes,oneToOne,total);

@override
String toString() {
  return 'WeeklySchedule(classes: $classes, oneToOne: $oneToOne, total: $total)';
}


}

/// @nodoc
abstract mixin class _$WeeklyScheduleCopyWith<$Res> implements $WeeklyScheduleCopyWith<$Res> {
  factory _$WeeklyScheduleCopyWith(_WeeklySchedule value, $Res Function(_WeeklySchedule) _then) = __$WeeklyScheduleCopyWithImpl;
@override @useResult
$Res call({
 int classes,@JsonKey(name: 'one_to_one') int oneToOne, int total
});




}
/// @nodoc
class __$WeeklyScheduleCopyWithImpl<$Res>
    implements _$WeeklyScheduleCopyWith<$Res> {
  __$WeeklyScheduleCopyWithImpl(this._self, this._then);

  final _WeeklySchedule _self;
  final $Res Function(_WeeklySchedule) _then;

/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? classes = null,Object? oneToOne = null,Object? total = null,}) {
  return _then(_WeeklySchedule(
classes: null == classes ? _self.classes : classes // ignore: cast_nullable_to_non_nullable
as int,oneToOne: null == oneToOne ? _self.oneToOne : oneToOne // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Revenue {

@JsonKey(name: 'paid_total') double get paidTotal;@JsonKey(name: 'pending_deposit_count') int get pendingDepositCount;
/// Create a copy of Revenue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueCopyWith<Revenue> get copyWith => _$RevenueCopyWithImpl<Revenue>(this as Revenue, _$identity);

  /// Serializes this Revenue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Revenue&&(identical(other.paidTotal, paidTotal) || other.paidTotal == paidTotal)&&(identical(other.pendingDepositCount, pendingDepositCount) || other.pendingDepositCount == pendingDepositCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paidTotal,pendingDepositCount);

@override
String toString() {
  return 'Revenue(paidTotal: $paidTotal, pendingDepositCount: $pendingDepositCount)';
}


}

/// @nodoc
abstract mixin class $RevenueCopyWith<$Res>  {
  factory $RevenueCopyWith(Revenue value, $Res Function(Revenue) _then) = _$RevenueCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'paid_total') double paidTotal,@JsonKey(name: 'pending_deposit_count') int pendingDepositCount
});




}
/// @nodoc
class _$RevenueCopyWithImpl<$Res>
    implements $RevenueCopyWith<$Res> {
  _$RevenueCopyWithImpl(this._self, this._then);

  final Revenue _self;
  final $Res Function(Revenue) _then;

/// Create a copy of Revenue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paidTotal = null,Object? pendingDepositCount = null,}) {
  return _then(_self.copyWith(
paidTotal: null == paidTotal ? _self.paidTotal : paidTotal // ignore: cast_nullable_to_non_nullable
as double,pendingDepositCount: null == pendingDepositCount ? _self.pendingDepositCount : pendingDepositCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Revenue].
extension RevenuePatterns on Revenue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Revenue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Revenue() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Revenue value)  $default,){
final _that = this;
switch (_that) {
case _Revenue():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Revenue value)?  $default,){
final _that = this;
switch (_that) {
case _Revenue() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'paid_total')  double paidTotal, @JsonKey(name: 'pending_deposit_count')  int pendingDepositCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Revenue() when $default != null:
return $default(_that.paidTotal,_that.pendingDepositCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'paid_total')  double paidTotal, @JsonKey(name: 'pending_deposit_count')  int pendingDepositCount)  $default,) {final _that = this;
switch (_that) {
case _Revenue():
return $default(_that.paidTotal,_that.pendingDepositCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'paid_total')  double paidTotal, @JsonKey(name: 'pending_deposit_count')  int pendingDepositCount)?  $default,) {final _that = this;
switch (_that) {
case _Revenue() when $default != null:
return $default(_that.paidTotal,_that.pendingDepositCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Revenue implements Revenue {
  const _Revenue({@JsonKey(name: 'paid_total') required this.paidTotal, @JsonKey(name: 'pending_deposit_count') required this.pendingDepositCount});
  factory _Revenue.fromJson(Map<String, dynamic> json) => _$RevenueFromJson(json);

@override@JsonKey(name: 'paid_total') final  double paidTotal;
@override@JsonKey(name: 'pending_deposit_count') final  int pendingDepositCount;

/// Create a copy of Revenue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueCopyWith<_Revenue> get copyWith => __$RevenueCopyWithImpl<_Revenue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Revenue&&(identical(other.paidTotal, paidTotal) || other.paidTotal == paidTotal)&&(identical(other.pendingDepositCount, pendingDepositCount) || other.pendingDepositCount == pendingDepositCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paidTotal,pendingDepositCount);

@override
String toString() {
  return 'Revenue(paidTotal: $paidTotal, pendingDepositCount: $pendingDepositCount)';
}


}

/// @nodoc
abstract mixin class _$RevenueCopyWith<$Res> implements $RevenueCopyWith<$Res> {
  factory _$RevenueCopyWith(_Revenue value, $Res Function(_Revenue) _then) = __$RevenueCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'paid_total') double paidTotal,@JsonKey(name: 'pending_deposit_count') int pendingDepositCount
});




}
/// @nodoc
class __$RevenueCopyWithImpl<$Res>
    implements _$RevenueCopyWith<$Res> {
  __$RevenueCopyWithImpl(this._self, this._then);

  final _Revenue _self;
  final $Res Function(_Revenue) _then;

/// Create a copy of Revenue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paidTotal = null,Object? pendingDepositCount = null,}) {
  return _then(_Revenue(
paidTotal: null == paidTotal ? _self.paidTotal : paidTotal // ignore: cast_nullable_to_non_nullable
as double,pendingDepositCount: null == pendingDepositCount ? _self.pendingDepositCount : pendingDepositCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Packages {

@JsonKey(name: 'active_count') int get activeCount;
/// Create a copy of Packages
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackagesCopyWith<Packages> get copyWith => _$PackagesCopyWithImpl<Packages>(this as Packages, _$identity);

  /// Serializes this Packages to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Packages&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeCount);

@override
String toString() {
  return 'Packages(activeCount: $activeCount)';
}


}

/// @nodoc
abstract mixin class $PackagesCopyWith<$Res>  {
  factory $PackagesCopyWith(Packages value, $Res Function(Packages) _then) = _$PackagesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'active_count') int activeCount
});




}
/// @nodoc
class _$PackagesCopyWithImpl<$Res>
    implements $PackagesCopyWith<$Res> {
  _$PackagesCopyWithImpl(this._self, this._then);

  final Packages _self;
  final $Res Function(Packages) _then;

/// Create a copy of Packages
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeCount = null,}) {
  return _then(_self.copyWith(
activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Packages].
extension PackagesPatterns on Packages {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Packages value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Packages() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Packages value)  $default,){
final _that = this;
switch (_that) {
case _Packages():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Packages value)?  $default,){
final _that = this;
switch (_that) {
case _Packages() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_count')  int activeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Packages() when $default != null:
return $default(_that.activeCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_count')  int activeCount)  $default,) {final _that = this;
switch (_that) {
case _Packages():
return $default(_that.activeCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'active_count')  int activeCount)?  $default,) {final _that = this;
switch (_that) {
case _Packages() when $default != null:
return $default(_that.activeCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Packages implements Packages {
  const _Packages({@JsonKey(name: 'active_count') required this.activeCount});
  factory _Packages.fromJson(Map<String, dynamic> json) => _$PackagesFromJson(json);

@override@JsonKey(name: 'active_count') final  int activeCount;

/// Create a copy of Packages
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackagesCopyWith<_Packages> get copyWith => __$PackagesCopyWithImpl<_Packages>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackagesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Packages&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeCount);

@override
String toString() {
  return 'Packages(activeCount: $activeCount)';
}


}

/// @nodoc
abstract mixin class _$PackagesCopyWith<$Res> implements $PackagesCopyWith<$Res> {
  factory _$PackagesCopyWith(_Packages value, $Res Function(_Packages) _then) = __$PackagesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'active_count') int activeCount
});




}
/// @nodoc
class __$PackagesCopyWithImpl<$Res>
    implements _$PackagesCopyWith<$Res> {
  __$PackagesCopyWithImpl(this._self, this._then);

  final _Packages _self;
  final $Res Function(_Packages) _then;

/// Create a copy of Packages
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeCount = null,}) {
  return _then(_Packages(
activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ShopSettings {

@JsonKey(name: 'cancellation_policy_enabled') bool get cancellationPolicyEnabled;@JsonKey(name: 'free_cancellation_hours') int get freeCancellationHours;
/// Create a copy of ShopSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopSettingsCopyWith<ShopSettings> get copyWith => _$ShopSettingsCopyWithImpl<ShopSettings>(this as ShopSettings, _$identity);

  /// Serializes this ShopSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopSettings&&(identical(other.cancellationPolicyEnabled, cancellationPolicyEnabled) || other.cancellationPolicyEnabled == cancellationPolicyEnabled)&&(identical(other.freeCancellationHours, freeCancellationHours) || other.freeCancellationHours == freeCancellationHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cancellationPolicyEnabled,freeCancellationHours);

@override
String toString() {
  return 'ShopSettings(cancellationPolicyEnabled: $cancellationPolicyEnabled, freeCancellationHours: $freeCancellationHours)';
}


}

/// @nodoc
abstract mixin class $ShopSettingsCopyWith<$Res>  {
  factory $ShopSettingsCopyWith(ShopSettings value, $Res Function(ShopSettings) _then) = _$ShopSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'cancellation_policy_enabled') bool cancellationPolicyEnabled,@JsonKey(name: 'free_cancellation_hours') int freeCancellationHours
});




}
/// @nodoc
class _$ShopSettingsCopyWithImpl<$Res>
    implements $ShopSettingsCopyWith<$Res> {
  _$ShopSettingsCopyWithImpl(this._self, this._then);

  final ShopSettings _self;
  final $Res Function(ShopSettings) _then;

/// Create a copy of ShopSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cancellationPolicyEnabled = null,Object? freeCancellationHours = null,}) {
  return _then(_self.copyWith(
cancellationPolicyEnabled: null == cancellationPolicyEnabled ? _self.cancellationPolicyEnabled : cancellationPolicyEnabled // ignore: cast_nullable_to_non_nullable
as bool,freeCancellationHours: null == freeCancellationHours ? _self.freeCancellationHours : freeCancellationHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopSettings].
extension ShopSettingsPatterns on ShopSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopSettings value)  $default,){
final _that = this;
switch (_that) {
case _ShopSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ShopSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'cancellation_policy_enabled')  bool cancellationPolicyEnabled, @JsonKey(name: 'free_cancellation_hours')  int freeCancellationHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopSettings() when $default != null:
return $default(_that.cancellationPolicyEnabled,_that.freeCancellationHours);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'cancellation_policy_enabled')  bool cancellationPolicyEnabled, @JsonKey(name: 'free_cancellation_hours')  int freeCancellationHours)  $default,) {final _that = this;
switch (_that) {
case _ShopSettings():
return $default(_that.cancellationPolicyEnabled,_that.freeCancellationHours);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'cancellation_policy_enabled')  bool cancellationPolicyEnabled, @JsonKey(name: 'free_cancellation_hours')  int freeCancellationHours)?  $default,) {final _that = this;
switch (_that) {
case _ShopSettings() when $default != null:
return $default(_that.cancellationPolicyEnabled,_that.freeCancellationHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopSettings implements ShopSettings {
  const _ShopSettings({@JsonKey(name: 'cancellation_policy_enabled') required this.cancellationPolicyEnabled, @JsonKey(name: 'free_cancellation_hours') required this.freeCancellationHours});
  factory _ShopSettings.fromJson(Map<String, dynamic> json) => _$ShopSettingsFromJson(json);

@override@JsonKey(name: 'cancellation_policy_enabled') final  bool cancellationPolicyEnabled;
@override@JsonKey(name: 'free_cancellation_hours') final  int freeCancellationHours;

/// Create a copy of ShopSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopSettingsCopyWith<_ShopSettings> get copyWith => __$ShopSettingsCopyWithImpl<_ShopSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopSettings&&(identical(other.cancellationPolicyEnabled, cancellationPolicyEnabled) || other.cancellationPolicyEnabled == cancellationPolicyEnabled)&&(identical(other.freeCancellationHours, freeCancellationHours) || other.freeCancellationHours == freeCancellationHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cancellationPolicyEnabled,freeCancellationHours);

@override
String toString() {
  return 'ShopSettings(cancellationPolicyEnabled: $cancellationPolicyEnabled, freeCancellationHours: $freeCancellationHours)';
}


}

/// @nodoc
abstract mixin class _$ShopSettingsCopyWith<$Res> implements $ShopSettingsCopyWith<$Res> {
  factory _$ShopSettingsCopyWith(_ShopSettings value, $Res Function(_ShopSettings) _then) = __$ShopSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'cancellation_policy_enabled') bool cancellationPolicyEnabled,@JsonKey(name: 'free_cancellation_hours') int freeCancellationHours
});




}
/// @nodoc
class __$ShopSettingsCopyWithImpl<$Res>
    implements _$ShopSettingsCopyWith<$Res> {
  __$ShopSettingsCopyWithImpl(this._self, this._then);

  final _ShopSettings _self;
  final $Res Function(_ShopSettings) _then;

/// Create a copy of ShopSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cancellationPolicyEnabled = null,Object? freeCancellationHours = null,}) {
  return _then(_ShopSettings(
cancellationPolicyEnabled: null == cancellationPolicyEnabled ? _self.cancellationPolicyEnabled : cancellationPolicyEnabled // ignore: cast_nullable_to_non_nullable
as bool,freeCancellationHours: null == freeCancellationHours ? _self.freeCancellationHours : freeCancellationHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FitnessPackageModel {

 int get id; int? get shop;// ID of the shop
 int? get customer;// ID of the customer (optional/nullable in list?)
@JsonKey(name: 'total_sessions') int get totalSessions;@JsonKey(name: 'sessions_remaining') int get sessionsRemaining; String get price;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'is_active') bool get isActive;
/// Create a copy of FitnessPackageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FitnessPackageModelCopyWith<FitnessPackageModel> get copyWith => _$FitnessPackageModelCopyWithImpl<FitnessPackageModel>(this as FitnessPackageModel, _$identity);

  /// Serializes this FitnessPackageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FitnessPackageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.price, price) || other.price == price)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shop,customer,totalSessions,sessionsRemaining,price,expiresAt,createdAt,isActive);

@override
String toString() {
  return 'FitnessPackageModel(id: $id, shop: $shop, customer: $customer, totalSessions: $totalSessions, sessionsRemaining: $sessionsRemaining, price: $price, expiresAt: $expiresAt, createdAt: $createdAt, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $FitnessPackageModelCopyWith<$Res>  {
  factory $FitnessPackageModelCopyWith(FitnessPackageModel value, $Res Function(FitnessPackageModel) _then) = _$FitnessPackageModelCopyWithImpl;
@useResult
$Res call({
 int id, int? shop, int? customer,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'sessions_remaining') int sessionsRemaining, String price,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class _$FitnessPackageModelCopyWithImpl<$Res>
    implements $FitnessPackageModelCopyWith<$Res> {
  _$FitnessPackageModelCopyWithImpl(this._self, this._then);

  final FitnessPackageModel _self;
  final $Res Function(FitnessPackageModel) _then;

/// Create a copy of FitnessPackageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shop = freezed,Object? customer = freezed,Object? totalSessions = null,Object? sessionsRemaining = null,Object? price = null,Object? expiresAt = freezed,Object? createdAt = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as int?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int?,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,sessionsRemaining: null == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FitnessPackageModel].
extension FitnessPackageModelPatterns on FitnessPackageModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FitnessPackageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FitnessPackageModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FitnessPackageModel value)  $default,){
final _that = this;
switch (_that) {
case _FitnessPackageModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FitnessPackageModel value)?  $default,){
final _that = this;
switch (_that) {
case _FitnessPackageModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? shop,  int? customer, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'sessions_remaining')  int sessionsRemaining,  String price, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'is_active')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FitnessPackageModel() when $default != null:
return $default(_that.id,_that.shop,_that.customer,_that.totalSessions,_that.sessionsRemaining,_that.price,_that.expiresAt,_that.createdAt,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? shop,  int? customer, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'sessions_remaining')  int sessionsRemaining,  String price, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'is_active')  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _FitnessPackageModel():
return $default(_that.id,_that.shop,_that.customer,_that.totalSessions,_that.sessionsRemaining,_that.price,_that.expiresAt,_that.createdAt,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? shop,  int? customer, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'sessions_remaining')  int sessionsRemaining,  String price, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'is_active')  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _FitnessPackageModel() when $default != null:
return $default(_that.id,_that.shop,_that.customer,_that.totalSessions,_that.sessionsRemaining,_that.price,_that.expiresAt,_that.createdAt,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FitnessPackageModel implements FitnessPackageModel {
  const _FitnessPackageModel({required this.id, this.shop, this.customer, @JsonKey(name: 'total_sessions') required this.totalSessions, @JsonKey(name: 'sessions_remaining') required this.sessionsRemaining, required this.price, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'is_active') required this.isActive});
  factory _FitnessPackageModel.fromJson(Map<String, dynamic> json) => _$FitnessPackageModelFromJson(json);

@override final  int id;
@override final  int? shop;
// ID of the shop
@override final  int? customer;
// ID of the customer (optional/nullable in list?)
@override@JsonKey(name: 'total_sessions') final  int totalSessions;
@override@JsonKey(name: 'sessions_remaining') final  int sessionsRemaining;
@override final  String price;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'is_active') final  bool isActive;

/// Create a copy of FitnessPackageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FitnessPackageModelCopyWith<_FitnessPackageModel> get copyWith => __$FitnessPackageModelCopyWithImpl<_FitnessPackageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FitnessPackageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FitnessPackageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.sessionsRemaining, sessionsRemaining) || other.sessionsRemaining == sessionsRemaining)&&(identical(other.price, price) || other.price == price)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shop,customer,totalSessions,sessionsRemaining,price,expiresAt,createdAt,isActive);

@override
String toString() {
  return 'FitnessPackageModel(id: $id, shop: $shop, customer: $customer, totalSessions: $totalSessions, sessionsRemaining: $sessionsRemaining, price: $price, expiresAt: $expiresAt, createdAt: $createdAt, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$FitnessPackageModelCopyWith<$Res> implements $FitnessPackageModelCopyWith<$Res> {
  factory _$FitnessPackageModelCopyWith(_FitnessPackageModel value, $Res Function(_FitnessPackageModel) _then) = __$FitnessPackageModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int? shop, int? customer,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'sessions_remaining') int sessionsRemaining, String price,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class __$FitnessPackageModelCopyWithImpl<$Res>
    implements _$FitnessPackageModelCopyWith<$Res> {
  __$FitnessPackageModelCopyWithImpl(this._self, this._then);

  final _FitnessPackageModel _self;
  final $Res Function(_FitnessPackageModel) _then;

/// Create a copy of FitnessPackageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shop = freezed,Object? customer = freezed,Object? totalSessions = null,Object? sessionsRemaining = null,Object? price = null,Object? expiresAt = freezed,Object? createdAt = freezed,Object? isActive = null,}) {
  return _then(_FitnessPackageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as int?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int?,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,sessionsRemaining: null == sessionsRemaining ? _self.sessionsRemaining : sessionsRemaining // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WorkoutTemplateModel {

 int get id; String get title; String get description; List<Map<String, dynamic>> get exercises;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of WorkoutTemplateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutTemplateModelCopyWith<WorkoutTemplateModel> get copyWith => _$WorkoutTemplateModelCopyWithImpl<WorkoutTemplateModel>(this as WorkoutTemplateModel, _$identity);

  /// Serializes this WorkoutTemplateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutTemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(exercises),createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutTemplateModel(id: $id, title: $title, description: $description, exercises: $exercises, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkoutTemplateModelCopyWith<$Res>  {
  factory $WorkoutTemplateModelCopyWith(WorkoutTemplateModel value, $Res Function(WorkoutTemplateModel) _then) = _$WorkoutTemplateModelCopyWithImpl;
@useResult
$Res call({
 int id, String title, String description, List<Map<String, dynamic>> exercises,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$WorkoutTemplateModelCopyWithImpl<$Res>
    implements $WorkoutTemplateModelCopyWith<$Res> {
  _$WorkoutTemplateModelCopyWithImpl(this._self, this._then);

  final WorkoutTemplateModel _self;
  final $Res Function(WorkoutTemplateModel) _then;

/// Create a copy of WorkoutTemplateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? exercises = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutTemplateModel].
extension WorkoutTemplateModelPatterns on WorkoutTemplateModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutTemplateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutTemplateModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutTemplateModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutTemplateModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutTemplateModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutTemplateModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String description,  List<Map<String, dynamic>> exercises, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutTemplateModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.exercises,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String description,  List<Map<String, dynamic>> exercises, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutTemplateModel():
return $default(_that.id,_that.title,_that.description,_that.exercises,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String description,  List<Map<String, dynamic>> exercises, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutTemplateModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.exercises,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutTemplateModel implements WorkoutTemplateModel {
  const _WorkoutTemplateModel({required this.id, required this.title, required this.description, final  List<Map<String, dynamic>> exercises = const [], @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _exercises = exercises;
  factory _WorkoutTemplateModel.fromJson(Map<String, dynamic> json) => _$WorkoutTemplateModelFromJson(json);

@override final  int id;
@override final  String title;
@override final  String description;
 final  List<Map<String, dynamic>> _exercises;
@override@JsonKey() List<Map<String, dynamic>> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of WorkoutTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutTemplateModelCopyWith<_WorkoutTemplateModel> get copyWith => __$WorkoutTemplateModelCopyWithImpl<_WorkoutTemplateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutTemplateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutTemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(_exercises),createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutTemplateModel(id: $id, title: $title, description: $description, exercises: $exercises, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutTemplateModelCopyWith<$Res> implements $WorkoutTemplateModelCopyWith<$Res> {
  factory _$WorkoutTemplateModelCopyWith(_WorkoutTemplateModel value, $Res Function(_WorkoutTemplateModel) _then) = __$WorkoutTemplateModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String description, List<Map<String, dynamic>> exercises,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$WorkoutTemplateModelCopyWithImpl<$Res>
    implements _$WorkoutTemplateModelCopyWith<$Res> {
  __$WorkoutTemplateModelCopyWithImpl(this._self, this._then);

  final _WorkoutTemplateModel _self;
  final $Res Function(_WorkoutTemplateModel) _then;

/// Create a copy of WorkoutTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? exercises = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_WorkoutTemplateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NutritionPlanModel {

 int get id; String get title; String get notes;@JsonKey(name: 'external_links') List<String> get externalLinks;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of NutritionPlanModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionPlanModelCopyWith<NutritionPlanModel> get copyWith => _$NutritionPlanModelCopyWithImpl<NutritionPlanModel>(this as NutritionPlanModel, _$identity);

  /// Serializes this NutritionPlanModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionPlanModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.externalLinks, externalLinks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,const DeepCollectionEquality().hash(externalLinks),createdAt,updatedAt);

@override
String toString() {
  return 'NutritionPlanModel(id: $id, title: $title, notes: $notes, externalLinks: $externalLinks, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NutritionPlanModelCopyWith<$Res>  {
  factory $NutritionPlanModelCopyWith(NutritionPlanModel value, $Res Function(NutritionPlanModel) _then) = _$NutritionPlanModelCopyWithImpl;
@useResult
$Res call({
 int id, String title, String notes,@JsonKey(name: 'external_links') List<String> externalLinks,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$NutritionPlanModelCopyWithImpl<$Res>
    implements $NutritionPlanModelCopyWith<$Res> {
  _$NutritionPlanModelCopyWithImpl(this._self, this._then);

  final NutritionPlanModel _self;
  final $Res Function(NutritionPlanModel) _then;

/// Create a copy of NutritionPlanModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? notes = null,Object? externalLinks = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,externalLinks: null == externalLinks ? _self.externalLinks : externalLinks // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NutritionPlanModel].
extension NutritionPlanModelPatterns on NutritionPlanModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionPlanModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionPlanModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionPlanModel value)  $default,){
final _that = this;
switch (_that) {
case _NutritionPlanModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionPlanModel value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionPlanModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String notes, @JsonKey(name: 'external_links')  List<String> externalLinks, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionPlanModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.externalLinks,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String notes, @JsonKey(name: 'external_links')  List<String> externalLinks, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NutritionPlanModel():
return $default(_that.id,_that.title,_that.notes,_that.externalLinks,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String notes, @JsonKey(name: 'external_links')  List<String> externalLinks, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NutritionPlanModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.externalLinks,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NutritionPlanModel implements NutritionPlanModel {
  const _NutritionPlanModel({required this.id, required this.title, this.notes = '', @JsonKey(name: 'external_links') final  List<String> externalLinks = const [], @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _externalLinks = externalLinks;
  factory _NutritionPlanModel.fromJson(Map<String, dynamic> json) => _$NutritionPlanModelFromJson(json);

@override final  int id;
@override final  String title;
@override@JsonKey() final  String notes;
 final  List<String> _externalLinks;
@override@JsonKey(name: 'external_links') List<String> get externalLinks {
  if (_externalLinks is EqualUnmodifiableListView) return _externalLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_externalLinks);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of NutritionPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionPlanModelCopyWith<_NutritionPlanModel> get copyWith => __$NutritionPlanModelCopyWithImpl<_NutritionPlanModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionPlanModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionPlanModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._externalLinks, _externalLinks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,const DeepCollectionEquality().hash(_externalLinks),createdAt,updatedAt);

@override
String toString() {
  return 'NutritionPlanModel(id: $id, title: $title, notes: $notes, externalLinks: $externalLinks, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NutritionPlanModelCopyWith<$Res> implements $NutritionPlanModelCopyWith<$Res> {
  factory _$NutritionPlanModelCopyWith(_NutritionPlanModel value, $Res Function(_NutritionPlanModel) _then) = __$NutritionPlanModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String notes,@JsonKey(name: 'external_links') List<String> externalLinks,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$NutritionPlanModelCopyWithImpl<$Res>
    implements _$NutritionPlanModelCopyWith<$Res> {
  __$NutritionPlanModelCopyWithImpl(this._self, this._then);

  final _NutritionPlanModel _self;
  final $Res Function(_NutritionPlanModel) _then;

/// Create a copy of NutritionPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? notes = null,Object? externalLinks = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_NutritionPlanModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,externalLinks: null == externalLinks ? _self._externalLinks : externalLinks // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
