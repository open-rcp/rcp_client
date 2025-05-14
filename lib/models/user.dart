// User model for authentication and user information
class User {
  /// Unique identifier for the user 
  final String id;
  
  /// Username for authentication
  final String username;
  
  /// Display name (if different from username)
  final String? displayName;
  
  /// User email address
  final String? email;
  
  /// User profile image (base64 encoded if available)
  final String? avatarData;
  
  /// User roles or permissions
  final List<String> roles;
  
  /// User preferences
  final Map<String, dynamic> preferences;
  
  /// Authentication token (if applicable)
  final String? token;
  
  /// Whether the user credentials should be remembered
  final bool rememberMe;

  /// Constructor
  User({
    required this.id,
    required this.username,
    this.displayName,
    this.email,
    this.avatarData,
    this.roles = const [],
    this.preferences = const {},
    this.token,
    this.rememberMe = false,
  });

  /// Create an anonymous/guest user
  factory User.guest() {
    return User(
      id: 'guest',
      username: 'guest',
      displayName: 'Guest User',
      roles: ['guest'],
    );
  }

  /// Create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      avatarData: json['avatar_data'] as String?,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      token: json['token'] as String?,
      rememberMe: json['remember_me'] as bool? ?? false,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'email': email,
      'avatar_data': avatarData,
      'roles': roles,
      'preferences': preferences,
      'token': token,
      'remember_me': rememberMe,
    };
  }

  /// Create a copy of this User with the specified fields replaced
  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? avatarData,
    List<String>? roles,
    Map<String, dynamic>? preferences,
    String? token,
    bool? rememberMe,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarData: avatarData ?? this.avatarData,
      roles: roles ?? this.roles,
      preferences: preferences ?? this.preferences,
      token: token ?? this.token,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
  
  /// Check if the user has a specific role
  bool hasRole(String role) => roles.contains(role);
  
  /// Check if the user is authenticated (non-guest)
  bool get isAuthenticated => id != 'guest' && username != 'guest';
}
