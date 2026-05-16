import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

// ── Model ──────────────────────────────────────────────────────────────────

class Product {
  final int? id;
  final int categoryId;
  final String name;
  final String description;
  final double weightKg;

  const Product({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.weightKg,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    categoryId: json['category_id'],
    name: json['name'],
    description: json['description'] ?? '',
    weightKg: double.tryParse(json['weight_kg'].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'name': name,
    'description': description,
    'weight_kg': weightKg,
  };
}

class ProductCategory {
  final int id;
  final String name;
  final int creditPerKg;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.creditPerKg,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id: json['id'],
        name: json['name'],
        creditPerKg: json['credit_per_kg'] ?? 0,
      );
}

// ── Halaman utama daftar produk ────────────────────────────────────────────

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _fetchProducts();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse('$apiStoreBaseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _products = data.map((e) => Product.fromJson(e)).toList();
        });
        _animCtrl.forward(from: 0);
      } else {
        setState(() => _error = 'Gagal memuat produk.');
      }
    } catch (_) {
      setState(() => _error = 'Tidak dapat terhubung ke server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await _showDeleteDialog();
    if (!confirm) return;

    try {
      final token = await _getToken();
      final res = await http.delete(
        Uri.parse('$apiStoreBaseUrl/products/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        _fetchProducts();
        if (mounted) {
          _showSnack('Produk berhasil dihapus', isError: false);
        }
      } else {
        if (mounted) _showSnack('Gagal menghapus produk');
      }
    } catch (_) {
      if (mounted) _showSnack('Tidak dapat terhubung ke server');
    }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: const Color(0xFF1C1F2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D4D).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hapus Produk',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Produk ini akan dihapus secara permanen. Yakin?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogButton(
                          label: 'Batal',
                          onTap: () => Navigator.pop(ctx, false),
                          isDestructive: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dialogButton(
                          label: 'Hapus',
                          onTap: () => Navigator.pop(ctx, true),
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  Widget _dialogButton({
    required String label,
    required VoidCallback onTap,
    required bool isDestructive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFF4D4D).withOpacity(0.15)
              : const Color(0xFF2A2D3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFF4D4D).withOpacity(0.4)
                : const Color(0xFF3A3D4E),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? const Color(0xFFFF6B6B) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? const Color(0xFFFF4D4D)
            : const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openForm({Product? product}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
    if (result == true) _fetchProducts();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
   appBar: AppBar(
    backgroundColor: const Color(0xFF1C1F2E),
    elevation: 0,
    surfaceTintColor: Colors.transparent,

    leading: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF3A3D4E),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    ),
 
    titleSpacing: 8,
    title: const Text(
      'Donasi Saya',
      style: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),

    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: _fetchProducts,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF3A3D4E),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF8A8FA8),
              size: 18,
            ),
          ),
        ),
      ),
    ],

    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        color: const Color(0xFF2A2D3E),
      ),
    ),
  ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
    );
  }

 Widget _buildBody() {
  if (_loading) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF6C63FF),
        strokeWidth: 2.5,
      ),
    );
  }

  if (_error != null) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFF8A8FA8),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(
              color: Color(0xFF8A8FA8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _fetchProducts,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2D3E)),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  if (_products.isEmpty) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2D3E)),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF8A8FA8),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada produk',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambahkan sampah yang ingin kamu donasikan',
            style: TextStyle(
              color: Color(0xFF8A8FA8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  return FadeTransition(
    opacity: _fadeAnim,
    child: ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2A2D3E),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),              
                ],
              ),

              const SizedBox(height: 10),

              Text(
                product.description,
                style: const TextStyle(
                  color: Color(0xFF8A8FA8),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.scale_outlined,
                    color: Color(0xFF8A8FA8),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${product.weightKg} kg',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  _actionButton(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF6C63FF),
                    onTap: () => _openForm(product: product),
                  ),

                  const SizedBox(width: 10),

                  _actionButton(
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFFF4D4D),
                    onTap: () => _deleteProduct(product.id!),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// ── Form Tambah / Edit produk ──────────────────────────────────────────────

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  List<ProductCategory> _categories = [];
  int? _selectedCategoryId;
  bool _loading = false;
  bool _loadingCats = true;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    if (_isEdit) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _weightCtrl.text = widget.product!.weightKg.toString();
      _selectedCategoryId = widget.product!.categoryId;
    }
    _fetchCategories();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchCategories() async {
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse('$apiStoreBaseUrl/categories'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _categories = data.map((e) => ProductCategory.fromJson(e)).toList();
          if (!_isEdit && _categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    } catch (_) {
    } finally {
      setState(() => _loadingCats = false);
      _animCtrl.forward();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final body = jsonEncode({
      'category_id': _selectedCategoryId,
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'weight_kg': double.tryParse(_weightCtrl.text) ?? 0,
    });

    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response res;
      if (_isEdit) {
        res = await http.put(
          Uri.parse('$apiStoreBaseUrl/products/${widget.product!.id}'),
          headers: headers,
          body: body,
        );
      } else {
        res = await http.post(
          Uri.parse('$apiStoreBaseUrl/products'),
          headers: headers,
          body: body,
        );
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        final decoded = jsonDecode(res.body);
        setState(() {
          _error = decoded['message'] ?? 'Gagal menyimpan produk.';
        });
      }
    } catch (_) {
      setState(() => _error = 'Tidak dapat terhubung ke server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1F2E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3A3D4E), width: 1),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          _isEdit ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF2A2D3E)),
        ),
      ),
      body: _loadingCats
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
                strokeWidth: 2.5,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error
                        if (_error != null) ...[
                          _errorBanner(_error!),
                          const SizedBox(height: 20),
                        ],

                        // Kategori dropdown
                        _sectionLabel('Kategori Sampah'),
                        const SizedBox(height: 8),
                        _categoryDropdown(),
                        const SizedBox(height: 20),

                        // Nama produk
                        _sectionLabel('Nama Produk'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _nameCtrl,
                          hint: 'Contoh: Botol plastik bekas',
                          icon: Icons.inventory_2_outlined,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Nama produk wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Deskripsi
                        _sectionLabel('Deskripsi'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _descCtrl,
                          hint: 'Deskripsi kondisi produk (opsional)',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Berat
                        _sectionLabel('Estimasi Berat (kg)'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _weightCtrl,
                          hint: 'Contoh: 1.5',
                          icon: Icons.scale_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Berat wajib diisi';
                            }
                            if (double.tryParse(v) == null) {
                              return 'Masukkan angka yang valid';
                            }
                            if (double.parse(v) <= 0) {
                              return 'Berat harus lebih dari 0';
                            }
                            return null;
                          },
                        ),

                        // Kredit preview
                        if (_selectedCategoryId != null) ...[
                          const SizedBox(height: 16),
                          _creditPreview(),
                        ],

                        const SizedBox(height: 32),

                        // Submit button
                        _submitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: Color(0xFF8A8FA8),
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  Widget _errorBanner(String msg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFF4D4D).withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFF4D4D).withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFFF6B6B),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            msg,
            style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _categoryDropdown() => DropdownButtonFormField<int>(
    value: _selectedCategoryId,
    dropdownColor: const Color(0xFF1C1F2E),
    iconEnabledColor: const Color(0xFF8A8FA8),
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: InputDecoration(
      prefixIcon: const Icon(
        Icons.category_outlined,
        color: Color(0xFF8A8FA8),
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFF1C1F2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A2D3E), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
    ),
    items: _categories
        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
        .toList(),
    onChanged: (v) => setState(() => _selectedCategoryId = v),
    validator: (v) => v == null ? 'Pilih kategori' : null,
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    cursorColor: const Color(0xFF6C63FF),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF4A4D5E), fontSize: 14),
      prefixIcon: maxLines == 1
          ? Icon(icon, color: const Color(0xFF8A8FA8), size: 20)
          : null,
      filled: true,
      fillColor: const Color(0xFF1C1F2E),
      contentPadding: EdgeInsets.symmetric(
        horizontal: maxLines > 1 ? 16 : 0,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A2D3E), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF4D4D), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF4D4D), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
    ),
  );

  Widget _creditPreview() {
    final cat = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => const ProductCategory(id: 0, name: '', creditPerKg: 0),
    );
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final estimated = (cat.creditPerKg * weight).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFF6C63FF), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${cat.creditPerKg} kredit/kg · estimasi $estimated kredit',
              style: const TextStyle(color: Color(0xFF9D96FF), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() => GestureDetector(
    onTap: _loading ? null : _submit,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        gradient: _loading
            ? null
            : const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: _loading ? const Color(0xFF2A2D3E) : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _loading
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Center(
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF6C63FF),
                ),
              )
            : Text(
                _isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    ),
  );
}
