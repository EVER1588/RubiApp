import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_tts/flutter_tts.dart';

const List<String> palabrasValidas = [
  "ABAJO", "ABRAZAR", "ABRIGO", "ABRIGOS", "ABRIR", "CAMA", "CAMAS",
  "AGUA", "ÁGUILA", "ÁGUILAS", "AHORA", "ALGO", "ALLÁ", "ALMOHADA", "ALMOHADAS",
  "ALTO", "ALTOS", "AMARILLO", "AMARILLOS", "AMIGA", "AMIGAS", "AMIGO", "AMIGOS",
  "AMOR", "ANDAR", "ANIMAL", "ANIMALES",
  "ANTES", "AQUÍ", "ARBOLES", "ÁRBOL", "ARBUSTO", "ARBUSTOS", "ARDILLA",
  "ARDILLAS", "ARENA", "ARENAS", "ARCOÍRIS", "ARMARIO", "ARMARIOS", "ASIENTO",
  "AVE", "AVES", "AURORA", "AURORAS", "AYER", "AZÚCAR", "AZUL", "AZULES",
  "BAILAR", "BAILES", "BAJO", "BAJOS", "BALLENA", "BALLENAS", "BARCO",
  "BARCOS", "BAÑO", "BAÑOS", "BEBÉ", "BEBÉS", "BEBER", "BIEN",
  "BIENES", "BICICLETA", "BICICLETAS", "BLANCA", "BLANCAS", "BLUSA", "BLUSAS",
  "BOLSO", "BOLSOS", "BOSQUE", "BOSQUES", "BOSTEZAR", "BOSTEZO", "BOSTEZOS",
  "BOTÓN", "BOTONES", "BRINCA", "BRINCAR", "BRISA", "BRISAS", "BÚHO",
  "BÚHOS", "BUFANDA", "BUFANDAS", "CABALLO", "CABALLOS", "CABRA", "CABRAS",
  "CACTUS", "CADA", "CAFÉ", "CALENDARIO", "CALENDARIOS", "CALIENTE", "CALIENTES",
  "CALLE", "CALMA", "CALOR", "CAMELLO", "CAMELLOS", 'CAMINA', "CAMINAR", "CAMINO", 
  "CAMISA", "CAMISAS", "CAMIÓN", "CAMIONES", "CAMPO", "CAMPOS", "CANDADO",
  "CANDADOS", "CANTA", "CANTAR", "CAOS", "CARACOL", "CARACOLES", "CARNE",
  "CARNES", "CARRETERA", "CARRO", "CARTÓN", "CARTONES", "CASA", "CASAS",
  "CELESTE", "CELESTES", "CERCA", "CERCANO", "CERCANOS", "CERDO", "CERDOS",
  "CERRAR", "CHICA", "CHICAS", "CHICO", "CHICOS",
  "CISNE", "CISNES", "CLARO", "CLAROS", "COCINA", "COCO", "COLCHÓN",
  "COLCHONES", "COLINA", "COLINAS", "COLOR", "COLORES", "COLUMNA", "COME",
  "COMEDOR", "COMEN", "COMER", "COMIENDO", "COMPAÑERO", "COMPAÑEROS", "COMPLEJO",
  "COMPLEJOS", "COMPLETO", "COMPLETOS", "CON", "CONEJO", "CONEJOS", "CORBATAS",
  "CORBATA", "CORTINA", "CORTINAS", "CREER", "CUADRADO", "CUADRADOS", "CUARTO",
  "CUARTOS", "CUCHARA", "CUCHARAS", "CUCHILLO", "CUCHILLOS", "DADO", "DADOS",
  "DEBAJO", "DEBER", "DECIR", "DICE", "DICEN", "DELFIN", "DENTRO",
  "DESAYUNA", "DESAYUNAN", "DESAYUNO", "DESAYUNOS", "DESIERTO", "DESIERTOS", "DESORDEN", "DESPUÉS", "DESTELLO",
  "DIBUJAR", "DIBUJO", "DIBUJOS", "DIFÍCIL", "DIFICULTAD", "DORMIR", "DORMITORIO",
  "DORMITORIOS", "DUDA", "DUDAS", "DURANTE", "ECHAR", "ECLIPSE", "ELEFANTE",
  "ELEFANTES", "ELLA", "ELLAS", "ELLOS", "EMPUJA", "EMPUJAN", "EMPUJAR",
  "ENTRADA", "ENTRADAS", "ENTRANDO", "ENTRAR", "ENVIAR", "EQUIPO", "EQUIPOS",
  "ERIZO", "ERIZOS", "ERROR", "ERRORES", 'ESCALA', 'ESCALAN', 'ESCALANDO', "ESCALERA", "ESCALERAS", "ESCALÓN",
  "ESCALONES", "ESCONDE", "ESCONDEN", "ESCONDIDO", "ESCONDIDOS", "ESCONDITE", "ESCRIBE",
  "ESCRIBEN", "ESCRIBIR", "ESCRITORIO", "ESCRITORIOS", "ESCUCHAR", "ESFERA", "ESMERALDA",
  "ESMERALDAS", "ESPACIO", "ESPACIOS", "ESPIRAL", "ESTAR", "ESTRELLA", "ESTRELLAS",
  "ESTUDIO", "ESTUDIOS", "ESTUFA", "ESTUFAS", "FÁCIL", "FAMILIA", "FAMILIAS",
  "FE", "FELICES", "FELIZ", "FLAMENCO", "FLAMENCOS", "FLOR", "FLORES",
  "FRESA", "FRESAS", "FRÁGIL", "FRÍO", "FROTAR", "FUEGO", "FUEGOS",
  "FUENTE", "FUENTES", "FUERA", "FUERTE", "FUGAZ", "GALAXIA", "GALAXIAS",
  "GALLO", "GALLOS", "GARAJE", "GARAJES", "GATO", "GATOS", "GIRA",
  "GIRANDO", "GIRAR", "GIRÓ", "GORILA", "GORILAS", "GORRA", "GORRAS",
  "GORRO", "GORROS", "GRANDE", "GRANDES", "GRIS", "GUANTE", "GUANTES",
  "GUERRA", "GUERRAS", "HABLAR", "HACER", "HACIA", "HIELO", "HIJO",
  "HIJOS", "HOGAR", "HOGARES", "HOJA", "HOJAS", "HOLA", "HONGO", "HONGOS",
  "HORMIGA", "HORMIGAS", "HOY", "HUECO", "HUELLA", "HUELLAS", "IDEA",
  "IDEAS", "IGLESIA", "IGLESIAS", "IGUAL", "ISLA", "ISLAS", "IRSE",
  "JABALÍ", "JABALÍES", "JARDÍN", "JARDINES", "JUGAR", "LAGO", "LAGOS",
  "LÁMPARA", "LÁMPARAS", "LANZAR", "LECHE", "LEER", "LEJANA", "LEJANAS",
  "LEJANO", "LEJANOS", "LEJOS", "LENTEJA", "LENTEJAS", "LENTO", "LLAVE",
  "LLAVES", "LOBO", "LOBOS", "LUCES", "LUZ", "MAGIA", "MAMÁ",
  "MIEL", "PANTUFLA", "PANTUFLAS", "POSTE", "POSTES", "RUBÍ", "RUBI",
  "RUEDA", "RUEDAS", "RODRIGUEZ", "SOLIS"
];

const List<String> silabasEspeciales = [
  "A", "AL", "DA", "DE", "EL", "EN", "ES", "FE", "HA", "LA",
  "LE", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
  "NO", "QUE", "QUI", "SE", "SI", "SU", "TE", "TU", "UN", "VA",
  "VE", "VI", "WEB", "WI", "Y", "YA", "YO",
];

final List<String> iniciosDePalabras3Silabas = [
  'CELU', 'CARGA', 'MANZA', 'CAMI', 'VENTA', 'ESCUE', 'MONTA',
  'AMI', 'ABRA', 'ABRI', 'ÁGUI', 'ANI', 'ARBO', 'ARBUS', 
  'ARDI', 'ARE', 'ARMA', 'ASIEN', 'AURO', 'AZÚ', 'AZU', 
  'BALLE', 'BOSTE', 'BOTO', 'BUFAN', 'CABA', 'CALIEN', 'CAME', 
  'CAMI', 'CANDA', 'CARA', 'CARTO', 'CELES', 'CERCA', 'COCI', 
  'COLCHO', 'COLI', 'COLO', 'COLUM', 'COME', 'COMIEN', 'COMPLE', 
  'CONE', 'CORBA', 'CORTI', 'CUADRA', 'CUCHA', 'CUCHI', 'DEBA', 
  'DESIER', 'DESOR', 'DIBU', 'DIFÍ', 'DURAN', 'ECLIP', 'EMPU', 
  'ENTRA', 'ENTRAN', 'EQUI', 'ERI', 'ERRO', 'ESCA', 'ESCON', 
  'ESCRI', 'ESCU', 'ESFE', 'ESPA', 'ESPI', 'ESTRE', 'FELI', 
  'FLAMEN', 'GALA', 'GARA', 'GIRAN', 'GORI', 'HORMI', 'IGLE', 
  'JABA', 'JARDI', 'LÁMPA', 'LEJA', 'LENTE', 'PANTU', 'RODRI', 
  'ESTU', 'FAMI', 
];

final List<String> iniciosDePalabras4Silabas = [
  'CHOCOLA', 'BIBLIOTE', 'FAMILI', 'MARIPO', 'AUTOMO', 'IMPRESO', 
  'ALMOHA', 'AMARI', 'ANIMA', 'ARCOÍ', 'BICICLE', 'CALENDA', 'CAMIO', 
  'CARRETE', 'COMPAÑE', 'DESAYU', 'DIFICUL', 'DORMITO', 'ELEFAN', 'ESCALE', 
  'ESCALAN', 'ESCALO', 'ESCONDI', 'ESCRITO', 'ESMERAL',
];

const Map<String, List<String>> silabasPorLetra = {
  "A": ["Á", "A", "AL", "AN", "AR", "AS", "AM"],
  "B": ["B", "BA", "BE", "BI", "BO", "BU", "BLA", "BLE", "BLI", "BLO", "BLU", "BRA", "BRE", "BRI", "BRO", "BRU", "BRAN", "BREN", "BRIN", "BRON", "BRUN"],
  "C": ["C", "CA", "CE", "CI", "CO", "CU", "CLA", "CLE", "CLI", "CLO", "CLU", "CRA", "CRE", "CRI", "CRO", "CRU", "CIAS"],
  "D": ["D", "DA", "DE", "DI", "DO", "DU"],
  "E": ["É", "E", "EL", "EM", "EN", "ES", "ER"],
  "F": ["F", "FA", "FE", "FI", "FO", "FU", "FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU"],
  "G": ["G", "GA", "GE", "GI", "GO", "GU", "GEN", "GUA", "GUE", "GUI", "GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU"],
  "H": ["H", "HA", "HE", "HI", "HIS", "HO", "HU"],
  "I": ["Í", "I", "IS", "IN", "IR", "IM"],
  "J": ["J", "JA", "JE", "JI", "JO", "JU"],
  "K": ["K", "KA", "KE", "KI", "KO", "KU"],
  "L": ["L", "LA", "LE", "LI", "LO", "LU", "LAS", "LOS", "LUZ", "LLA", "LLE", "LLI", "LLO", "LLU"],
  "M": ["M", "MA", "ME", "MI", "MO", "MU", "MAS", "MES", "MIS", "MOS"],
  "N": ["N", "NA", "NE", "NI", "NO", "NU"],
  "Ñ": ["Ñ", "ÑA", "ÑE", "ÑI", "ÑO", "ÑU"],
  "O": ["Ó", "O", "OS", "ON"],
  "P": ["P", "PA", "PE", "PI", "PO", "PU", "PLA", "PLE", "PLI", "PLO", "PLU", "PRA", "PRE", "PRI", "PRO", "PRU"],
  "Q": ["Q", "QUE", "QUI"],
  "R": ["R", "RA", "RAL", "RE", "RI", "RO", "RU"],
  "S": ["S", "SA", "SE", "SI", "SO", "SU"],
  "T": ["T", "TA", "TE", "TI", "TO", "TU", "TRA", "TRE", "TRI", "TRO", "TRU"],
  "U": ["Ú", "U", "UL", "UN", "UR", "US"],
  "V": ["V", "VA", "VE", "VI", "VO", "VU"],
  "W": ["W", "WEB", "WI"],
  "X": ["X", "XA", "XE", "XI"],
  "Y": ["Y", "YA", "YO"],
  "Z": ["Z", "ZA", "ZE", "ZI", "ZO", "ZU"],
};

const double blockWidth = 60.0;
const double blockHeight = 40.0;
const double blockSpacing = 8.0;

final FlutterTts flutterTts = FlutterTts(); // Instancia global de Flutter TTS

// Configurar Flutter TTS
void configurarFlutterTts() async {
  await flutterTts.setLanguage("es-ES"); // Configurar el idioma a español
  await flutterTts.setPitch(1.0); // Configurar el tono
  await flutterTts.setSpeechRate(0.5); // Configurar la velocidad de habla
  await flutterTts.awaitSpeakCompletion(true); // Esperar a que termine de hablar
}

// Función global para reproducir texto en voz alta
Future<void> decirTexto(String texto) async {
  if (texto.isNotEmpty) {
    await flutterTts.speak(texto); // Decir el texto en voz alta
  }
}

// Función global para detener la reproducción
Future<void> detenerTexto() async {
  await flutterTts.stop(); // Detener cualquier reproducción en curso
}