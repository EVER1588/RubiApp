import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final String nombre;
  final String imagen;
  final String categoria;
  
  const ItemDetailScreen({
    Key? key,
    required this.nombre,
    required this.imagen,
    required this.categoria,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagen,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(nombre, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Categoría: $categoria", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}