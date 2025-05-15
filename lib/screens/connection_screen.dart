import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../services/rcp_service.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/copyable_error_message.dart';
import 'login_screen.dart';

/// Screen for connecting to an RCP server
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();

  final _rcpService = RcpService();
  final _settingsService = SettingsService();

  List<String> _recentServers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  /// Load saved settings and recent servers
  Future<void> _initializeSettings() async {
    setState(() => _isLoading = true);

    try {
      // Initialize the FFI bridge
      await _rcpService.initialize();

      // Load default connection settings
      final host = await _settingsService.getDefaultHost();
      final port = await _settingsService.getDefaultPort();

      // Load recent servers
      final recentServers = await _settingsService.getRecentServers();

      // Update UI
      setState(() {
        _hostController.text = host;
        _portController.text = port.toString();
        _recentServers = recentServers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
        _isLoading = false;
      });
    }
  }

  /// Connect to the RCP server
  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final host = _hostController.text;
    final port = int.parse(_portController.text);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _rcpService.connect(host, port);

      if (success) {
        // Save the connection settings
        await _settingsService.setDefaultHost(host);
        await _settingsService.setDefaultPort(port);
        await _settingsService.addRecentServer('$host:$port');

        // Update the app state
        if (!mounted) return;
        final appState = context.read<AppState>();
        appState.setConnected(true);
        appState.setServerInfo(host, port);

        // Navigate to login screen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to the server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  /// Select a recent server from the dropdown
  void _selectRecentServer(String? server) {
    if (server == null || server.isEmpty) {
      return;
    }

    final parts = server.split(':');
    if (parts.length == 2) {
      setState(() {
        _hostController.text = parts[0];
        _portController.text = parts[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to RCP Server')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading && _errorMessage == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _buildConnectionForm(),
                  ),
                ),
      ),
    );
  }

  Widget _buildConnectionForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo or icon
            const Icon(
              Icons.cloud_outlined,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null) ...[
              CopyableErrorMessage(
                message: _errorMessage!,
                title: 'Connection Error',
              ),
              const SizedBox(height: 16),
            ],

            // Recent servers dropdown
            if (_recentServers.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Recent Servers',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.history),
                ),
                items:
                    _recentServers
                        .map(
                          (server) => DropdownMenuItem(
                            value: server,
                            child: Text(server),
                          ),
                        )
                        .toList(),
                onChanged: _selectRecentServer,
                hint: const Text('Select a recent server'),
              ),
              const SizedBox(height: 16),
            ],

            // Host input field
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Server Hostname or IP',
                hintText: 'e.g., localhost or 192.168.1.100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
              validator: FormValidators.validateHostname,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Port input field
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '8717',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings_ethernet),
              ),
              validator: FormValidators.validatePort,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Connect button
            ElevatedButton(
              onPressed: _isLoading ? null : _connect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Connect'),
            ),
            const SizedBox(height: 24),

            // Version info
            Text(
              'RCP Client v${AppConstants.appVersion}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
