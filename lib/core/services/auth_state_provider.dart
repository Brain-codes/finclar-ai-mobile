import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state_service.dart';

final authStateProvider = Provider<AuthStateService>((ref) => authStateService);
