// App information model for RCP applications
class AppInfo {
  /// Unique identifier for the application
  final String id;
  
  /// Display name of the application
  final String name;
  
  /// Optional description of the application
  final String? description;
  
  /// Application icon data (base64 encoded if available)
  final String? iconData;
  
  /// Timestamp when the app was last launched (null if never launched)
  final DateTime? lastLaunch;
  
  /// Version information for the application
  final String? version;
  
  /// Publisher or author of the application
  final String? publisher;
  
  /// Tags or categories for the application
  final List<String> tags;
  
  /// Whether this application is available to launch
  final bool available;

  /// Constructor
  AppInfo({
    required this.id,
    required this.name,
    this.description,
    this.iconData,
    this.lastLaunch,
    this.version,
    this.publisher,
    this.tags = const [],
    this.available = true,
  });

  /// Create an AppInfo from JSON data
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconData: json['icon_data'] as String?,
      lastLaunch: json['last_launch'] != null 
          ? DateTime.parse(json['last_launch'] as String) 
          : null,
      version: json['version'] as String?,
      publisher: json['publisher'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      available: json['available'] as bool? ?? true,
    );
  }

  /// Convert AppInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_data': iconData,
      'last_launch': lastLaunch?.toIso8601String(),
      'version': version,
      'publisher': publisher,
      'tags': tags,
      'available': available,
    };
  }

  /// Create a copy of this AppInfo with the specified fields replaced
  AppInfo copyWith({
    String? id,
    String? name,
    String? description,
    String? iconData,
    DateTime? lastLaunch,
    String? version,
    String? publisher,
    List<String>? tags,
    bool? available,
  }) {
    return AppInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconData: iconData ?? this.iconData,
      lastLaunch: lastLaunch ?? this.lastLaunch,
      version: version ?? this.version,
      publisher: publisher ?? this.publisher,
      tags: tags ?? this.tags,
      available: available ?? this.available,
    );
  }
}
