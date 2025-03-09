// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:restaurant_app/models/restaurant.dart' as _i2;
import 'package:restaurant_app/services/api_service.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeRestaurantDetail_0 extends _i1.SmartFake
    implements _i2.RestaurantDetail {
  _FakeRestaurantDetail_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class MockApiService extends _i1.Mock implements _i3.ApiService {
  MockApiService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<List<_i2.Restaurant>> getRestaurants() => (super.noSuchMethod(
        Invocation.method(#getRestaurants, []),
        returnValue: _i4.Future<List<_i2.Restaurant>>.value(
          <_i2.Restaurant>[],
        ),
      ) as _i4.Future<List<_i2.Restaurant>>);

  @override
  _i4.Future<_i2.RestaurantDetail> getRestaurantDetail(String? id) =>
      (super.noSuchMethod(
        Invocation.method(#getRestaurantDetail, [id]),
        returnValue: _i4.Future<_i2.RestaurantDetail>.value(
          _FakeRestaurantDetail_0(
            this,
            Invocation.method(#getRestaurantDetail, [id]),
          ),
        ),
      ) as _i4.Future<_i2.RestaurantDetail>);

  @override
  _i4.Future<List<_i2.CustomerReview>> addReview(
    String? id,
    String? name,
    String? review,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#addReview, [id, name, review]),
        returnValue: _i4.Future<List<_i2.CustomerReview>>.value(
          <_i2.CustomerReview>[],
        ),
      ) as _i4.Future<List<_i2.CustomerReview>>);

  @override
  _i4.Future<List<_i2.Restaurant>> searchRestaurants(String? query) =>
      (super.noSuchMethod(
        Invocation.method(#searchRestaurants, [query]),
        returnValue: _i4.Future<List<_i2.Restaurant>>.value(
          <_i2.Restaurant>[],
        ),
      ) as _i4.Future<List<_i2.Restaurant>>);
}
