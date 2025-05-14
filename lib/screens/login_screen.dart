import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/copyable_error_message.dart';
import 'app_launcher_screen.dart';

/// Screen for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkStoredCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Check for stored credentials and try to auto-login
  Future<void> _checkStoredCredentials() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.checkStoredCredentials();
      
      if (user != null) {
        if (!mounted) return;
        _handleSuccessfulLogin(user);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Auto-login error: $e';
        _isLoading = false;
      });
    }
  }

  /// Handle login button press
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final username = _usernameController.text;
    final password = _passwordController.text;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final user = await _authService.login(
        username,
        password,
        rememberMe: _rememberMe,
      );
      
      if (!mounted) return;
      _handleSuccessfulLogin(user);
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed: $e';
        _isLoading = false;
      });
    }
  }

  /// Handle successful login and navigate to app launcher
  void _handleSuccessfulLogin(User user) {
    // Update app state
    final appState = context.read<AppState>();
    appState.setAuthenticated(true, user: user);
    
    // Navigate to app launcher screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppLauncherScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading && _errorMessage == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildLoginForm(),
                ),
              ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo or icon
          const Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          
          // Error message
          if (_errorMessage != null) ...[
            CopyableErrorMessage(
              message: _errorMessage!,
              title: 'Authentication Error',
            ),
            const SizedBox(height: 16),
          ],
          
          // Username input field
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) => FormValidators.validateRequired(value, fieldName: 'Username'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          
          // Password input field
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) => FormValidators.validateRequired(value, fieldName: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          
          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text('Remember me'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Login button
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Login'),
          ),
          const SizedBox(height: 16),
          
          // Back button
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    // Reset connection in app state
                    final appState = context.read<AppState>();
                    appState.setConnected(false);
                    
                    // Navigate back to connection screen
                    Navigator.of(context).pop();
                  },
            child: const Text('Back to Connection'),
          ),
        ],
      ),
    );
  }
}
