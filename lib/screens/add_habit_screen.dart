// lib/screens/add_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  String _icon      = 'star';
  String _color     = '#6C63FF';
  String _frequency = 'daily';
  bool _loading     = false;
  Map? _editHabit;

  final List<Map<String, String>> _icons = [
    {'icon': 'fitness_center', 'label': 'Olahraga'},
    {'icon': 'menu_book', 'label': 'Baca'},
    {'icon': 'water_drop', 'label': 'Minum Air'},
    {'icon': 'self_improvement', 'label': 'Meditasi'},
    {'icon': 'restaurant', 'label': 'Makan Sehat'},
    {'icon': 'bedtime', 'label': 'Tidur Cukup'},
    {'icon': 'code', 'label': 'Coding'},
    {'icon': 'brush', 'label': 'Seni'},
    {'icon': 'music_note', 'label': 'Musik'},
    {'icon': 'star', 'label': 'Lainnya'},
  ];

  final List<Map<String, String>> _colors = [
    {'color': '#6C63FF', 'label': 'Ungu'},
    {'color': '#E91E63', 'label': 'Merah muda'},
    {'color': '#2196F3', 'label': 'Biru'},
    {'color': '#4CAF50', 'label': 'Hijau'},
    {'color': '#FF9800', 'label': 'Oranye'},
    {'color': '#00BCD4', 'label': 'Cyan'},
    {'color': '#9C27B0', 'label': 'Ungu tua'},
    {'color': '#F44336', 'label': 'Merah'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _editHabit = ModalRoute.of(context)?.settings.arguments as Map?;
    if (_editHabit != null && _nameCtrl.text.isEmpty) {
      _nameCtrl.text = _editHabit!['name'] ?? '';
      _descCtrl.text = _editHabit!['description'] ?? '';
      _icon      = _editHabit!['icon'] ?? 'star';
      _color     = _editHabit!['color'] ?? '#6C63FF';
      _frequency = _editHabit!['frequency'] ?? 'daily';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final hp   = context.read<HabitProvider>();
    final data = {
      if (_editHabit != null) 'id': _editHabit!['id'],
      'name':        _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'icon':        _icon,
      'color':       _color,
      'frequency':   _frequency,
    };

    final ok = _editHabit != null
        ? await hp.updateHabit(data)
        : await hp.createHabit(data);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan habit'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editHabit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Habit' : 'Tambah Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama habit *',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              // Frekuensi
              const Text('Frekuensi', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _FreqChip(label: 'Harian', value: 'daily', selected: _frequency == 'daily',
                      onTap: () => setState(() => _frequency = 'daily')),
                  const SizedBox(width: 12),
                  _FreqChip(label: 'Mingguan', value: 'weekly', selected: _frequency == 'weekly',
                      onTap: () => setState(() => _frequency = 'weekly')),
                ],
              ),
              const SizedBox(height: 24),

              // Pilih ikon
              const Text('Ikon', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((ic) {
                  final selected = _icon == ic['icon'];
                  return GestureDetector(
                    onTap: () => setState(() => _icon = ic['icon']!),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected ? _parseColor(_color).withOpacity(0.15) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? _parseColor(_color) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(_iconData(ic['icon']!),
                          color: selected ? _parseColor(_color) : Colors.grey),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Pilih warna
              const Text('Warna', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((c) {
                  final selected = _color == c['color'];
                  return GestureDetector(
                    onTap: () => setState(() => _color = c['color']!),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(c['color']!),
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(color: Colors.black54, width: 3)
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(isEdit ? Icons.save : Icons.add),
                      label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Habit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    const map = {
      'fitness_center': Icons.fitness_center,
      'menu_book': Icons.menu_book,
      'water_drop': Icons.water_drop,
      'self_improvement': Icons.self_improvement,
      'restaurant': Icons.restaurant,
      'bedtime': Icons.bedtime,
      'code': Icons.code,
      'brush': Icons.brush,
      'music_note': Icons.music_note,
      'star': Icons.star,
    };
    return map[name] ?? Icons.star;
  }
}

class _FreqChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _FreqChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
