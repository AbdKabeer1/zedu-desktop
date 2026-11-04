import 'package:zedu/features/features.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
    this.sessionExpired = false,
  });

  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isLoading;

  /// True when a 401 ended a signed-in session (not a logout).
  final bool sessionExpired;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
    bool? sessionExpired,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
