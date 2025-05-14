import 'package:flutter/material.dart';

import '../models/app_info.dart';
import '../utils/constants.dart';

/// Widget for displaying a remote application in the grid
class AppCard extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;
  
  const AppCard({
    super.key,
    required this.app,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: app.available ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App icon
            Expanded(
              flex: 3,
              child: _buildAppIcon(),
            ),
            
            // App information
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Make column take minimum space needed
                  children: [
                    // App name
                    Text(
                      app.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // App description
                    if (app.description != null) ...[
                      Flexible(  // Wrap with Flexible to prevent overflow
                        child: Text(
                          app.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1, // Reduced from 2 to 1 to save space
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    // App metadata
                    Flexible(  // Wrap with Flexible to prevent overflow
                      child: Row(
                        children: [
                          // Publisher
                          if (app.publisher != null) ...[
                            Expanded(
                              child: Text(
                                app.publisher!,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          
                          // Version
                          if (app.version != null) ...[
                            Text(
                              'v${app.version}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Launch bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tags (if any)
                  if (app.tags.isNotEmpty)
                    Expanded(
                      child: Text(
                        app.tags.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Launch button
                  if (app.available)
                    const Icon(
                      Icons.launch,
                      size: 18,
                    )
                  else
                    const Icon(
                      Icons.lock,
                      size: 18,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppIcon() {
    // If we have icon data, use it
    if (app.iconData != null) {
      // In a real implementation, we would decode the icon data
      return Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.apps,
          size: AppConstants.appCardIconSize,
          color: Colors.blue,
        ),
      );
    }
    
    // Otherwise, use a placeholder based on the app name
    final nameInitial = app.name.isNotEmpty ? app.name[0].toUpperCase() : '?';
    
    return Container(
      color: _getColorFromString(app.name),
      alignment: Alignment.center,
      child: Text(
        nameInitial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Color _getColorFromString(String input) {
    // Generate a deterministic color based on the string
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.red,
      Colors.cyan,
      Colors.amber[700]!,
    ];
    
    int hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final index = (hash % colors.length).abs();
    return colors[index];
  }
}
