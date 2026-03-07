import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'concatenacion_screen.dart';
import '../services/tts_manager.dart';

// Constantes para el tamaño de los bloques
const double BLOCK_HEIGHT = 40.0;
const double BLOCK_TEXT_SIZE = 16.0;
const double BLOCK_PADDING = 8.0;
const double BLOCK_SPACING = 8.0;
const double BLOCK_RUN_SPACING = 4.0;
const double CONTAINER_PADDING = 16.0;

// Constantes para los contenedores
const double CONTAINER_1_HEIGHT = 114.0; // Altura fija para 2 líneas de bloques
const double CONTAINER_BORDER_RADIUS = 10.0;
const Color CONTAINER_1_COLOR = Color.fromRGBO(0, 0, 255, 0.3);
const Color CONTAINER_2_COLOR = Color.fromRGBO(0, 128, 0, 0.3);

// Constantes para los botones
const double BUTTON_BORDER_RADIUS = 20.0;
const double BUTTON_PADDING_VERTICAL = 12.0;
const double BUTTON_TEXT_SIZE = 14.0;

// Constantes para el teclado secundario
const double KEYBOARD_WIDTH_FACTOR = 0.9;
const double KEYBOARD_HEIGHT_FACTOR = 0.58;
const double KEYBOARD_BORDER_RADIUS = 15.0;
const double KEYBOARD_GRID_ASPECT_RATIO = 1.3;

// Colores de los bloques
const Color BLOCK_GREEN = Colors.green;
const Color BLOCK_BLUE = Colors.blue;
const Color BLOCK_ORANGE = Colors.orange;
const Color BLOCK_RED = Colors.red;

// Constantes para los chips/bloques
const double CHIP_FONT_SIZE = 16.0;
const double CHIP_HORIZONTAL_PADDING = 8.0;
const double CHIP_VERTICAL_PADDING = 2.0;
const double CHIP_INTERNAL_PADDING = 4.0;
const double CHIP_BORDER_RADIUS = 8.0;
const double CHIP_BORDER_WIDTH = 2.0;

// Constantes para el espaciado entre chips
const double CHIP_SPACING = 8.0;
const double CHIP_RUN_SPACING = 1.0;

// Constantes para los botones circulares
const double ROUND_BUTTON_SIZE = 40.0;
const double ROUND_BUTTON_ICON_SIZE = 24.0;
const double ROUND_BUTTON_BORDER_RADIUS = 20.0;
const double ROUND_BUTTON_BORDER_WIDTH = 2.0;

// Constante para el botón de borrar
const double DELETE_BUTTON_SIZE = 70.0;

// Instancia global de TTS y UUID
final FlutterTts flutterTts = FlutterTts();
final Uuid uuid = Uuid();
final TtsManager ttsManager = TtsManager();

// Configurar Flutter TTS
void configurarFlutterTts() async {
  await flutterTts.setLanguage("es-U S");
  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.awaitSpeakCompletion(true);
}

// Función global actualizada para texto a voz
Future<void> decirTexto(String texto, {bool esSilaba = false}) async {
  if (esSilaba) {
    await ttsManager.speakSpecialSyllable(texto);
  } else {
    await ttsManager.speak(texto);
  }
}

// Nueva función específica para sílabas
Future<void> decirSilaba(String silaba) async {
  await ttsManager.speakSpecialSyllable(silaba);
}

// Función global para detener la reproducción
Future<void> detenerTexto() async {
  await flutterTts.stop();
}

// Función para calcular el número máximo de bloques que caben en un contenedor
int calcularMaximoBloques(double screenWidth) {
  // Estimación de bloques en 2 líneas basada en el ancho de la pantalla
  return ((screenWidth * 0.98) ~/ 80) * 2;
}

// Función para obtener el color según estado del bloque
Color obtenerColorBloque(BlockColor? color) {
  switch (color) {
    case BlockColor.green:
      return BLOCK_GREEN;
    case BlockColor.orange:
      return BLOCK_ORANGE;
    case BlockColor.red:
      return BLOCK_RED;
    default:
      return BLOCK_BLUE;
  }
}

// Función para acentuar automáticamente una sílaba
String acentuarSilaba(String silaba) {
  if (silaba.isEmpty) return silaba;
  
  // Mapa de conversión de vocales normales a acentuadas
  final Map<String, String> vocalesAcentuadas = {
    'a': 'á', 'e': 'é', 'i': 'í', 'o': 'ó', 'u': 'ú',
    'A': 'Á', 'E': 'É', 'I': 'Í', 'O': 'Ó', 'U': 'Ú',
  };
  
  // Encontrar la última vocal en la sílaba
  String ultimaVocal = '';
  int ultimaVocalPos = -1;
  
  for (int i = silaba.length - 1; i >= 0; i--) {
    final char = silaba[i];
    if ('aeiouAEIOU'.contains(char)) {
      ultimaVocal = char;
      ultimaVocalPos = i;
      break;
    }
  }
  
  // Si encontramos una vocal, acentuarla
  if (ultimaVocalPos != -1) {
    final vocalAcentuada = vocalesAcentuadas[ultimaVocal] ?? ultimaVocal;
    return silaba.substring(0, ultimaVocalPos) + 
           vocalAcentuada + 
           silaba.substring(ultimaVocalPos + 1);
  }
  
  return silaba; // Si no hay vocales, devolver la sílaba original
}

// Listas de palabras válidas y otros datos permanecen igual
const List<String> palabrasValidas = [
  "A", "AL", "CON", "DA", "DAN", "DAR", "DE", "DEL", "DI", "DON", "EL", "EN", "ES", 
  "FÉ", "HA", "HE", "IR", "LA", "LAS", "LE", "LES", "LO", "LOS", "LUZ", 
  "MAS", "ME", "MES", "MI", "MIS", "NI", "NO", "NOS", "DOS", "SAL", "SON",
  "QUE", "QUI", "SE", "SER", "SI", "SIN", "SU", "SUS", "FÉ", "FAN", "FIN", 
  "TAL", "TAN", "TE", "TEN", "TU", "TUS", "UN", "GEL", "MAR", "SOL", "SUR",
  "VA", "VAN", "VE", "VEN", "VER", "VES", "VI", "VOY", "VOZ", "SER", "SOS",
  "WEB", "WI", "Y", "YA", "YO", "BUS", "CRUZ", "HAN", "HAN", "HAS", "TRES",

  "ABAJO", "ABANICO", "ABRAZAR", "ABRIGO", "ABRIGOS", "ABRIR", "AGREGADO", "AGREGAN", "AGREGAR", "AGUA", "AGUJA", "AGUJAS", 
  "ABOGADO", "ABOGADA", "ABOGADOS", "ABOGADAS", "CONTADOR", "CONTADORA", "CONTADORES", "CONTADORAS",
  "ACOSTAR", "ACOSTADO", "ACOSTADA", "DORIR", "DORMIDO", "DORMIDA", "DURMINENDO", "PEINA", "PEINADO", "PEINADOS", 
  "AGRICULTURES", "AGRICULTORAS", "CARPINTERO", "CARPINTERA", "CARPINTEROS", "CARPINTERAS", 
  "AGUA", "JUGO", "JUGOS", "REFRESCO", "REFRESCOS", "SODA", "SODAS", "CAFÉ", "DIEZ",
  "ÁGUILA", "ÁGUILAS", "AHORA", "ALGO", "ALLÁ", "ALMOHADA", "ALMOHADAS", "ALTO", "ALTOS", "AMARILLO", "AMARILLOS", 
  "AJO", "AJOS", "PAPA", "PAPAS", "BRÓCOLI", "ESPINA", "ESPINAS", "ESPINACA", "ESPINACAS", "PEPINO", "PEPINOS",
  "ALTAVOZ", "ALTAVOCES", "ESTIRA", "ESTIRAR", "ESTIRANDO", "MANO", "MANOS", "DEDO", "DEDOS", "BRAZO", "BRAZOS", "PIERNA", 
  "ALUMNOS", "ALUMNAS", "SECRETARIO", "SECRETARIA", "CONSERJE", "CONSERJES", "BIBLIOTECARIO", "BIBLIOTECARIA",
  "AMIGA", "AMIGAS", "AMIGO", "AMIGOS", "AMA", "AMAN", "AMO", "AMOR", "ANDAR", "ANIMAL", "ANIMALES", "ANÍMA", "ANIMAR", "ANTES", "AQUÍ", "ÁRBOL", 
  "AÑO", "AÑOS", "CICLO", "CICLOS", "PERÍODO", "PERÍODOS", "SEMANA", "SEMANAS", "DÍA", "DÍAS",
  "ARBUSTO", "ARBUSTOS", "ARDILLA", "ARDILLAS", "ARENA", "ARENAS", "ARCOÍRIS", "ARMARIO", "ARMARIOS", "ARRIBA", "SOMOS", 
  "ARQUITECTO", "ARQUITECTA", "ARQUITECTOS", "ARQUITECTAS", "ENFERMERO", "ENFERMERA", "ENFERMEROS", "ENFERMERAS",
  "ARROZ", "FRIJOL", "FRIJOLES", "LENTEJA", "LENTEJAS", "AVENA", "TRIGO", "SOY", "ASISTE", "ASISTEN", "ASISTIR",
  "ASIENTO", "AVE", "AVES", "AYER", "AZUL", "AZULES", "AZÚCAR", "AZULEJO", "AZULEJOS", "BAILAR", "BAILES", "BAJO", "BAJOS", 
  "BALLENA", "BALLENAS", "ASISTENTE", "ASISTENTES", "PRESIDENTE", "PRESIDENTA", "PRESIDENTES", "PRESIDENTAS",
  "BALLENA", "BARCO", "BARCOS", "BAÑO", "BAÑOS", "BEBÉ", "BEBÉS", "BEBER", "BIEN", "BIENES", "BICICLETA", "BICICLETAS", "BLANCO", "BLANCOS",
  "BERENJENA", "BERENJENAS", "APIO", "REPOLLO", "COLIFLOR", "ESPÁRRAGO", "ESPÁRRAGOS", "CANASTO", "CANASTOS", 
  "BIBLIOTECA", "BIBLIOTECAS", "LABORATORIO", "LABORATORIOS", "PATIO", "PATIOS", "CANA", "CANAS", "CANASTA", "CANASTAS", 
  "BLANCA", "BLANCAS", "BLUSA", "BLUSAS", "BONITA", "BONITAS", "BONITO", "BONITOS", "BOLA", "BOLAS", "BOLSOS", "BOLSO", "BOSQUE", "BOSQUES", "BOTÓN", "BOTONES", 
  "BOLETÍN", "BOLETINES", "EVALUACIÓN", "EVALUACIONES", "PROMEDIO", "PROMEDIOS", "APROBADO", "REPROBADO",
  "BONO", "BONOS", "PRÉSTAMO", "PRÉSTAMOS", "IMPUESTO", "IMPUESTOS", "BALANCE", "BALANCES", "CAPA", "CAPAS", "BANDA", "BANDAS",
  "BANQUETE", "BANQUETES", "BANQUILLO", "BANQUILLOS", "CAPACITA", "CAPACITAN", "CAPACITADO", "CAPACIDAD", 
  "BOTA", "BOTAS", "BOSTEZAR", "BOSTEZO", "BOSTEZOS", "BOTE", "BOTES", "BOYA", "BOYAS", "BRINCAR", "BRISA", "BRISAS", 
  "BÚHO", "BÚHOS", "BUFANDA", "BUFANDAS", "CABALLO", "CABALLOS", "CABRA", "CABRAS", "CACTUS", "CAFÉ", "CALENDARIO", 
  "CABELLO", "HERMOSA", "HERMOSAS", "HERMOSO", "HERMOSOS", "LINDA", "LINDAS", "LINDO", "LINDOS", "RETORO",
  "CALABAZA", "CALABAZAS", "MAÍZ", "RÁBANO", "RÁBANOS", "PIMIENTO", "PIMIENTOS", "MARCA", "MARCADOR", "MARCADORES", 
  "CALENDARIOS", "CALIENTE", "CALIENTES", "CALMA", "CALOR", "CAMAS", "CAMINAR", "CAMINA", "CAMINO", "CAMISA", "CAMISAS", 
  "CAMA", "CAMIÓN", "CAMIONES", "CAMPO", "CAMPOS", "CANASTA", "CANDADO", "CANDADOS", "CANTA", "CANTAR", "CAOS", 
  "CAPACITACIÓN", "CAPACITACIONES", "PRESENTACIÓN", "PRESENTACIONES", "GESTIÓN", "GESTIONES",
  "CARACOL", "CARACOLES", "CARNE", "CARNES", "CARRETERA", "CARRO", "CARROS", "CARTÓN", "CARTONES", "CASA", "CASAS", 
  "CARPETA", "CARPETAS", "FOLDER", "FOLDERS", "DICCIONARIO", "DICCIONARIOS", "ATLAS", "MAPA", "MAPAS", 
  "CARRERA", "CARRERAS", "PROFESIÓN", "PROFESiones", "OFICIO", "OFICIOS", "OCUPACIÓN", "OCUPACIONES",
  "CASCO", "CASCOS", "CELESTE", "CELESTES", "CENTRO", "CERCA", "CERCANO", "CERCANOS", "CERDO", "CERDOS", "CERRAR", 
  "CEREZA", "CEREZAS", "COCO", "COCOS", "KIWI", "KIWIS", "DURAZNO", "DURAZNOS", "MOTIVADO", "MOTIVADA", "MOTIVADOS", "MOTIVADAS", 
  "CHARLA", "CHARLAS", 
  "CHICA", "CHICAS", "CHICO", "CHICOS", "CIEN", "CIENCIA", "CIENCIAS", "CLIP", "CLARO", "CLAROS", "COCINA", "COCO", "COLA", 
  "COLCHÓN", "COLCHONES", "COLORES", "COLOR", "COMEDOR", "COME", "COMER", "COMIDA", "COMO", "COMPÁS", "COMPRAR", 
  "COMERCIO", "INDUSTRIA", "EDUCACIÓN", "SALUD", "TECNOLOGÍA", "CONSTRUCCIÓN", "TRANSPORTE",
  "COMPÁS", "PEGAMENTO", "CRAYÓN", "CRAYONES", "MARCADOR", "MARCADORES", "PIZARRA", "PIZARRÓN",
  "COMPRA", "CONO", "CONOS", "CONTAR", "CONTROL", "CONTROLES", "CORBATAS", "CORBATA", "CORDILLERA", "CORDILLERAS", 
  "COMPUTADORA", "COMPUTADORAS", "IMPRESORA", "IMPRESORAS", "TELÉFONO", "TELÉFONOS", "MÁQUINA", "MÁQUINAS",
  "COMUNICACIÓN", "AGRICULTURA", "GANADERÍA", "PESCA", "MINERÍA", "ENERGÍA", "TURISMO", "GANA", "GANAN",
  "CONDUCTOR", "CONDUCTORA", "COCINERO", "COCINERA", "DOCTOR", "DOCTORA", "PSICÓLOGO", "PSICÓLOGA", 
  "CONGRESO", "CONGRESOS", "INFORME", "INFORMES", "REPORTE", "REPORTES", "PROYECTO", "PROYECTOS",
  "CONSOLA", "CONSOLAS", "JUGO", "JUGOS", "MONTE", "MONTA", "MONTAN", "MONTANDO", "SACA", "SACAR", "SACATE", "RETROVISOR", "RETROVISORES", 
  "CONSULTORÍA", "LOGÍSTICA", "GOBIERNO", "ADMINISTRACIÓN", "DEFENSA", "SEGURIDAD", "TAMBIÉN",
  "COORDINACIÓN", "SUPERVISIÓN", "DELEGACIÓN", "MOTIVACIÓN", "DISCIPLINA", "PERSEVERANCIA",
  "CORDERO", "SALCHICHA", "SALCHICHAS", "JAMÓN", "TOCINO", "BISTEC", "FILETE", "FILETES",
  "CORTINA", "CORTINAS", "CREER", "CUADRADO", "CUADRADOS", "CUARTO", "CUARTOS", "CUCHARA", "CUCHARAS", "CUCHILLO", 
  "CUCHILLOS", "CUMPLIR", "DADO", "DADOS", "DEBER", "DECIR", "DELFIN", "DELFINES", "DENSA", "DENSO", 
  "CUELLO", "DIENTE", "DIENTES", "TOBILLO", "TOBILLOS", "TALÓN", "TALONES", "MEDIA", "MEDIAS", "CALSETÍN", "LLAMA", 
  "DENTISTA", "DENTISTAS", "ELECTRICISTA", "ELECTRICISTAS", "MECÁNICO", "MECÁNICA", "MECÁNICOS", "MECÁNICAS",
  "DENTRO", "DESPUÉS", "DESAYUNAR", "DESAYUNO", "DESAYUNOS", "DESIERTO", "DESIERTOS", "DESTELLO", "DETRÁS", "DIBUJAR", 
  "DEPARTAMENTO", "DEPARTAMENTOS", "DIVISIÓN", "DIVISIONES", "SUCURSAL", "SUCURSALES",
  "DESPACHO", "DESPACHOS", "CONSULTORIO", "CONSULTORIOS", "TIENDA", "TIENDAS", "ESTUDIO", "ESTUDIOS",
  "DESTACADO", "SOBRESALIENTE", "EXCELENTE", "BUENO", "REGULAR", "SUFICIENTE", "INSUFICIENTE",
  "DÍA", "DÍAS", "FOTO", "FOTOS", "FOTOGRAFÍA", "FOTOGRAFÍAS", "TENER", "TENERTE", "TENEMOS", "RECUERDO", "RECUERDOS", "TENIA",
  "DIBUJO", "DIBUJOS", "DIFÍCIL", "DIFICULTAD", "DRONE", "DORMIR", "DORMITORIO", "DORMITORIOS", "DUDA", "DUDAS", "ECHAR", 
  "DIRECTOR", "DIRECTORA", "DIRECTORES", "DIRECTORAS", "ESTUDIANTE", "ESTUDIANTES", "ALUMNO", "ALUMNA",
  "DIRECTOR", "DIRECTORA", "DIRECTORES", "DIRECTORAS", "GERENTE", "GERENTES", "JEFE", "JEFA", "JEFES", "JEFAS",
  "DISEÑADOR", "DISEÑADORA", "DISEÑADORES", "DISEÑADORAS", "CHEF", "CHEFS", "AGRICULTOR", "AGRICULTORA",
  "DULCE", "DULCES", "CHOCOLATE", "CHOCOLATES", "CARAMELO", "CARAMELOS", "POSTRE", "POSTRES", 
  "ECLIPSE", "ELEFANTE", "ELEFANTES", "EMPUJAR", "EMPUJA", "EMPUJAN", "ENCIMA", "ENCONTRAR", "ENCUENTRA", "HACE"
  "EDUCACIÓN", "DEPORTE", "DEPORTES", "TECNOLOGÍA", "LITERATURA", "LECTURA", "ESCRITURA", "GRAMÁTICA",
  "EJECUTIVO", "EJECUTIVA", "EJECUTIVOS", "EJECUTIVAS", "SOCIO", "SOCIA", "SOCIOS", "SOCIAS",
  "EMPRESA", "EMPRESAS", "COMPAÑÍA", "COMPAÑÍAS", "NEGOCIO", "NEGOCIOS", "CORPORACIÓN", "CORPORACIONES",
  "ENCENDER", "ENCENDI", "ENCENDIÓ", "ENCIENDE", "ENCENDIDO", "ENTENDER", "ENTIENDE", "ENTIENDEN", "VEZ", "CORAZÓN", "SOLO", "SOLA", 
  "ENCUENTRO", "ENERGÍA", "ENFADO", "ENORME", "ENTRAR", "ENTRADA", "ENTRADAS", "ENTRANDO", "ENVIAR", "ERIZO", "ERIZOS", 
  "ENFERMERÍA", "PASILLO", "PASILLOS", "AUDITORIO", "AUDITORIOS", "CANCHA", "CANCHAS",
  "ENSALADA", "ENSALADAS", "SANDWICH", "SANDWICHES", "BURRITO", "BURRITOS", "PAELLA",
  "ERROR", "ERRORES", "ESCALA", "ESCALAN", "ESCALANDO", "ESCALERA", "ESCALERAS", "ESCALÓN", "ESCALONES", "ESCONDE", "ESTOS", "ESTAS", 
  "ESCONDEN", "ESCONDIDO", "ESCONDIDOS", "ESCONDITE", "ESCRIBE", "ESCRIBEN", "ESCRIBIR", "ESCRITO", "ESCRITORIO", "ESCRITORIOS", "ESTRELLAS",
  "ESCUCHAR", "ESFERA", "ESMERALDA", "ESMERALDAS", "ESPACIO", "ESPACIOS", "ESPIRAL", "ESTA", "ESTAS", "ESTAR", "ESTE", "ESTO",  
  "ESCUELA", "ESCUELAS", "COLEGIO", "COLEGIOS", "AULA", "AULAS", "CLASE", "CLASES",
  "ESTACIÓN", "ESTACIONES", "COMERCIO", "COMERCIOS", "RESTAURANTE", "RESTAURANTES",
  "ESTANTE", "ESTANTES", "CASILLERO", "CASILLEROS", "CORTINA", "CORTINAS", "VENTANA", "VENTANAS",
  "ESTUDIO", "ESTUDIOS", "ESTUFA", "ESTUFAS", "EXAMEN", "EXÁMENES", "FÁCIL", "FAMILIA", "FAMILIAS", "FELICES", "ESTRELLA", 
  "EXCURSIÓN", "EXCURSIONES", "VISITA", "VISITAS", "CONCURSO", "CONCURSOS", "FERIA", "FERIAS", "FACTURA", "FACTURAS",
  "FACTURACIÓN", "VENTA", "VENTAS", "COMPRA", "COMPRAS", "CLIENTE", "CLIENTES", "PROVEEDOR", "PROVEEDORES",
  "FALTA", "FALTAN", "FALTANDO", "TERMINA","TERMINAN", "TERMINÓ", "TERMINARON", "POCO", "POQUITO", "APAGA", "APAGAR", "APAGÓ", "APAGÓN", 
  "FELIZ", "FIESTA", "FIESTAS", "FLAMENCO", "FLAMENCOS", "FLOR", "FLORES", "FRASE", "FRASES", "FRÍO", "FRUTA", "FRUTAS", 
  "FESTIVAL", "FESTIVALES", "CEREMONIA", "CEREMONIAS", "ACTO", "ACTOS", "GRADUA", "GRADUÓ", "GRADUAN", "GRADUANDO", 
  "GRADUACIÓN", "GRADUACIONES",
  "FIEL", "FIELES", "PENSAR", "PIENSA", "PIENSO", "PIENSAN", "PENSAMOS", "ABRASO", "GUSTA", "LOCA", "LOCAS", "LOCO", "LOCOS", 
  "FILIAL", "FILIALES", "SEDE", "SEDES", "FRANQUICIA", "FRANQUICIAS",
  "FINANZAS", "BANCA", "SEGURO", "SEGUROS", "INMOBILIARIA", "LEGAL", "MARKETING", "PUBLICIDAD",
  "FLAN", "GELATINA", "BROWNIE", "BROWNIES", "MERMELADA", "MERMELADAS", "GOMITA", "GOMITAS", 
  "FORMULARIO", "FORMULARIOS", "MEMORANDO", "MEMORANDOS", "CARTA", "CARTAS", "DOCUMENTO", "DOCUMENTOS",
  "FROTAR", "FUEGO", "FUEGOS", "FUENTE", "FUENTES", "FUERA", "FUERTE", "FUGAZ", "GALAXIA", "GALAXIAS", "GALLO", "GALLOS", 
  "GANANCIA", "GANANCIAS", "PÉRDIDA", "PÉRDIDAS", "INVERSIÓN", "INVERSIONES", "ACCIÓN", "ACCIONES",
  "GARAJE", "GARAJES", "GATO", "GATOS", "GIRA", "GIRAN", "GIRANDO", "GIRAR", "GORILA", "GORILAS", "GORRA", "GORRAS", "GORRO", 
  "GIMNASIO", "GIMNASIOS", "CAFETERÍA", "CAFETERÍAS", "COMEDOR", "COMEDORES",
  "GORROS", "GRACIAS", "GRANDE", "GRANDES", "GRIS", "GUANTE", "GUANTES", "HABLAR", "HACER", "HACE", "HACEN", "HACEMOS", "HACIA", "HIELO", "HIJO", 
  "HOGAR", "HOGARES", "HOJA", "HOJAS", "HOLA", "HONGO", "HONGOS", "HORMIGA", "HORMIGAS", "HOY", "HUECO", "HUEVO", "HACIENDO",
  "HORA", "HORAS", "MINUTO", "MINUTOS", "SEGUNDO", "SEGUNDOS", "VACACIÓN", "VACACIONES",
  "HORARIO", "HORARIOS", "CALENDARIO", "CALENDARIOS", "SEMESTRE", "SEMESTRES", "TRIMESTRE", "TRIMESTRES",
  "HUELLA", "HUELLAS", "IDEA", "IDEAS", "IGLESIA", "IGLESIAS", "IGUAL", "ISLA", "ISLAS", "IRSE", "JABALÍ", "JABALÍES", 
  "INFORME", "INFORMES", "CONTRATO", "CONTRATOS", "FACTURA", "FACTURAS", "RECIBO", "RECIBOS",
  "INGRESO", "INGRESOS", "GASTO", "GASTOS", "COSTO", "COSTOS", "BENEFICIO", "BENEFICIOS",
  "INICIATIVA", "DECISIÓN", "ANÁLISIS", "PERSUASIÓN", "NEGOCIACIÓN", "RESOLUCIÓN", "PLANIFICACIÓN",
  "INVESTIGACIÓN", "INVESTIGACIONES", "LECTURA", "LECTURAS", "DICTADO", "DICTADOS", "RESUMEN", "RESÚMENES",
  "JADE", "RUBÍ", "CUIDA", "CUIDAR", "CUIDAN", "CUIDARTE", "NECESITA", "NECESITAN", "NECESITO", "MIL", 
  "JARDÍN", "JARDINES", "JUGAR", "JUGUETE", "JUGUETES", "LAGO", "LAGOS", "LÁMPARA", "LÁMPARAS", "LANZAR", "LECHE", 
  "JUBILACIÓN", "PENSIÓN", "PENSIONES", "CONTRATO", "CONTRATOS", "NÓMINA", "NÓMINAS",
  "JUEZ", "JUEZA", "JUECES", "JUEZAS", "CIENTÍFICO", "CIENTÍFICA", "CIENTÍFICOS", "CIENTÍFICAS",
  "JUNTO", "JUNTAS", "JUNTOS", "LIBRETO", "LIBRETA", "LIBRETAS", "LIBRE", "LIBRES", "MIRADA", "MIRADAS", "MIRA", "MIRAN", 
  "JUZGADO", "JUZGADOS", "TRIBUNAL", "TRIBUNALES", "AEROPUERTO", "AEROPUERTOS", "PUERTO", "PUERTOS",
  "KILÓMETRO", "QUIERO", "QUIERE", "QUIERES", "QUIEREN", "MURO", "PILA", "BATERIA", "BATERIAS", 
  "LABORATORIO", "LABORATORIOS", "HOSPITAL", "HOSPITALES", "CLÍNICA", "CLÍNICAS", "BANCO", "BANCOS",
  "LECHE", "QUESO", "QUESOS", "YOGUR", "YOGURES", "CREMA", "MANTEQUILLA", "HELADO", "HELADOS",
  "LEER", "LEJANA", "LEJANAS", "LEJANO", "LEJANOS", "LEJOS", "LENTEJA", "LENTEJAS", "LENTO", "LIBRO", "LIBROS", 
  "LIBRO", "LIBROS", "CUADERNO", "CUADERNOS", "LIBRETA", "LIBRETAS", "LÁPIZ", "LÁPICES",
  "LICENCIA", "LICENCIAS", "CERTIFICADO", "CERTIFICADOS", "TÍTULO", "TÍTULOS", "DIPLOMA", "DIPLOMAS",
  "LIDERAZGO", "COMUNICACIÓN", "ORGANIZACIÓN", "CREATIVIDAD", "INNOVACIÓN", "EFICIENCIA",
  "LIMÓN", "LIMONES", "PIÑA", "PIÑAS", "MANGO", "MANGOS", "CIRUELA", "CIRUELAS", 
  "LIMPIEZA", "LIMPIO", "LLAVE", "LLAVES", "LOBO", "LOBOS", "LUCES", "LUGAR", "MAGIA", "MAMÁ", "MASA", "MASAS", 
  "LLAMAR", "LLAMAN", "CELULAR", "CELULARES", "TELÉFONO", "TELÉFONOS", "PORTÁTIL", "PORTÁTILES", "VIDEO", "VIDEOS", "VIDEOJUEGO", 
  "MAESTRO", "MAESTRA", "MAESTROS", "MAESTRAS", "PROFESOR", "PROFESORA", "PROFESORES", "PROFESORAS",
  "MANDARINA", "MANDARINAS", "HIGO", "HIGOS", "MORA", "MORAS", "GOLF",
  "MANZANA", "MANZANAS", "PERA", "PERAS", "PLÁTANO", "PLÁTANOS", "NARANJA", "NARANJAS",
  "MATEMÁTICA", "MATEMÁTICAS", "ESPAÑOL", "CIENCIA", "CIENCIAS", "HISTORIA", "GEOGRAFÍA", "FÍSICA",
  "MÉDICO", "MÉDICA", "MÉDICOS", "MÉDICAS", "INGENIERO", "INGENIERA", "INGENIEROS", "INGENIERAS",
  "MESEDORA", "MESA", "MESAS", "MIEL", "MIL", "MOMENTO", "MONTAÑA", "MONTAÑAS", "MUCHO", "MUCHOS", "MUEBLE", "MUEBLES", 
  "MIRAS", "VIDRIO", "VIDRIOS", "CABLE", "CABLES", "PASO", "PASOS", "PISA", "PISADA", "PISADAS", "PISAN", "NUESTRA", 
  "MOSTAZA", "MIEL", "CANELA", "VAINILLA", "ORÉGANO", "CHILE", "CHILES", "CEBOLLÍN",
  "NADA", "NARANJA", "NEGRO", "NINGUN", "NOCHE", "NOVENO", "NUEVE", "NUNCA", "OCHO", "ONCE", "OSCURO", "OTROS", 
  "NAVEGAN", "NAVEGANTE", "NAVEGANTES", "VELERO", "VELEROS", "VELA", "HUMANO", "HUMANOS", "HUNAMIDAD", 
  "NEGOCIACIÓN", "NEGOCIACIONES", "TRÁMITE", "TRÁMITES", "PLANIFICACIÓN", "IMPLEMENTACIÓN",
  "NOTA", "NOTAS", "CALIFICACIÓN", "CALIFICACIONES", "PUNTAJE", "PUNTAJES", "REPORTE", "REPORTES",
  "NUESTRAS", "NUESTRO", "NUESTROS", "LENTE", "LENTES", "VIVE", "VIVO", "VIVEN", "VIVIMOS", "PIEL", "CONMIGO", "CONTIGO", 
  "OFICINA", "OFICINAS", "FÁBRICA", "FÁBRICAS", "ALMACÉN", "ALMACENES", "TALLER", "TALLERES",
  "OLIMPIADA", "OLIMPIADAS", "TORNEO", "TORNEOS", "CAMPEONATO", "CAMPEONATOS", "ASAMBLEA", "ASAMBLEAS"
  "ORGANIZACIÓN", "ORGANIZACIONES", "INSTITUCIÓN", "INSTITUCIONES", "AGENCIA", "AGENCIAS",
  "ORTOGRAFÍA", "ÁLGEBRA", "GEOMETRÍA", "CÁLCULO", "ESTADÍSTICA",
  "PALABRA", "PALABRAS", "PALO", "PALOS", "PANTALLA", "PANTALLAS", "PANTALÓN", "PANTALONES", "PAPA", "PAPÁ", "PAPEL", 
  "PALETA", "PALETAS"
  "PAN", "PANES", "HARINA", "GALLETA", "GALLETAS", "BIZCOCHO", "BIZCOCHOS", 
  "PANSA", "CADERA", "ESTÓMAGO", "ESPALDA", "TRASERO", "UÑA", "UÑAS", "CODO", "CODOS", "RODILLA", "RODILLAS", "FRENTE", 
  "PANTALLA", "PANTALLAS", "PARLANTE", "PARLANTES", "MICRÓFONO", "MICRÓFONOS", "BANDERA", "BANDERAS",
  "PAPELES", "PARA", "PARED", "PAREDES", "PASILLO", "PATIO", "PATOS", "PERDER", "PERRO", "PERSONA", "PERSONAS", 
  "PASADO", "PASA", "PASAN", "PASAMOS", "PASARON", "RETRO", "YENDO", "VAMOS", "FRASCO", "PLAN", "MUY", "MAL", "MALO", "MALOS", "MALA", "MALAS", 
  "PASTA", "PASTAS", "ESPAGUETI", "ESPAGUETIS", "CEREAL", "CEREALES", "GRANOLA",
  "PASTEL", "PASTELES", "BOLLO", "BOLLOS", "PANQUÉ", "PANQUÉS", "SEIS", "SIETE", "OCHO", "NUEVE",
  "PEINANDO", "PEINANDOSE", "BOTELLA", "SABE", "SABEN", "SABES", "SUPER", "SUPE", "RAYO", "RAYOS", "TRUENO", "TRUENOS", 
  "PEQUEÑO", "PIE", "PIES", "PINCEL", "PINCELES", "PINTAR", "PINTURA", "PLANETA", "PLANETAS", "PLATO", "PLATOS", 
  "PERICO", "PERICOS", "BOMBILLO", "BOMBILLOS", "CONEJITO", "METRO", "METROS", 
  "PERIODISTA", "PERIODISTAS", "PROGRAMADOR", "PROGRAMADORA", "PROGRAMADORES", "PROGRAMADORAS",
  "PIERNAS", "CABEZA", "OJO", "OJOS", "NARÍZ", "BOCA", "OREJA", "OREJAS", "PELA", "PELAN", "PELANDO", "PELO", "PELÓN", 
  "PILOTO", "PILOTOS", "BOMBERO", "BOMBERA", "BOMBEROS", "BOMBERAS", "POLICÍA", "POLICÍAS",
  "PIMIENTA", "ACEITE", "VINAGRE", "SALSA", "SALSAS", "MAYONESA",
  "PINTURA", "PINTURAS", "GOMA", "GOMAS", "CARTULINA", "CARTULINAS", "PAPEL", "PAPELES",
  "PLUMA", "PLUMAS", "BOLÍGRAFO", "BOLÍGRAFOS", "BORRADOR", "BORRADORES", "SACAPUNTAS", "TIJERA", "TIJERAS",
  "POEMA", "POEMAS", "PORQUE", "PRIMER", "PROFESOR", "PROFESORA", "PROFESORES", "PROFESORAS", "PUERTA", "PUERTAS", 
  "POLLO", "CARNE", "CERDO", "PESCADO", "ATÚN", "SALMÓN", "PAVO", "TERNERA",
  "PRESENTACIÓN", "PRESENTACIONES", "RECREO", "RECREOS", "JUEGO", "JUEGOS", "REUNIÓN", "REUNIONES",
  "PRESUPUESTO", "PRESUPUESTOS", "CURRÍCULUM", "CURRÍCULUMS", "SOLICITUD", "SOLICITUDES",
  "PROBLEMA", "PROBLEMAS", "EJERCICIO", "EJERCICIOS", "DEBATE", "DEBATES", "EXPOSICIÓN", "EXPOSICIONES",
  "PRODUCTIVIDAD", "PUNTUALIDAD", "RESPONSABILIDAD", "COMPROMISO", "ADAPTACIÓN", "FLEXIBILIDAD",
  "PUERTA", "PUERTAS", "RELOJ", "RELOJES", "COMPUTADORA", "COMPUTADORAS", "PROYECTOR", "PROYECTORES",
  "PUPITRE", "PUPITRES", "QUINTO", "RADIO", "RANA", "RANAS", "RAPIDO", "RARO", "RAYA", "RAYAS", "REAL", "RECIBIR", 
  "PUPITRE", "PUPITRES", "SILLA", "SILLAS", "MESA", "MESAS", "ESCRITORIO", "ESCRITORios",
  "QUÍMICA", "BIOLOGÍA", "ARTE", "ARTES", "MÚSICA", "INGLÉS", "FRANCÉS", "COMPUTACIÓN", "INFORMÁTICA",
  "REDONDO", "REFRI", "REMOLINO", "RENGLÓN", "RENGLONES", "REVISTA", "REVISTAS", "RÍO", "RISA", "RISAS", "ROJO", "SALIMOS",
  "REGLA", "REGLAS", "CALCULADORA", "CALCULADORAS", "MOCHILA", "MOCHILAS", "ESTUCHE", "ESTUCHES",
  "RELAMPAGO", "RELAMPAGOS", "MANDO", "MANDOS", "CAMARA", "CAMARAS", "LLAVERO", "LLAVEROS", "COLLAR", "COLLARES", 
  "RENUNCIA", "RENUNCIAS", "DESPIDO", "DESPIDOS", "CESANTÍA", "CESANTÍAS", "CUATRO", "CINCO",
  "REUNIÓN", "REUNIONES", "ENTREVISTA", "ENTREVISTAS", "CONFERENCIA", "CONFERENCIAS",
  "ROSADO", "SABER", "SALA", "SALIR", "SALUDO", "SALUDOS", "SANDALIA", "SANDALIAS", "SANTA", "REÍR", "RÍE", "RÍEN", 
  "RUEDA", "RUEDAS", "BRILLANTE", "BRILLANTES", "BRILLAR", "BRILLO", "BRILLITOS", "CANDELA", "CANDELAS", 
  "SALÓN", "SALONES", "OFICINA", "OFICINAS", "DIRECCIÓN", "SECRETARÍA", "BAÑO", "BAÑOS",
  "SANTO", "SASTRE", "SASTRES", "SEGUNDO", "SEIS", "SEMILLA", "SEMILLAS", "SEPTIMO", "SÍLABA", "SÍLABAS", "SALERO",
  "SILLA", "SILLAS", "SIMPÁTICO", "SITIO", "SOPLO", "SOPLAR", "SORDO", "SORPRENDER", "SUAVE", "SUBIR", "SUCIO", "SALE", "SALEN",
  "SOLEDAD", "SOLITA", "SOLITARIO", "SUELE", "SUELEN", "ÁNGEL", "ÁNGELES", "ANGELICAL", "ACOMPAÑA", "COMPAÑIA", "COMPAÑERO", "COMPAÑERA", 
  "SOMBRILLA", "VENTILADOR", "CARGADOR", "CARGADORES", "CARGADO", "CARGANDO", "CARGA", "NAVE", "NAVES", "NAVEGA", 
  "SOPA", "SOPAS", "PIZZA", "PIZZAS", "HAMBURGUESA", "HAMBURGUESAS", "TACO", "TACOS",
  "SUELDO", "SUELDOS", "SALARIO", "SALARIOS", "VACACIONES", "PERMISO", "PERMISOS", "BAJA", "BAJAS",
  "SUELO", "SUEÑO", "SUEÑOS", "SUFICIENTE", "SUEGRA", "SUEGROS", "SUMAR", "SUSURRO", "TABLA", "TABLAS", "SONRÍE", "SONRÍEN",
  "SUPERVISOR", "SUPERVISORA", "SUPERVISORES", "SUPERVISORAS", "COORDINADOR", "COORDINADORA", "COORDINADORES", "COORDINADORAS",
  "TABLETA", "TAREA", "TAREAS", "TECHO", "TECLA", "TECLAS", "TELE", "TELEVISOR", "TELEVISORES", "TERCER", "TEXTO", 
  "TAREA", "TAREAS", "EXAMEN", "EXÁMENES", "PRUEBA", "PRUEBAS", "PROYECTO", "PROYECTOS",
  "TAREA", "TAREAS", "INVESTIGACIÓN", "INVESTIGACIONES", "ANÁLISIS", "ESTRATEGIA", "ESTRATEGIAS",
  "TÉ", "VINO", "VINOS", "CERVEZA", "CERVEZAS", "BATIDO", "BATIDOS",
  "TEXTOS", "TIENDA", "TIENDAS", "TIERRA", "TIJERA", "TIJERAS", "TIPO", "TIPOS", "TODOS", "TORNILLO", "TORNILLOS", 
  "TOMATE", "TOMATES", "LECHUGA", "LECHUGAS", "ZANAHORIA", "ZANAHORIAS", "CEBOLLA", "CEBOLLAS",
  "TORTA", "TORTAS", "TRABAJO", "TRABAJOS", "TRATAR", "TRAVES", "TRAVESÍA", "TREN", "TRENES", "TRIÁNGULO", "TRIÁNGULOS", 
  "TORTILLA", "TORTILLAS", "EMPANADA", "EMPANADAS", "CALDO", "CALDOS", "GUISO", "GUISOS",
  "TRABAJO", "TRABAJOS", "EMPLEO", "EMPLEOS", "PUESTO", "PUESTOS", "CARGO", "CARGOS",
  "TROMPO", "TROMPOS", "TUBO", "TUBOS", "UNO", "VASO", "VASOS", "VECES", "VEGETAL", "VEGETALES", "VERANO", 
  "UVA", "UVAS", "SANDÍA", "SANDÍAS", "MELÓN", "MELONES", "FRESA", "FRESAS",
  "VENTANA", "VENTANAS", "VESTIDO", "VESTIDOS", "PLATA", "PLANTAS", "CEPILLO", "CEPILLOS", "CONEJO", "CONEJOS",
  "VERANOS", "VERBO", "VERBOS", "VERDE", "VERDES", "VIENTO", "VIENTOS", "VIEJO", "VIEJA", "VIEJOS", "VIEJAS", 
  "VETERINARIO", "VETERINARIA", "VETERINARIOS", "VETERINARIAS", "PSICÓLOGO", "PSICÓLOGA", "PSICÓLOGOS", "PSICÓLOGAS",
  "VICEPRESIDENTE", "VICEPRESIDENTA", "VICEPRESIDENTES", "VICEPRESIDENTAS",
  "VIDEOJUEGOS", "CEJA", "CEJAS", "PESTAÑA", "PESTAÑAS", "LABIO", "LABIOS", "HOMBRO", "HOMBROS", "PECHO", "PANZA", 
  "VOLVER", "ZAPATO", "ZAPATOS", "MUÑECA", "MUÑECAS", "MUÑECO", "MUÑECOS", "MALL", "ENTONCES", ];

const List<String> silabasEspeciales = [
  "A", "AL", "CON", "DA", "DAN", "DAR", "DE", "EL", "EN", "ES", "FÉ", "HA", "HE", "LA",
  "LE", "LO", "LAS", "LOS", "LUZ", "ME", "MI", "MÁS", "MAR", "MES", "MIS", "NI", "SOL",
  "NO", "QUE", "QUI", "SE", "SER", "SI", "SU", "SIN", "SON", "SOS", "SUR", "TE", "TU", 
  "UN", "VA", "VAN" "VE", "VEN", "VER", "VI", "WEB", "WI", "Y", "YA", "YO", "TAL", "DOS", 
];

const List<String> IniciosDePalabras = [
  // Combina los valores de iniciosDePalabras3Silabas e iniciosDePalabras4Silabas


   "ABA", "ABANI", "ABRA", "ABRI", "ABRIR", "AGRE", "AGU",  
   "ABO", "ABOGA", "CONTA", "CONTADO", "CONTADORE",
   "ACO", "ACOS", "ACOSTA", "DORMI", "DURMI", "DURMIEN", 
   "AGRI", "AGRICU", "AGRICUL", "AGRICULTO", "CAR", "CARPI", "CARPIN", "CARPINTE", 
   "AGU", "REFRE", "REFRES", 
   "ÁGUI", "ALMO", "ALMOHA", "AMARI",  
   "BRÓCO", "ESPI", "PEPI",
   "ALTAVO", "ALTAVOCE", "ESTI", "PIER", 
   "ALU", "ALUM", "SECRE", "SECRETARI", "CONSE", "CONSER", "BIBLI", "BIBLIO", "BIBLIOTE", "BIBLIOTECARI",
   "AMI", "ANI", 
   "PERÍ", "PERÍO", "SEMA", 
   "ARBU", "ARBUS", "ARDI", "ARE", "ARCOÍ", "ARCOÍRI", "ARMA", "ARMARI", "ARRI", 
   "ARQUI", "ARQUITE", "ARQUITEC", "ENFE", "ENFER", "ENFERME", 
   "ARRO", "FRIJO", 
   "ASIEN", "AZU", "AZULE", "AZÚ", "BALLE", 
   "ASI", "ASI", "ASIS", "PRESI", "PRESIDE", "PRESIDEN", 
   "BALLE", "BICICLE", 
   "BERE", "BEREN", "BERENJE", "REPO", "COLI", "COLIFLO", "ESPÁ", "ESPÁRRA",
   "BIBLI", "BIBLIO", "BIBLIOTE", "LABO", "LABORA", "LABORATO", "LABORATORI", "PATI", 
   "BONI", "BOTO", 
   "BOLE", "BOLETÍ", "EVA", "EVALU", "EVALUACI", "EVALUACIO", "PROME", "PROMEDI", "APRO", "APROBA", "REPRO", "REPROBA", 
   "PRÉSTA", "IMPU", "IMPUES", "BALA", "BALAN",
   "BOSTE",
   "BUFA", "BUFAN", "CABA", "CALE", "CALEN", "CALENDA", "CALENDARI", 
   "CABE", "HERMO", 
   "CALA", "CALABA", "RÁBA", "PIMI", "PIMIEN", 
   "CALI", "CALIEN", "CAMI", 
   "CAMIO", "CAMIONE", "CANDA", "BANQUE", "BANQUI",
   "CAPACI", "PRESE", "PRESEN", "PRESENTACI", "PRESENTACIO", "PRESENTACIONE", "GESTI", "GESTIONE",
   "CARACO", "CARACOLE", "CARRE", "CARTONE", 
   "CARPE", "DICCI", "DICCIO", "DICCIONA", "DICCIONARI", "ATLA", 
   "CARRE", "PROFE", "PROFESO", "OFI", "OFICI", "OCU", "OCUPA", "OCUPACI", "OCUPACIO", "OCUPACIONE", 
   "CELE", "CELES", 
   "CERE", "DURAZ", "COCI",
   "COLCHO", "COLO", "COMI", "COMERCI", "INDU", "INDUS", "INDUSTRI", "EDU", "EDUCACI", "EDUCACIÓ", "TECNO", 
   "TECNOLO", "TECNOLOGÍ", "CONS", "CONSTRU", "CONSTRUC", "CONSTRUCCI", "TRANSPO", "TRANSPOR", 
   "PEGA", "PEGAME", "PEGAMEN", "CRAYO", "CRAYONE", "MARCA", "MARCADORE", "PIZA", "PIZARRÓ",
   "CONTRO", "CONTROLE", "CORBA", "CORDI", "CORDILLE", 
   "COMPU", "COMPUTA", "COMPUTADO", "IMPRE", "IMPRESO", "TELÉ", "TELÉFO", "MÁQUI", 
   "COMU", "COMUNI", "COMUNICA", "COMUNICACI", "AGRI", "AGRICU", "AGRICUL", "AGRICULTU", "GANADE", "GANADERI", 
   "MINE", "MINERI", "ENE", "ENER", "ENERGI", "TURI", "TURIS",
   "CONDU", "CONDUC", "CONDUCTO", "COCI", "COCINE", "DOCTO", 
   "CONGRE", "INFO", "INFOR", "REPO", "REPOR", "PROYE", "PROYEC",
   "CONSO", "SACA", "RETROVI", "RETROVISO", "RETROVISORE", 
   "SEGU", "SEGURI", "SEGURIDA", "TAMBIÉN",
   "MOTI", "MOTIVA", "MOTIVACI", "DISCI", "DISCIPLI",
   "CORDE", "SALCHI", "TOCI", "FILE", 
   "CORTI", "CUA", "CUADRA", "CUCHA", "CUCHI", 
   "DELFI", "DELFINE", 
   "CUE", "DIEN", "TOBI", "TALO", "TALONE", "CALSE", "CALSETÍ", 
   "DENTI", "DENTIS", "ELE", "ELEC", "ELECTRI", "ELECTRICI", "ELECTRICIS", "MECÁ", "MECÁNI", 
   "DESA", "DESAYU", "DESI", "DESIER", "DESTE", "DIBU", 
   "DEPA", "DEPAR", "DEPARTA", "DEPARTAME", "DEPARTAMEN", "DEPARTAMEN", "DIVI", "DIVISI", "SUCU", "SUCUR", 
   "SUCURSA", "TIEN", "ESTU", "ESTUDI",
   "DESTA", "EXCE", "EXCELE", "EXCELEN", "REGU", "SUFI", "SUFICI", "SUFICIEN",
   "FOTOGRA", "FOTOGRAFÍ", "TENE", "TENEMO", "RECU", "RECUER", 
   "DIBU", "DIFÍ", "DIFICU", "DIFICUL", "DORMI", "DORMITO", "DORMITORI", 
   "DIRE", "DIREC", "DIRECTO", "ESTU", "ESTUDI", "ESTUDIAN", "ALU", "ALUM",
   "GERE", "GEREN", 
   "DISE", "AGRI", "AGRICU", "AGRUCUL", 
   "CHOCO", "CHOCOLA", "CARA", "CARAME", 
   "ECLI", "ECLIP", "ELE", "ELEFA", "ELEFAN", "EMPU", "ENCI", "ENCO", "ENCON", "ENCONTRA", "ENCU", "ENCUEN", 
   "EDU", "EDUCA", "EDUCACI", "DEPO", "DEPOR", "TEC", "TECNO", "TECNOLO", "TECNOLOGÍ", "LITE", "LITERA", "LITERATU", 
   "ESCRI", "ESCRITU", "GRAMÁ", "GRAMÁTI", 
   "EJE", "EJECU", "EJECUTI", "EM", "EMPRE", "COM", "COMPA", "COMPAÑÍ", "NEGO", "NEGOCI", "COR", "CORPO", 
   "ENCE", "ENCEN", "ENCENDI", "ENTENDER", "ENTEN", "ENTENDE", "ENTI", "ENTIEN", "CORA", "CORAZÓ", 
   "ENCU", "ENCUEN", "ENE", "ENER", "ENERGÍ", "ENFA", "ENO", "ENOR", "ERI", 
   "ENFE", "ENFER", "ENFERME", "ENFERMERÍ", "PASI", "AU", "AUDI", "AUDITO", "AUDITORI", 
   "ENSA", "ENSALA", "BURRI", "PAE", "ERRO", "ERRORE", "ESCA", "ESCALE", "ESCO", "ESCON", "ESCRI", "ESCRITORI", "ESTRE",
   "ESCU", "ESFE", "ESME", "ESMERA", "ESMERAL", "ESPA", "ESPACI", "ESPI", "ESPIRA", 
   "ESCUE", "COLE", "COLEGI", 
   "ESTACI", "COME", "COMER", "COMERCI", "RES", "RESTA", "RESTAU", "RESTAURA", "RESTAURAN",
   "ESTAN", "CASI", "CASILLE", "CORTI", "VENTA", 
   "ESTU", "ESTUDI", "ESTU", "EXA", "EXAME", "EXÁ", "EXÁME", "EXÁMENE", "FAMI", "FAMILI", "FELI", "ESTRE", 
   
 

];

const Map<String, List<String>> silabasPorLetra = {
  "A": ["Á", "A", "AL", "AN", "AR", "AS", "AM"],
  "B": ["B", "BA", "BE", "BI", "BO", "BU", "BAN", "BEN", "BIN", "BON", "BUN", "BLA", "BLE", "BLI", "BLO", "BLU", "BRA", "BRE", "BRI", "BRO", "BRU", "BRAN", "BREN", "BRIN", "BRON", "BRUN"],
  "C": ["CA", "CE", "CI", "CO", "CU", "CAS", "CES", "CIS", "COS", "CUS", "CAN", "CEN", "CIN", "CON", "CUN", "CAl", "CEl", "CIl", "COl", "CUl", "CLA", "CLE", "CLI", "CLIP", "CLO", "CLU",
        "CRA", "CRE", "CRI", "CRO", "CRU", "CIAS", "CAR", "CER", "CIR", "COR", "CUR", "CHA", "CHE", "CHI", "CHO", "CHU",],
  "D": ["D", "DA", "DE", "DI", "DO", "DU", "DAN", "DEN", "DIN", "DON", "DUN", "DAR", "DER", "DIR", "DOR", "DUR",],
  "E": ["É", "E", "EL", "EM", "EN", "ES", "ER"],
  "F": ["F", "FA", "FE", "FI", "FIES", "FO", "FU", "FAL", "FEL", "FIL", "FOL", "FUL", "FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU"],
  "G": ["G", "GA", "GE", "GI", "GO", "GU", "GUA", "GEN", "GUA", "GUE", "GUI", "GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU"],
  "H": ["H", "HA", "HE", "HI", "HIS", "HO", "HOR", "HU"],
  "I": ["Í", "I", "IS", "IN", "IR", "IM"],
  "J": ["J", "JA", "JE", "JI", "JO", "JU", "JAS", "JES", "JIS", "JOS", "JUS"],
  "K": ["K", "KA", "KE", "KI", "KO", "KU"],
  "L": ["L", "LA", "LE", "LI", "LO", "LO", "LU", "LAS", "LOS", "LUZ", "LLA", "LLE", "LLI", "LLO", "LLU"],
  "M": ["M", "MA", "ME", "MI", "MO", "MU", "MAS", "MES", "MIS", "MOS"],
  "N": ["N", "NA", "NE", "NI", "NO", "NU"],
  "Ñ": ["Ñ", "ÑA", "ÑE", "ÑI", "ÑO", "ÑU"],
  "O": ["Ó", "O", "OS", "ON"],
  "P": ["P", "PA", "PE", "PI", "PO", "PU", "PAL", "PEL", "PIL", "POL", "PUL", "PLA", "PLE", "PLI", "PLO", "PLU",
        "PRA", "PRE", "PRI", "PRO", "PRU"],
  "Q": ["Q", "QUE", "QUI"],
  "R": ["R", "RA", "RAL", "RE", "RI", "RO", "RU"],
  "S": ["S", "SA", "SE", "SI", "SO", "SU", "SAN", "SEN", "SIN", "SON", "SUN", "SAM", "SEM", "SIM", "SO", "SUM"],
  "T": ["T", "TA", "TE", "TI", "TO", "TU", "TAS", "TES", "TIS", "TOS", "TUS", "TRA", "TRE", "TRI", "TRO", "TRU"],
  "U": ["Ú", "U", "UL", "UN", "UR", "US"],
  "V": ["V", "VA", "VE", "VI", "VO", "VU", "VAN", "VEN", "VIN", "VON", "VUN", "VAR", "VER", "VES", "VIR", "VOR", "VUR",
        "VAL", "VEL", "VEL", "VOL", "VUL",],
  "W": ["W", "WEB", "WI"],
  "X": ["X", "XA", "XE", "XI"],
  "Y": ["Y", "YA", "YO"],
  "Z": ["Z", "ZA", "ZE", "ZI", "ZO", "ZU"],
};

const Map<String, Map<String, List<String>>> silabasClasificadas = {
  "A": {
    "comunes": ["A", "AL", "AN", "AR", "AS", "AM"],
    "trabadas": [],
    "mixtas": [],
  },
  "B": {
    "comunes": ["BA", "BE", "BI", "BO", "BU", "BLA", "BLE", "BLI", "BLO", "BLU", "BRA", "BRE", "BRI", "BRO", "BRU", "BAI",],
    "trabadas": [
                 "BLAS", "BLES", "BLIS", "BLOS", "BLUS", "BRAS", "BRES", "BRIS", "BROS", "BRUS",
                 "BLAN", "BLEN", "BLIN", "BLON", "BLUN", "BRAN", "BREN", "BRIN", "BRON", "BRUN"],
    "mixtas": ["BAL", "BEL", "BIL", "BOL", "BUL", "BAM", "BEM", "BIM", "BOM", "BUM", 
               "BAN", "BEN", "BIN", "BON", "BUN", "BAR", "BER", "BIR", "BOR", "BUR", 
               "BAS", "BES", "BIS", "BOS", "BUS"],
  },
  "C": {
    "comunes": ["CA", "CE", "CI", "CO", "CU", "CLA", "CLE", "CLI", "CLO", "CLU", "CHA", "CHE", "CHI", "CHO", "CHU",
                "CRA", "CRE", "CRI", "CRO", "CRU"],
    "trabadas": ["CLAS", "CLES", "CLIS", "CLOS", "CLUS", "CRAS", "CRES", "CRIS", "CROS", "CRUS",
                "CLAN", "CLEN", "CLIN", "CLON", "CLUN", "CRAN", "CREN", "CRIN", "CRON", "CRUN"],
    "mixtas": ["CAL", "CEL", "CIL", "COL", "CUL", "CAM", "CEM", "CIM", "COM", "CUM", 
               "CAN", "CEN", "CIN", "CON", "CUN", "CAR", "CER", "CIR", "COR", "CUR", 
               "CAS", "CES", "CIS", "COS", "CUS"],
  },
  "D": {
    "comunes": ["DA", "DE", "DI", "DO", "DU", "DRA", "DRE", "DRI", "DRO", "DRU", "DAC", "DEC", "DIC", "DOC", "DUC",],
    "trabadas": ["DLA", "DLE", "DLI", "DLO", "DLU",  
                 "DLAS", "DLES", "DLIS", "DLOS", "DLUS", "DRAS", "DRES", "DRIS", "DROS", "DRUS",
                 "DLAN", "DLEN", "DLIN", "DLON", "DLUN", "DRAN", "DREN", "DRIN", "DRON", "DRUN"],
    "mixtas": ["DAL", "DEL", "DIL", "DOL", "DUL", "DAM", "DEM", "DIM", "DOM", "DUM", 
               "DAN", "DEN", "DIN", "DON", "DUN", "DAR", "DER", "DIR", "DOR", "DUR", 
               "DAS", "DES", "DIS", "DOS", "DUS"],
  },
  "E": {
    "comunes": ["E", "EL", "EM", "EN", "ES", "ER"],
    "trabadas": [],
    "mixtas": [],
  },
  "F": {
    "comunes": ["FA", "FE", "FI", "FO", "FU", "FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU",],
    "trabadas": ["FLAS", "FLES", "FLIS", "FLOS", "FLUS", "FRAS", "FRES", "FRIS", "FROS", "FRUS",
                 "FLAN", "FLEN", "FLIN", "FLON", "FLUN", "FRAN", "FREN", "FRIN", "FRON", "FRUN"],
    "mixtas": ["FAL", "FEL", "FIL", "FOL", "FUL", "FAM", "FEM", "FIM", "FOM", "FUM", 
               "FAN", "FEN", "FIN", "FON", "FUN", "FAR", "FER", "FIR", "FOR", "FUR", 
               "FAS", "FES", "FIS", "FOS", "FUS"],
  },
  "G": {
    "comunes": ["GA", "GE", "GI", "GO", "GU", "GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU",],
    "trabadas": ["GLAS", "GLES", "GLIS", "GLOS", "GLUS", "GRAS", "GRES", "GRIS", "GROS", "GRUS",
                 "GLAN", "GLEN", "GLIN", "GLON", "GLUN", "GRAN", "GREN", "GRIN", "GRON", "GRUN"],
    "mixtas": ["GAL", "GEL", "GIL", "GOL", "GUL", "GAM", "GEM", "GIM", "GOM", "GUM", 
               "GAN", "GEN", "GIN", "GON", "GUN", "GAR", "GER", "GIR", "GOR", "GUR", 
               "GAS", "GES", "GIS", "GOS", "GUS"],
  }, 
  "H": {
    "comunes": ["HA", "HE", "HI", "HO", "HU"],
    "trabadas": [],
    "mixtas": ["HAL", "HEL", "HIL", "HOL", "HUL", "HAM", "HAM", "HIM", "HOM", "HUM", 
               "HAN", "HEN", "HIN", "HON", "HUN", "HAR", "HER", "HIR", "HOR", "HUR", 
               "HAS", "HES", "HIS", "HOS", "HUS"],
  },
  "I": {
    "comunes": ["I", "IS", "IN", "IR", "IM"],
    "trabadas": [],
    "mixtas": [],
  },
  "J": {
    "comunes": ["JA", "JE", "JI", "JO", "JU"],
    "trabadas": [],
    "mixtas": [],
  },
  "K": {
    "comunes": ["KA", "KE", "KI", "KO", "KU"],
    "trabadas": [],
    "mixtas": [],
  },
  "L": {
    "comunes": ["LA", "LE", "LI", "LO", "LU", "LAS", "LES", "LIS", "LOS", "LUS", "LUZ",],
    "trabadas": ["LLA", "LLE", "LLI", "LLO", "LLU"],
    "mixtas": ["LAM", "LEM", "LIM", "LOM", "LUM", 
               "LAN", "LEN", "LIN", "LON", "LUN", "LAR", "LER", "LIR", "LOR", "LUR",   
               "LLAN", "LLEN", "LLIN", "LLON", "LLUN", "LLAS", "LLES", "LLIS", "LLOS", "LLUS",],
  },
  "M": {
    "comunes": ["MA", "ME", "MI", "MO", "MU", "MUY",],
    "trabadas": [],
    "mixtas": ["MAL", "MEL", "MIL", "MOL", "MUL", "MAM", "MEM", "MIM", "MOM", "MUM", 
               "MAN", "MEN", "MIN", "MON", "MUN", "MAR", "MER", "MIR", "MOR", "MUR", 
               "MAS", "MES", "MIS", "MOS", "MUS"],
  },
  "N": {
    "comunes": ["NA", "NE", "NI", "NO", "NU"],
    "trabadas": [],
    "mixtas": ["NAL", "NEL", "NIL", "NOL", "NUL", "NAM", "NEM", "NIM", "NOM", "NUM", 
               "NAN", "NEN", "NIN", "NON", "NUN", "NAR", "NER", "NIR", "NOR", "NUR", 
               "NAS", "NES", "NIS", "NOS", "NUS"],
  },
  "Ñ": {
    "comunes": ["ÑA", "ÑE", "ÑI", "ÑO", "ÑU"],
    "trabadas": [],
    "mixtas": ["ÑAL", "ÑEL", "ÑIL", "ÑOL", "ÑUL", "ÑAM", "ÑEM", "ÑIM", "ÑOM", "ÑUM", 
               "ÑAN", "ÑEN", "ÑIN", "ÑON", "ÑUN", "ÑAR", "ÑER", "ÑIR", "ÑOR", "ÑUR", 
               "ÑAS", "ÑES", "ÑIS", "ÑOS", "ÑUS"],
  },
  "O": {
    "comunes": ["O", "OS", "ON"],
    "trabadas": [],
    "mixtas": [],
  },
  "P": {
    "comunes": ["PA", "PE", "PI", "PO", "PU", "PLA", "PLE", "PLI", "PLO", "PLU", "PRA", "PRE", "PRI", "PRO", "PRU",],
    "trabadas": ["PLAS", "PLES", "PLIS", "PLOS", "PLUS", "PRAS", "PRES", "PRIS", "PROS", "PRUS",
                 "PLAN", "PLEN", "PLIN", "PLON", "PLUN", "PRAN", "PREN", "PRIN", "PRON", "PRUN"],
    "mixtas": ["PAL", "PEL", "PIL", "POL", "PUL", "PAM", "PEM", "PIM", "POM", "PUM", 
               "PAN", "PEN", "PIN", "PON", "PUN", "PAR", "PER", "PIR", "POR", "PUR", 
               "PAS", "PES", "PIS", "POS", "PUS"],
  },
  "Q": {
    "comunes": ["QUE", "QUI"],
    "trabadas": [],
    "mixtas": [],
  },
  "R": {
    "comunes": ["RA", "RE", "RI", "RO", "RU"],
    "trabadas": ["RRA", "RRE", "RRI", "RRO", "RRU", "RRAS", "RRES", "RRIS", "RROS", "RRUS",
                 "RREI",],
    "mixtas": ["RAL", "REL", "RIL", "ROL", "RUL", "RAM", "REM", "RIM", "ROM", "RUM", 
               "RAN", "REN", "RIN", "RON", "RUN", "RAR", "RER", "RIR", "ROR", "RUR", 
               "RAS", "RES", "RIS", "ROS", "RUS"],
  },
  "S": {
    "comunes": ["SA", "SE", "SI", "SO", "SU", "SOY",],
    "trabadas": ["SLA", "SLE", "SLI", "SLO", "SLU"],
    "mixtas": ["SAL", "SEL", "SIL", "SOL", "SUL", "SAM", "SEM", "SIM", "SOM", "SUM", 
               "SAN", "SEN", "SIN", "SON", "SUN", "SAR", "SER", "SIR", "SOR", "SUR", 
               "SAS", "SES", "SIS", "SOS", "SUS"],
  },
  "T": {
    "comunes": ["TA", "TE", "TI", "TO", "TU", "TLA", "TLE", "TLI", "TLO", "TLU", "TRA", "TRE", "TRI", "TRO", "TRU", "TOY",],
    "trabadas": ["TLAS", "TLES", "TLIS", "TLOS", "TLUS", "TRAS", "TRES", "TRIS", "TROS", "TRUS",
                 "TLAN", "TLEN", "TLIN", "TLON", "TLUN", "TRAN", "TREN", "TRIN", "TRON", "TRUN"],
    "mixtas": ["TAL", "TEL", "TIL", "TOL", "TUL", "TAM", "TEM", "TIM", "TOM", "TUM", 
               "TAN", "TEN", "TIN", "TON", "TUN", "TAR", "TER", "TIR", "TOR", "TUR", 
               "TAS", "TES", "TIS", "TOS", "TUS"],
  },
  "U": {
    "comunes": ["U", "UN", "UR", "US"],
    "trabadas": [],
    "mixtas": [],
  },
  "V": {
    "comunes": ["VA", "VE", "VI", "VO", "VU"],
    "trabadas": [],
    "mixtas": ["VAL", "VEL", "VIL", "VOL", "VUL", "VAM", "VEM", "VIM", "VOM", "VUM", 
               "VAN", "VEN", "VIN", "VON", "VUN", "VAR", "VER", "VIR", "VOR", "VUR", 
               "VAS", "VES", "VIS", "VOS", "VUS", "VAZ", "VEZ", "VIZ", "VOZ", "VUZ"],
  },
  "W": {
    "comunes": ["WA", "WI", "WEB", "WIN"],
    "trabadas": [],
    "mixtas": [],
  },
  "X": {
    "comunes": ["XA", "XE", "XI", "XO", "XU",],
    "trabadas": [],
    "mixtas": [],
  },
  "Y": {
    "comunes": ["Y", "YA", "YO"],
    "trabadas": [],
    "mixtas": [],
  },
  "Z": {
    "comunes": ["ZA", "ZE", "ZI", "ZO", "ZU"],
    "trabadas": [],
    "mixtas": ["ZAL", "ZEL", "ZIL", "ZOL", "ZUL", "ZAM", "ZEM", "ZIM", "ZOM", "ZUM", 
               "ZAN", "ZEN", "ZIN", "ZON", "ZUN", "ZAR", "ZER", "ZIR", "ZOR", "ZUR", 
               "ZAS", "ZES", "ZIS", "ZOS", "ZUS"],
  },
};