import 'package:flutter/material.dart';

void main() {
  runApp(const UninorteInnovacionApp());
}

class UninorteInnovacionApp extends StatelessWidget {
  const UninorteInnovacionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innovación Uninorte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E1E1E),
          primary: const Color(0xFF1E1E1E),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const FeedScreen(),
    );
  }
}

// ==========================================
// FLUJO 2: EXPLORACIÓN (VERSIÓN B - CHIPS)
// ==========================================
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedFilter = 'Todos';

  final List<String> filters = [
    'Todos',
    'Buscan Diseñador UI',
    'Buscan Dev Frontend',
    'Ingeniería',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explorar Proyectos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1E1E1E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              size: 28,
              color: Color(0xFF1E1E1E),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PublicarProyectoScreen(),
                ),
              );
            },
            tooltip: 'Publicar Iniciativa',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar iniciativa...',
                hintStyle: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Chips de Filtro Horizontal (Versión B)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    backgroundColor: const Color(0xFFF2F2F2),
                    selectedColor: const Color(0xFF1E1E1E),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E1E1E),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // Feed de Proyectos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (selectedFilter == 'Todos' ||
                    selectedFilter == 'Buscan Diseñador UI' ||
                    selectedFilter == 'Ingeniería')
                  _buildProjectCard(
                    context,
                    title: 'Unisports',
                    faculty: 'Ingeniería de Sistemas',
                    leader: 'Luis Robles',
                    description: 'Plataforma centralizada para conectar deportistas universitarios y organizar torneos internos en el campus de Uninorte.',
                    vacancies: ['Buscan: Diseñador UI', 'Buscan: Dev Frontend'],
                  ),
                const SizedBox(height: 16),
                if (selectedFilter == 'Todos' ||
                    selectedFilter == 'Buscan Dev Frontend')
                  _buildProjectCard(
                    context,
                    title: 'EcoCampus Uninorte',
                    faculty: 'Diseño Industrial',
                    leader: 'Vanessa Orozco',
                    description: 'Sistema de reciclaje e incentivos dinámicos dentro de la universidad mediante código QR.',
                    vacancies: ['Buscan: Dev Frontend'],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context, {
    required String title,
    required String faculty,
    required String leader,
    required String description,
    required List<String> vacancies,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleProyectoScreen(
              title: title,
              faculty: faculty,
              leader: leader,
              description: description,
              vacancies: vacancies,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$faculty • Por: $leader',
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE0E0E0)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vacancies.map((vacant) {
                final isHighlighted = vacant.contains('Diseñador UI');
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    vacant,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted
                          ? Colors.white
                          : const Color(0xFF1E1E1E),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// FLUJO 3: POSTULACIÓN (VERSIÓN A)
// ==========================================
class DetalleProyectoScreen extends StatelessWidget {
  final String title;
  final String faculty;
  final String leader;
  final String description;
  final List<String> vacancies;

  const DetalleProyectoScreen({
    super.key,
    required this.title,
    required this.faculty,
    required this.leader,
    required this.description,
    required this.vacancies,
  });

  void _mostrarDialogoPostulacion(BuildContext context, String rol) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Postularme como $rol',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escribe un mensaje breve para el líder de la iniciativa:',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ej. Hola, me interesa el proyecto y tengo experiencia en Figma...',
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Postulación enviada con éxito!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Enviar Postulación',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha de Proyecto', style: TextStyle(fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$faculty • Liderado por $leader',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción General',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Vacantes Disponibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...vacancies.map((v) {
              final rolLimpio = v.replaceAll('Buscan: ', '');
              return Card(
                elevation: 0,
                color: const Color(0xFFF2F2F2),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    rolLimpio,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Requisitos: Trabajo en equipo e interés académico.',
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () =>
                        _mostrarDialogoPostulacion(context, rolLimpio),
                    child: const Text(
                      'Postular',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// FLUJO 1: PUBLICAR IDEA (VERSIÓN A PASO A PASO)
// ==========================================
class PublicarProyectoScreen extends StatefulWidget {
  const PublicarProyectoScreen({super.key});

  @override
  State<PublicarProyectoScreen> createState() => _PublicarProyectoScreenState();
}

class _PublicarProyectoScreenState extends State<PublicarProyectoScreen> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publicar Nueva Iniciativa',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() => currentStep += 1);
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Proyecto publicado directamente en el feed!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: details.onStepContinue,
                  child: Text(
                    currentStep == 2 ? 'Publicar' : 'Siguiente',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text(
                      'Atrás',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Información General'),
            isActive: currentStep >= 0,
            content: const Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nombre de la iniciativa',
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Problema que resuelve',
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Facultad y Categoría'),
            isActive: currentStep >= 1,
            content: const TextField(
              decoration: InputDecoration(
                labelText: 'Facultad principal (ej. Ingeniería)',
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
          Step(
            title: const Text('Vacantes Requeridas'),
            isActive: currentStep >= 2,
            content: const TextField(
              decoration: InputDecoration(
                labelText: 'Roles que buscas (ej. Diseñador UI, Dev Frontend)',
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
