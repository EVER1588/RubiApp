import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_tts/flutter_tts.dart';

const List<String> palabrasValidas = [
  "ABAJO", "ABRAZAR", "ABRIGO", "ABRIGOS", "ABRIR", "CAMA", "CAMAS", "AGREGAR", "AGREGADO",
  "AGREGAN", "AGUJA", "AGUJAS",
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
  "CERRAR", "CHICA", "CHICAS", "CHICO", "CHICOS", "COMETA", 
  "COMIDA", "COMO", "CAMPO", "COMPRA", "COMPRAR", "COMPÁS",
  "CISNE", "CISNES", "CLARO", "CLAROS", "COCINA", "COCO", "COLCHÓN", "COLA,"
  "COLCHONES", "COLINA", "COLINAS", "COLOR", "COLORES", "COLUMNA", "COME",
  "COMEDOR", "COMEN", "COMER", "COMIENDO", "COMPAÑERO", "COMPAÑEROS","COMPAÑERA", "COMPAÑERAS", 
  "COMPLEJO", "COMPLEJOS", "COMPLETO", "COMPLETOS", "CONTROL", "CONEJO", "CONEJOS", "CORBATAS",
  "CORBATA", "CORTINA", "CORTINAS", "CREER", "CUADRADO", "CUADRADOS", "CUARTO",
  "CUARTOS", "CUCHARA", "CUCHARAS", "CUCHILLO", "CUCHILLOS", "DADO", "DADOS",
  "DEBAJO", "DEBER", "DECIR", "DICE", "DICEN", "DELFIN", "DENTRO",
  "DESAYUNA", "DESAYUNAN", "DESAYUNO", "DESAYUNOS", "DESIERTO", "DESIERTOS", "DESORDEN", "DESPUÉS", "DESTELLO",
  "DIBUJAR", "DIBUJO", "DIBUJOS", "DIFÍCIL", "DIFICULTAD", "DORMIR", "DORMITORIO",
  "DORMITORIOS", "DUDA", "DUDAS", "DURANTE", "ECHAR", "ECLIPSE", "ELEFANTE",
  "ELEFANTES", "ELLA", "ELLAS", "ELLOS", "EMPUJA", "EMPUJAN", "EMPUJAR",
  "ENAMORA", "ANAMORAR", "ENCIMA", "ENCENDER", "ENCUENTRA", "ENCONTRAR", "ENCUENTRO",
  "ENFADO", "ENTRADA", "ENTRADAS", "ENTRANDO", "ENTRAR", "ENVIAR", "EQUIPO", "EQUIPOS",
  "ERIZO", "ERIZOS", "ERROR", "ERRORES", 'ESCALA', 'ESCALAN', 'ESCALANDO', "ESCALERA", "ESCALERAS", "ESCALÓN",
  "ESCALONES", "ESCONDE", "ESCONDEN", "ESCONDIDO", "ESCONDIDOS", "ESCONDITE", "ESCRIBE",
  "ESCRIBEN", "ESCRIBIR", "ESCRITORIO", "ESCRITORIOS", "ESCUCHAR", "ESFERA", "ESMERALDA",
  "ESMERALDAS", "ESPACIO", "ESPACIOS", "ESPIRAL", "ESTAR", "ESTRELLA", "ESTRELLAS",
  "ESTUDIO", "ESTUDIOS", "ESTUFA", "ESTUFAS", "FÁCIL", "FAMILIA", "FAMILIAS",
  "FE", "FELICES", "FELIZ", "FLAMENCO", "FLAMENCOS", "FLOR", "FLORES", "FIESTA", "FIESTAS",
  "FRESA", "FRESAS", "FRÁGIL", "FRÍO", "FROTAR", "FUEGO", "FUEGOS",
  "FUENTE", "FUENTES", "FUERA", "FUERTE", "FUGAZ", "GALAXIA", "GALAXIAS",
  "GALLO", "GALLOS", "GARAJE", "GARAJES", "GATO", "GATOS", "GIRA",
  "GIRANDO", "GIRAR", "GIRÓ", "GORILA", "GORILAS", "GORRA", "GORRAS",
  "GORRO", "GORROS", "GRANDE", "GRANDES", "GRIS", "GUANTE", "GUANTES",
  "GUERRA", "GUERRAS", "HABLAR", "HACER", "HACIA", "HIELO", "HIJO", "HUMANO", "HUMANOS",
  "HIJOS", "HIJO", "HOGAR", "HOGARES", "HOJA", "HOJAS", "HOLA", "HONGO", "HONGOS",
  "HORMIGA", "HORMIGAS", "HOY", "HUECO", "HUELLA", "HUELLAS", "IDEA",
  "IDEAS", "IGLESIA", "IGLESIAS", "IGUAL", "ISLA", "ISLAS", "IRSE",
  "JABALÍ", "JABALÍES", "JARDÍN", "JARDINES", "JUGAR", "LAGO", "LAGOS",
  "LÁMPARA", "LÁMPARAS", "LANZAR", "LECHE", "LEER", "LEJANA", "LEJANAS",
  "LEJANO", "LEJANOS", "LEJOS", "LENTEJA", "LENTEJAS", "LENTO", "LLAVE",
  "LLAVES", "LOBO", "LOBOS", "LUCES", "LUZ", "MAGIA", "MAMÁ", "MIEL", 
  "PAN", "PELUCHE", "PANTUFLA", "PANTUFLAS", "POSTE", "POSTES", "RUBÍ", "RUBI",
  "RUEDA", "RUEDAS", "RODRIGUEZ", "SOLIS", "SOMBRERO", "SOMBRILLA", "VASO",
  "SOPLO", "SOPLAR", "SUAVE", "SUEÑO", "SUEÑOS", "SUFICIENTE", "VACA", "VACAS",
  "VALLE", "VALLES", "VAMOS", "VAN", "VERANO", "VERANOS", "INVIERNO", "INVIERNOS",
  "OTOÑO", "OTOÑOS", "VENTANA","VENTANAS", "VERDAD", "VERDADES", "VERDURA", "VERDURAS", "VEGETAL", "VEGETALES", 
  "VENDER", "VENDIDO", "VERDE", "VERDES", "MISMO", "MISMA" "MISMOS", "MISMAS",
  "VIAJE", "VIAJES", "VIEJO", "VIEJA", "VIEJOS", "VIEJAS", "VACACIONES", "FRUTA", "FRUTAS,"
  ];

const List<String> silabasEspeciales = [
  "A", "AL", "CON", "DA", "DAN", "DON", "DAR", "DE", "EL", "EN", "ES", "FE", "HA", "HE", "LA",
  "LE", "LO", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
  "NO", "QUE", "QUI", "SE", "SI", "SU", "SIN", "TE", "TU", "UN", "VA", "VAN"
  "VE", "VEN", "VER", "VI", "WEB", "WI", "Y", "YA", "YO",
];

final List<String> iniciosDePalabras3Silabas = [
  'CELU', 'CARGA', 'MANZA', 'CAMI', 'VENTA', 'ESCUE', 'MONTA',
  'AMI', 'ABRA', 'ABRI', 'ÁGUI', 'ANI', 'ARBO', 'ARBUS', "HUMA",
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
  'ESTU', 'FAMI', "COMI", "PELU", "SUFI", "VELO",  
  'ENCUE', 'ENCI', 'ENCON', 'ENFA', "AGRE",
];

final List<String> iniciosDePalabras4Silabas = [
  'CHOCOLA', 'BIBLIOTE', 'FAMILI', 'MARIPO', 'AUTOMO', 'IMPRESO', 
  'ALMOHA', 'AMARI', 'ANIMA', 'ARCOÍ', 'BICICLE', 'CALENDA', 'CAMIO', 
  'CARRETE', 'COMPAÑE', 'DESAYU', 'DIFICUL', 'DORMITO', 'ELEFAN', 'ESCALE', 
  'ESCALAN', 'ESCALO', 'ESCONDI', 'ESCRITO', 'ESMERAL', "VACACIO",
  'ENAMO', "SUFICIEN", "VELOCI",
];

const Map<String, List<String>> silabasPorLetra = {
  "A": ["Á", "A", "AL", "AN", "AR", "AS", "AM"],
  "B": ["B", "BA", "BE", "BI", "BO", "BU", "BAN", "BEN", "BIN", "BON", "BUN", "BLA", "BLE", "BLI", "BLO", "BLU", "BRA", "BRE", "BRI", "BRO", "BRU", "BRAN", "BREN", "BRIN", "BRON", "BRUN"],
  "C": ["CA", "CE", "CI", "CO", "CU", "CAN", "CEN", "CIN", "CON", "CUN", "CAl", "CEl", "CIl", "COl", "CUl", "CLA", "CLE", "CLI", "CLO", "CLU",
        "CRA", "CRE", "CRI", "CRO", "CRU", "CIAS", "CAR", "CER", "CIR", "COR", "CUR",],
  "D": ["D", "DA", "DE", "DI", "DO", "DU", "DAN", "DEN", "DIN", "DON", "DUN", "DAR", "DER", "DIR", "DOR", "DUR",],
  "E": ["É", "E", "EL", "EM", "EN", "ES", "ER"],
  "F": ["F", "FA", "FE", "FI", "FIES", "FO", "FU", "FAL", "FEL", "FIL", "FOL", "FUL", "FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU"],
  "G": ["G", "GA", "GE", "GI", "GO", "GU", "GUA", "GEN", "GUA", "GUE", "GUI", "GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU"],
  "H": ["H", "HA", "HE", "HI", "HIS", "HO", "HU"],
  "I": ["Í", "I", "IS", "IN", "IR", "IM"],
  "J": ["J", "JA", "JE", "JI", "JO", "JU"],
  "K": ["K", "KA", "KE", "KI", "KO", "KU"],
  "L": ["L", "LA", "LE", "LI", "LO", "LU", "LAS", "LOS", "LUZ", "LLA", "LLE", "LLI", "LLO", "LLU"],
  "M": ["M", "MA", "ME", "MI", "MO", "MU", "MAS", "MES", "MIS", "MOS"],
  "N": ["N", "NA", "NE", "NI", "NO", "NU"],
  "Ñ": ["Ñ", "ÑA", "ÑE", "ÑI", "ÑO", "ÑU"],
  "O": ["Ó", "O", "OS", "ON"],
  "P": ["P", "PA", "PE", "PI", "PO", "PU", "PAL", "PEL", "PIL", "POL", "PUL", "PLA", "PLE", "PLI", "PLO", "PLU", "PRA", "PRE", "PRI", "PRO", "PRU"],
  "Q": ["Q", "QUE", "QUI"],
  "R": ["R", "RA", "RAL", "RE", "RI", "RO", "RU"],
  "S": ["S", "SA", "SE", "SI", "SO", "SU", "SAN", "SEN", "SIN", "SON", "SUN", "SAM", "SEM", "SIM", "SO", "SUM"],
  "T": ["T", "TA", "TE", "TI", "TO", "TU", "TRA", "TRE", "TRI", "TRO", "TRU"],
  "U": ["Ú", "U", "UL", "UN", "UR", "US"],
  "V": ["V", "VA", "VE", "VI", "VO", "VU", "VAN", "VEN", "VIN", "VON", "VUN", "VAR", "VER", "VIR", "VOR", "VUR",
        "VAL", "VEL", "VEL", "VOL", "VUL",],
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