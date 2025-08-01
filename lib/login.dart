import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoginMode = true;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;

        if (user != null) {
          await user.reload();
          user = FirebaseAuth.instance.currentUser;

          if (user != null && !user.emailVerified) {
            await FirebaseAuth.instance.signOut();
            setState(() {
              _errorMessage =
              'Por favor verifica tu correo antes de iniciar sesión.';
            });
            return;
          }
        }
      } else {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;

        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();

          setState(() {
            _errorMessage =
            'Se ha enviado un correo de verificación a $email. Por favor, verifica tu correo.';
            _isLoginMode = true;
          });

          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'El correo electrónico no es válido.';
          break;
        case 'user-disabled':
          message = 'Esta cuenta ha sido deshabilitada.';
          break;
        case 'user-not-found':
          message = 'No hay ninguna cuenta registrada con ese correo.';
          break;
        case 'wrong-password':
          message = 'La contraseña es incorrecta.';
          break;
        case 'email-already-in-use':
          message = 'El correo ya está registrado.';
          break;
        case 'weak-password':
          message = 'La contraseña es muy débil.';
          break;
        case 'too-many-requests':
          message =
          'Solo se puede intentar una vez. Intenta con otro correo o vuelve en 10 minutos.';
          break;
        default:
          message = 'Error inesperado: ${e.message}';
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = '';
    });
  }

  Future<void> _resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo de verificación reenviado.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar correo: $e')),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Ingresa tu correo electrónico para restablecer la contraseña.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se ha enviado un enlace de recuperación a $email'),
          backgroundColor: Colors.deepPurple,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.code == 'user-not-found'
            ? 'No existe una cuenta con ese correo.'
            : 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [

          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: Colors.white.withOpacity(0.2),
                spawnMinSpeed: 20,
                spawnMaxSpeed: 40,
                spawnMinRadius: 1,
                spawnMaxRadius: 3,
                particleCount: 70,
              ),
            ),
            vsync: this,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6A0572),
                    Color(0xFFC72C39),
                    Color(0xFF6A0572),
                  ],
                ),
              ),
            ),
          ),

          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: Colors.white.withOpacity(0.6),
                spawnMinSpeed: 5,
                spawnMaxSpeed: 20,
                spawnMinRadius: 2,
                spawnMaxRadius: 4,
                particleCount: 50,
              ),
            ),
            vsync: this,
            child: Container(),
          ),

          // Contenido del login
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                color: Colors.white.withOpacity(0.93),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.graphic_eq,
                          size: 64, color: Color(0xFF9D50BB)),
                      const SizedBox(height: 8),
                      Text(
                        'SpotifyMe',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _isLoginMode ? '¡Hola otra vez!' : 'Crear cuenta',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Campo de correo electrónico
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de contraseña
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_isLoginMode)
                        const SizedBox(height: 10),
                      if (_isLoginMode)
                        Center(
                          child: TextButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Color(0xFF9D50BB)),
                            ),
                          ),
                        ),


                      // Botón principal
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9D50BB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : Text(
                            _isLoginMode
                                ? 'Iniciar sesión'
                                : 'Registrarse',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mensaje de error
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 24),

                      // Botón para cambiar de modo login/registro
                      TextButton(
                        onPressed: _isLoading ? null : _toggleMode,
                        child: Text(
                          _isLoginMode
                              ? '¿No tienes cuenta? Crear una'
                              : '¿Ya tienes cuenta? Iniciar sesión',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9D50BB),
                          ),
                        ),
                      ),

                      // Botón para reenviar correo de verificación
                      if (_errorMessage.contains('verificación'))
                        TextButton(
                          onPressed: _resendVerificationEmail,
                          child: const Text(
                            'Reenviar correo de verificación',
                            style: TextStyle(color: Color(0xFF9D50BB)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
