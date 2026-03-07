import 'package:flutter/material.dart';
import 'dart:async';

class LoadingBackgroundImage extends StatefulWidget {
  final String imagePath;
  final Widget child;
  final BoxFit fit;

  const LoadingBackgroundImage({
    Key? key,
    required this.imagePath,
    required this.child,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  _LoadingBackgroundImageState createState() => _LoadingBackgroundImageState();
}

class _LoadingBackgroundImageState extends State<LoadingBackgroundImage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeOutController;
  late Animation<double> _fadeOutAnimation;
  bool _isLoading = true;
  bool _imageLoaded = false;
  bool _contentVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    // Solo controlador para desaparición
    _fadeOutController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut)
    );
    
    // Cargar recursos después de un breve retraso
    Future.delayed(Duration(milliseconds: 100), () {
      _loadResources();
    });
  }
  
  Future<void> _loadResources() async {
    try {
      // Cargar la imagen
      final imageProvider = AssetImage(widget.imagePath);
      await precacheImage(imageProvider, context);
      
      // Tiempo mínimo de carga
      await Future.delayed(Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _imageLoaded = true;
          _contentVisible = true;
        });
        
        // Tiempo para que el contenido se renderice
        await Future.delayed(Duration(milliseconds: 100));
        
        // Iniciar animación de desaparición
        _fadeOutController.forward().then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      print('Error cargando recursos: $e');
      
      if (mounted) {
        setState(() {
          _imageLoaded = true;
          _contentVisible = true;
        });
        _fadeOutController.forward().then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
  }
  
  @override
  void dispose() {
    _fadeOutController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo
        if (_imageLoaded)
          Image.asset(
            widget.imagePath,
            fit: widget.fit,
            width: double.infinity,
            height: double.infinity,
          ),
        
        // Contenido principal
        if (_contentVisible) 
          widget.child,
        
        // Overlay de carga (sin animación de entrada)
        if (_isLoading)
          AnimatedBuilder(
            animation: _fadeOutController,
            builder: (context, child) {
              return Opacity(
                opacity: _contentVisible ? _fadeOutAnimation.value : 1.0,
                child: Container(
                  color: Colors.blue.shade700,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}