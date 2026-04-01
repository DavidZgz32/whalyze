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
    _loadWrappeds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWrappeds();
  }

  void _loadWrappeds() {
    final loadedWrappeds = WrappedStorage.getAllWrappeds();
    setState(() {
      _wrappeds = loadedWrappeds;
    });
  }

  /// Grupo WhatsApp: más de 2 participantes. 1:1 queda en Individual.
  static bool _isGroupChat(WrappedModel w) => w.participants.length > 2;

  List<WrappedModel> get _individualWrappeds =>
      _wrappeds.where((w) => !_isGroupChat(w)).toList();

  List<WrappedModel> get _groupWrappeds =>
      _wrappeds.where((w) => _isGroupChat(w)).toList();

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _tabLabel(String emoji, String label) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrappedList(List<WrappedModel> items, String emptyMessage) {
    if (items.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final wrapped = items[index];
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
                          '${wrapped.participants.length} participantes',
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
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Quieres compartir?',
                                style: GoogleFonts.poppins(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Próximamente',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cerrar',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFFE8F2FF);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: appBarColor,
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Material(
              color: appBarColor,
              child: TabBar(
                labelColor: const Color(0xFF006B7A),
                unselectedLabelColor: Colors.black54,
                indicatorColor: const Color(0xFF00A6B6),
                indicatorWeight: 3,
                tabs: [
                  _tabLabel('👤', 'Individual'),
                  _tabLabel('👥', 'Grupo'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildWrappedList(
              _individualWrappeds,
              '¡Todavía no has creado ningún wrapped! Importa un chat y analiza vuestra actividad.',
            ),
            _buildWrappedList(
              _groupWrappeds,
              '¡Todavía no has creado ningún wrapped grupal! Importa un chat grupal y analiza vuestra actividad en grupo.',
            ),
          ],
        ),
      ),
    );
  }
}
