import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/providers/user_auth_provider.dart';
import 'package:book_tracker/utils/form_validators.dart';
import 'package:book_tracker/screens/auth/signup_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailPassword() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 50)); // Allow DOM to update
    if (!_formKey.currentState!.validate()) return;

    try {
      await Provider.of<UserAuthProvider>(context, listen: false).signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      // Error will be shown via the auth provider's error property
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 50)); // Allow DOM to update
    try {
      await Provider.of<UserAuthProvider>(context, listen: false).signInWithGoogle();
    } catch (e) {
      // Error will be shown via the auth provider's error property
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _forgotPassword() async {
    // Show dialog to get email
    final emailController = TextEditingController();
    String? errorMessage;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your email to receive a password reset link'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
                    await authProvider.resetPassword(emailController.text.trim());
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset email sent. Check your inbox.'),
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      errorMessage = e.toString();
                    });
                  }
                },
                child: const Text('SEND'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<UserAuthProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    // Robust navigation after successful login
    if (authProvider.error == null && authProvider.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decoration
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(
                    Icons.auto_stories,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.menu_book,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Main content
              Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App logo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_stories,
                              size: 60,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Card containing form
                          Container(
                            width: min(screenSize.width * 0.9, 400),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header
                                  Text(
                                    'Welcome Back',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue your reading journey',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Error message
                                  if (authProvider.error != null)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        authProvider.error!,
                                        style: TextStyle(color: theme.colorScheme.error),
                                      ),
                                    ),
                                  if (authProvider.error != null) const SizedBox(height: 16),
                                  
                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                      ),
                                    ),
                                    validator: FormValidators.validateEmail,
                                    textInputAction: TextInputAction.next,
                                    enabled: !authProvider.isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Password field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                      ),
                                    ),
                                    validator: FormValidators.validatePassword,
                                    onFieldSubmitted: (_) => _signInWithEmailPassword(),
                                    enabled: !authProvider.isLoading,
                                  ),
                                  
                                  // Forgot Password link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: authProvider.isLoading ? null : _forgotPassword,
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Sign In button
                                  ElevatedButton(
                                    onPressed: authProvider.isLoading ? null : _signInWithEmailPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey[300])),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey[300])),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Google Sign In button
                                  OutlinedButton.icon(
                                    onPressed: authProvider.isLoading ? null : _signInWithGoogle,
                                    icon: SvgPicture.asset(
                                      'assets/images/google_logo.svg',
                                      height: 20,
                                    ),
                                    label: const Text('Sign in with Google'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      side: BorderSide(color: Colors.grey[300]!),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Sign Up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  double min(double a, double b) {
    return a < b ? a : b;
  }
}
