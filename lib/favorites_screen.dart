import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/wrapped_storage.dart';
import 'services/firestore_user_service.dart';
import 'models/wrapped_model.dart';
import 'wrapped_view_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<WrappedModel> _wrappeds = [];
  UserWrappedQuotaSnapshot? _quota;
  bool _quotaLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWrappeds();
    _loadQuota();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWrappeds();
    _loadQuota();
  }

  Future<void> _loadQuota() async {
    final snap = await FirestoreUserService.instance.fetchQuotaSnapshot();
    if (!mounted) return;
    setState(() {
      _quota = snap;
      _quotaLoading = false;
    });
  }

  void _loadWrappeds() {
    final loadedWrappeds = WrappedStorage.getAllWrappeds();
    setState(() {
      _wrappeds = loadedWrappeds;
    });
  }

  String _remainingQuotaSubtitle() {
    if (_quotaLoading) return 'Cargando saldo de wrappeds…';
    final q = _quota;
    if (q == null) {
      return 'No se pudo cargar tu saldo de wrappeds.';
    }
    if (q.hasPaid) {
      return 'Puedes crear wrappeds sin límite.';
    }
    final n = q.wrappedRemaining;
    return 'Te quedan $n créditos (1 crédito = wrapped).';
  }

  static const _coinGoldA = Color(0xFFFFE082);
  static const _coinGoldB = Color(0xFFF9A825);
  static const _coinGoldC = Color(0xFFFFC107);
  static const _coinBorder = Color(0xFFB8860B);
  static const _coinText = Color(0xFF4E342E);

  static const Widget _creditIcon = Icon(
    Icons.monetization_on_rounded,
    color: _coinGoldB,
    size: 26,
    shadows: [
      Shadow(
        color: Color(0x33000000),
        blurRadius: 1,
        offset: Offset(0, 0.5),
      ),
    ],
  );

  Widget _coinBadge({required Widget child}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_coinGoldA, _coinGoldB, _coinGoldC],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _coinBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildQuotaCredits() {
    if (_quotaLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _creditIcon,
          SizedBox(width: 8),
          SizedBox(
            width: 36,
            height: 36,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _coinGoldB,
              ),
            ),
          ),
        ],
      );
    }
    final q = _quota;
    if (q == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on_rounded, color: Colors.grey.shade400, size: 26),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
            child: Center(
              child: Text(
                '?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (q.hasPaid) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _creditIcon,
          const SizedBox(width: 8),
          _coinBadge(
            child: Text(
              '∞',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _coinText,
                height: 1,
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _creditIcon,
        const SizedBox(width: 8),
        _coinBadge(
          child: Text(
            '${q.wrappedRemaining}',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _coinText,
            ),
          ),
        ),
      ],
    );
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
    final subtitle = _remainingQuotaSubtitle();
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
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.35,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWrappedList(
    List<WrappedModel> items,
    String emptyMessage,
  ) {
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
            'Mis wrappeds',
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: _buildQuotaCredits()),
            ),
          ],
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
