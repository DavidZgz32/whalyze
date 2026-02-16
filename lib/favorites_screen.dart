import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/wrapped_storage.dart';
import 'models/wrapped_model.dart';
import 'wrapped_view_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<WrappedModel> _wrappeds = [];

  @override
  void initState() {
    super.initState();
    print('FavoritesScreen initState - cargando wrappeds...');
    _loadWrappeds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar cuando vuelvas a esta pantalla
    print('FavoritesScreen didChangeDependencies - recargando wrappeds...');
    _loadWrappeds();
  }

  void _loadWrappeds() {
    print('_loadWrappeds() llamado');
    final loadedWrappeds = WrappedStorage.getAllWrappeds();
    print('Wrappeds obtenidos de storage: ${loadedWrappeds.length}');
    setState(() {
      _wrappeds = loadedWrappeds;
      print('Wrappeds cargados en estado: ${_wrappeds.length}');
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F2FF),
        elevation: 0,
        title: Text(
          'Favoritos',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _wrappeds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay wrapped guardados',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _wrappeds.length,
              itemBuilder: (context, index) {
                final wrapped = _wrappeds[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WrappedViewScreen(
                            wrapped: wrapped,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00C980),
                            Color(0xFF00A6B6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wrapped.title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${wrapped.participants.length} participantes • ${wrapped.totalLines} líneas',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(wrapped.createdAt),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Eliminar',
                                    style: GoogleFonts.inter(),
                                  ),
                                  content: Text(
                                    '¿Eliminar este wrapped?',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text(
                                        'Cancelar',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text(
                                        'Eliminar',
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await WrappedStorage.deleteWrapped(wrapped.id);
                                _loadWrappeds();
                              }
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

