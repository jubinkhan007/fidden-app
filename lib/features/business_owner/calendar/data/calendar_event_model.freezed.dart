// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarEventModel {

@JsonKey(name: 'event_type') String get eventType;// "booking" | "blocked"
 int get id; String get title;@JsonKey(name: 'start_at') String get startAt;// Keep as String to preserve offset
@JsonKey(name: 'end_at') String get endAt;// Keep as String to preserve offset
@JsonKey(name: 'start_at_utc') DateTime get startAtUtc;@JsonKey(name: 'end_at_utc') DateTime get endAtUtc;@JsonKey(name: 'timezone_id') String get timezoneId;@JsonKey(name: 'calendar_status') String get calendarStatus;// CONFIRMED|PENDING...
 List<String> get badges;// ["PAID", "DEP_DUE", ...]
// Joint fields
 ProviderLite? get provider;// Booking specific
 CustomerLite? get customer; ServiceLite? get service;// Blocked specific
@JsonKey(name: 'blocked_reason') String? get blockedReason; String? get note;
/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventModelCopyWith<CalendarEventModel> get copyWith => _$CalendarEventModelCopyWithImpl<CalendarEventModel>(this as CalendarEventModel, _$identity);

  /// Serializes this CalendarEventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEventModel&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.timezoneId, timezoneId) || other.timezoneId == timezoneId)&&(identical(other.calendarStatus, calendarStatus) || other.calendarStatus == calendarStatus)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.service, service) || other.service == service)&&(identical(other.blockedReason, blockedReason) || other.blockedReason == blockedReason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventType,id,title,startAt,endAt,startAtUtc,endAtUtc,timezoneId,calendarStatus,const DeepCollectionEquality().hash(badges),provider,customer,service,blockedReason,note);

@override
String toString() {
  return 'CalendarEventModel(eventType: $eventType, id: $id, title: $title, startAt: $startAt, endAt: $endAt, startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, timezoneId: $timezoneId, calendarStatus: $calendarStatus, badges: $badges, provider: $provider, customer: $customer, service: $service, blockedReason: $blockedReason, note: $note)';
}


}

/// @nodoc
abstract mixin class $CalendarEventModelCopyWith<$Res>  {
  factory $CalendarEventModelCopyWith(CalendarEventModel value, $Res Function(CalendarEventModel) _then) = _$CalendarEventModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'event_type') String eventType, int id, String title,@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt,@JsonKey(name: 'start_at_utc') DateTime startAtUtc,@JsonKey(name: 'end_at_utc') DateTime endAtUtc,@JsonKey(name: 'timezone_id') String timezoneId,@JsonKey(name: 'calendar_status') String calendarStatus, List<String> badges, ProviderLite? provider, CustomerLite? customer, ServiceLite? service,@JsonKey(name: 'blocked_reason') String? blockedReason, String? note
});


$ProviderLiteCopyWith<$Res>? get provider;$CustomerLiteCopyWith<$Res>? get customer;$ServiceLiteCopyWith<$Res>? get service;

}
/// @nodoc
class _$CalendarEventModelCopyWithImpl<$Res>
    implements $CalendarEventModelCopyWith<$Res> {
  _$CalendarEventModelCopyWithImpl(this._self, this._then);

  final CalendarEventModel _self;
  final $Res Function(CalendarEventModel) _then;

/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventType = null,Object? id = null,Object? title = null,Object? startAt = null,Object? endAt = null,Object? startAtUtc = null,Object? endAtUtc = null,Object? timezoneId = null,Object? calendarStatus = null,Object? badges = null,Object? provider = freezed,Object? customer = freezed,Object? service = freezed,Object? blockedReason = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,timezoneId: null == timezoneId ? _self.timezoneId : timezoneId // ignore: cast_nullable_to_non_nullable
as String,calendarStatus: null == calendarStatus ? _self.calendarStatus : calendarStatus // ignore: cast_nullable_to_non_nullable
as String,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as ProviderLite?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerLite?,service: freezed == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as ServiceLite?,blockedReason: freezed == blockedReason ? _self.blockedReason : blockedReason // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderLiteCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $ProviderLiteCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerLiteCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $CustomerLiteCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceLiteCopyWith<$Res>? get service {
    if (_self.service == null) {
    return null;
  }

  return $ServiceLiteCopyWith<$Res>(_self.service!, (value) {
    return _then(_self.copyWith(service: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarEventModel].
extension CalendarEventModelPatterns on CalendarEventModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEventModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEventModel value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEventModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEventModel value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEventModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'event_type')  String eventType,  int id,  String title, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt, @JsonKey(name: 'start_at_utc')  DateTime startAtUtc, @JsonKey(name: 'end_at_utc')  DateTime endAtUtc, @JsonKey(name: 'timezone_id')  String timezoneId, @JsonKey(name: 'calendar_status')  String calendarStatus,  List<String> badges,  ProviderLite? provider,  CustomerLite? customer,  ServiceLite? service, @JsonKey(name: 'blocked_reason')  String? blockedReason,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEventModel() when $default != null:
return $default(_that.eventType,_that.id,_that.title,_that.startAt,_that.endAt,_that.startAtUtc,_that.endAtUtc,_that.timezoneId,_that.calendarStatus,_that.badges,_that.provider,_that.customer,_that.service,_that.blockedReason,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'event_type')  String eventType,  int id,  String title, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt, @JsonKey(name: 'start_at_utc')  DateTime startAtUtc, @JsonKey(name: 'end_at_utc')  DateTime endAtUtc, @JsonKey(name: 'timezone_id')  String timezoneId, @JsonKey(name: 'calendar_status')  String calendarStatus,  List<String> badges,  ProviderLite? provider,  CustomerLite? customer,  ServiceLite? service, @JsonKey(name: 'blocked_reason')  String? blockedReason,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CalendarEventModel():
return $default(_that.eventType,_that.id,_that.title,_that.startAt,_that.endAt,_that.startAtUtc,_that.endAtUtc,_that.timezoneId,_that.calendarStatus,_that.badges,_that.provider,_that.customer,_that.service,_that.blockedReason,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'event_type')  String eventType,  int id,  String title, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt, @JsonKey(name: 'start_at_utc')  DateTime startAtUtc, @JsonKey(name: 'end_at_utc')  DateTime endAtUtc, @JsonKey(name: 'timezone_id')  String timezoneId, @JsonKey(name: 'calendar_status')  String calendarStatus,  List<String> badges,  ProviderLite? provider,  CustomerLite? customer,  ServiceLite? service, @JsonKey(name: 'blocked_reason')  String? blockedReason,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEventModel() when $default != null:
return $default(_that.eventType,_that.id,_that.title,_that.startAt,_that.endAt,_that.startAtUtc,_that.endAtUtc,_that.timezoneId,_that.calendarStatus,_that.badges,_that.provider,_that.customer,_that.service,_that.blockedReason,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarEventModel implements CalendarEventModel {
  const _CalendarEventModel({@JsonKey(name: 'event_type') required this.eventType, required this.id, required this.title, @JsonKey(name: 'start_at') required this.startAt, @JsonKey(name: 'end_at') required this.endAt, @JsonKey(name: 'start_at_utc') required this.startAtUtc, @JsonKey(name: 'end_at_utc') required this.endAtUtc, @JsonKey(name: 'timezone_id') required this.timezoneId, @JsonKey(name: 'calendar_status') required this.calendarStatus, final  List<String> badges = const [], this.provider = null, this.customer = null, this.service = null, @JsonKey(name: 'blocked_reason') this.blockedReason, this.note = null}): _badges = badges;
  factory _CalendarEventModel.fromJson(Map<String, dynamic> json) => _$CalendarEventModelFromJson(json);

@override@JsonKey(name: 'event_type') final  String eventType;
// "booking" | "blocked"
@override final  int id;
@override final  String title;
@override@JsonKey(name: 'start_at') final  String startAt;
// Keep as String to preserve offset
@override@JsonKey(name: 'end_at') final  String endAt;
// Keep as String to preserve offset
@override@JsonKey(name: 'start_at_utc') final  DateTime startAtUtc;
@override@JsonKey(name: 'end_at_utc') final  DateTime endAtUtc;
@override@JsonKey(name: 'timezone_id') final  String timezoneId;
@override@JsonKey(name: 'calendar_status') final  String calendarStatus;
// CONFIRMED|PENDING...
 final  List<String> _badges;
// CONFIRMED|PENDING...
@override@JsonKey() List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

// ["PAID", "DEP_DUE", ...]
// Joint fields
@override@JsonKey() final  ProviderLite? provider;
// Booking specific
@override@JsonKey() final  CustomerLite? customer;
@override@JsonKey() final  ServiceLite? service;
// Blocked specific
@override@JsonKey(name: 'blocked_reason') final  String? blockedReason;
@override@JsonKey() final  String? note;

/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventModelCopyWith<_CalendarEventModel> get copyWith => __$CalendarEventModelCopyWithImpl<_CalendarEventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarEventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEventModel&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.timezoneId, timezoneId) || other.timezoneId == timezoneId)&&(identical(other.calendarStatus, calendarStatus) || other.calendarStatus == calendarStatus)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.service, service) || other.service == service)&&(identical(other.blockedReason, blockedReason) || other.blockedReason == blockedReason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventType,id,title,startAt,endAt,startAtUtc,endAtUtc,timezoneId,calendarStatus,const DeepCollectionEquality().hash(_badges),provider,customer,service,blockedReason,note);

@override
String toString() {
  return 'CalendarEventModel(eventType: $eventType, id: $id, title: $title, startAt: $startAt, endAt: $endAt, startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, timezoneId: $timezoneId, calendarStatus: $calendarStatus, badges: $badges, provider: $provider, customer: $customer, service: $service, blockedReason: $blockedReason, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventModelCopyWith<$Res> implements $CalendarEventModelCopyWith<$Res> {
  factory _$CalendarEventModelCopyWith(_CalendarEventModel value, $Res Function(_CalendarEventModel) _then) = __$CalendarEventModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'event_type') String eventType, int id, String title,@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt,@JsonKey(name: 'start_at_utc') DateTime startAtUtc,@JsonKey(name: 'end_at_utc') DateTime endAtUtc,@JsonKey(name: 'timezone_id') String timezoneId,@JsonKey(name: 'calendar_status') String calendarStatus, List<String> badges, ProviderLite? provider, CustomerLite? customer, ServiceLite? service,@JsonKey(name: 'blocked_reason') String? blockedReason, String? note
});


@override $ProviderLiteCopyWith<$Res>? get provider;@override $CustomerLiteCopyWith<$Res>? get customer;@override $ServiceLiteCopyWith<$Res>? get service;

}
/// @nodoc
class __$CalendarEventModelCopyWithImpl<$Res>
    implements _$CalendarEventModelCopyWith<$Res> {
  __$CalendarEventModelCopyWithImpl(this._self, this._then);

  final _CalendarEventModel _self;
  final $Res Function(_CalendarEventModel) _then;

/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventType = null,Object? id = null,Object? title = null,Object? startAt = null,Object? endAt = null,Object? startAtUtc = null,Object? endAtUtc = null,Object? timezoneId = null,Object? calendarStatus = null,Object? badges = null,Object? provider = freezed,Object? customer = freezed,Object? service = freezed,Object? blockedReason = freezed,Object? note = freezed,}) {
  return _then(_CalendarEventModel(
eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,startAtUtc: null == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,endAtUtc: null == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,timezoneId: null == timezoneId ? _self.timezoneId : timezoneId // ignore: cast_nullable_to_non_nullable
as String,calendarStatus: null == calendarStatus ? _self.calendarStatus : calendarStatus // ignore: cast_nullable_to_non_nullable
as String,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as ProviderLite?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerLite?,service: freezed == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as ServiceLite?,blockedReason: freezed == blockedReason ? _self.blockedReason : blockedReason // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderLiteCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $ProviderLiteCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerLiteCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $CustomerLiteCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of CalendarEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceLiteCopyWith<$Res>? get service {
    if (_self.service == null) {
    return null;
  }

  return $ServiceLiteCopyWith<$Res>(_self.service!, (value) {
    return _then(_self.copyWith(service: value));
  });
}
}


/// @nodoc
mixin _$ProviderLite {

 int get id; String get name;
/// Create a copy of ProviderLite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderLiteCopyWith<ProviderLite> get copyWith => _$ProviderLiteCopyWithImpl<ProviderLite>(this as ProviderLite, _$identity);

  /// Serializes this ProviderLite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderLite&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ProviderLite(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ProviderLiteCopyWith<$Res>  {
  factory $ProviderLiteCopyWith(ProviderLite value, $Res Function(ProviderLite) _then) = _$ProviderLiteCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$ProviderLiteCopyWithImpl<$Res>
    implements $ProviderLiteCopyWith<$Res> {
  _$ProviderLiteCopyWithImpl(this._self, this._then);

  final ProviderLite _self;
  final $Res Function(ProviderLite) _then;

/// Create a copy of ProviderLite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderLite].
extension ProviderLitePatterns on ProviderLite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderLite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderLite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderLite value)  $default,){
final _that = this;
switch (_that) {
case _ProviderLite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderLite value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderLite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderLite() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _ProviderLite():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ProviderLite() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderLite implements ProviderLite {
  const _ProviderLite({required this.id, required this.name});
  factory _ProviderLite.fromJson(Map<String, dynamic> json) => _$ProviderLiteFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of ProviderLite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderLiteCopyWith<_ProviderLite> get copyWith => __$ProviderLiteCopyWithImpl<_ProviderLite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderLiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderLite&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ProviderLite(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ProviderLiteCopyWith<$Res> implements $ProviderLiteCopyWith<$Res> {
  factory _$ProviderLiteCopyWith(_ProviderLite value, $Res Function(_ProviderLite) _then) = __$ProviderLiteCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$ProviderLiteCopyWithImpl<$Res>
    implements _$ProviderLiteCopyWith<$Res> {
  __$ProviderLiteCopyWithImpl(this._self, this._then);

  final _ProviderLite _self;
  final $Res Function(_ProviderLite) _then;

/// Create a copy of ProviderLite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ProviderLite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CustomerLite {

 int get id; String get name;
/// Create a copy of CustomerLite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerLiteCopyWith<CustomerLite> get copyWith => _$CustomerLiteCopyWithImpl<CustomerLite>(this as CustomerLite, _$identity);

  /// Serializes this CustomerLite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerLite&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CustomerLite(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $CustomerLiteCopyWith<$Res>  {
  factory $CustomerLiteCopyWith(CustomerLite value, $Res Function(CustomerLite) _then) = _$CustomerLiteCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$CustomerLiteCopyWithImpl<$Res>
    implements $CustomerLiteCopyWith<$Res> {
  _$CustomerLiteCopyWithImpl(this._self, this._then);

  final CustomerLite _self;
  final $Res Function(CustomerLite) _then;

/// Create a copy of CustomerLite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerLite].
extension CustomerLitePatterns on CustomerLite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerLite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerLite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerLite value)  $default,){
final _that = this;
switch (_that) {
case _CustomerLite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerLite value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerLite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerLite() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _CustomerLite():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CustomerLite() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerLite implements CustomerLite {
  const _CustomerLite({required this.id, required this.name});
  factory _CustomerLite.fromJson(Map<String, dynamic> json) => _$CustomerLiteFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of CustomerLite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerLiteCopyWith<_CustomerLite> get copyWith => __$CustomerLiteCopyWithImpl<_CustomerLite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerLiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerLite&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CustomerLite(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CustomerLiteCopyWith<$Res> implements $CustomerLiteCopyWith<$Res> {
  factory _$CustomerLiteCopyWith(_CustomerLite value, $Res Function(_CustomerLite) _then) = __$CustomerLiteCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$CustomerLiteCopyWithImpl<$Res>
    implements _$CustomerLiteCopyWith<$Res> {
  __$CustomerLiteCopyWithImpl(this._self, this._then);

  final _CustomerLite _self;
  final $Res Function(_CustomerLite) _then;

/// Create a copy of CustomerLite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_CustomerLite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ServiceLite {

 int get id; String get title;
/// Create a copy of ServiceLite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceLiteCopyWith<ServiceLite> get copyWith => _$ServiceLiteCopyWithImpl<ServiceLite>(this as ServiceLite, _$identity);

  /// Serializes this ServiceLite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceLite&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'ServiceLite(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $ServiceLiteCopyWith<$Res>  {
  factory $ServiceLiteCopyWith(ServiceLite value, $Res Function(ServiceLite) _then) = _$ServiceLiteCopyWithImpl;
@useResult
$Res call({
 int id, String title
});




}
/// @nodoc
class _$ServiceLiteCopyWithImpl<$Res>
    implements $ServiceLiteCopyWith<$Res> {
  _$ServiceLiteCopyWithImpl(this._self, this._then);

  final ServiceLite _self;
  final $Res Function(ServiceLite) _then;

/// Create a copy of ServiceLite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceLite].
extension ServiceLitePatterns on ServiceLite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceLite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceLite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceLite value)  $default,){
final _that = this;
switch (_that) {
case _ServiceLite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceLite value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceLite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceLite() when $default != null:
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title)  $default,) {final _that = this;
switch (_that) {
case _ServiceLite():
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title)?  $default,) {final _that = this;
switch (_that) {
case _ServiceLite() when $default != null:
return $default(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceLite implements ServiceLite {
  const _ServiceLite({required this.id, required this.title});
  factory _ServiceLite.fromJson(Map<String, dynamic> json) => _$ServiceLiteFromJson(json);

@override final  int id;
@override final  String title;

/// Create a copy of ServiceLite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceLiteCopyWith<_ServiceLite> get copyWith => __$ServiceLiteCopyWithImpl<_ServiceLite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceLiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceLite&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'ServiceLite(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class _$ServiceLiteCopyWith<$Res> implements $ServiceLiteCopyWith<$Res> {
  factory _$ServiceLiteCopyWith(_ServiceLite value, $Res Function(_ServiceLite) _then) = __$ServiceLiteCopyWithImpl;
@override @useResult
$Res call({
 int id, String title
});




}
/// @nodoc
class __$ServiceLiteCopyWithImpl<$Res>
    implements _$ServiceLiteCopyWith<$Res> {
  __$ServiceLiteCopyWithImpl(this._self, this._then);

  final _ServiceLite _self;
  final $Res Function(_ServiceLite) _then;

/// Create a copy of ServiceLite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,}) {
  return _then(_ServiceLite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
