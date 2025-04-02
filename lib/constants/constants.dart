import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_tts/flutter_tts.dart';

const List<String> palabrasValidas = [
"ABAJO", "ABRAZAR", "ABRIGO", "ABRIGOS", "ABRIR", "AGREGADO", "AGREGAN", "AGREGAR", "AGUA", "AGUJA", "AGUJAS", 
"ÁGUILA", "ÁGUILAS", "AHORA", "ALGO", "ALLÁ", "ALMOHADA", "ALMOHADAS", "ALTO", "ALTOS", "AMARILLO", "AMARILLOS", 
"AMIGA", "AMIGAS", "AMIGO", "AMIGOS", "AMOR", "ANDAR", "ANIMAL", "ANIMALES", "ANTES", "AQUÍ", "ARBOL", "ÁRBOL", 
"ARBUSTO", "ARBUSTOS", "ARDILLA", "ARDILLAS", "ARENA", "ARENAS", "ARCOÍRIS", "ARMARIO", "ARMARIOS", "ARRIBA", 
"ASIENTO", "AVE", "AVES", "AYER", "AZUL", "AZULES", "AZÚCAR", "BAILAR", "BAILES", "BAJO", "BAJOS", "BALLENAS", 
"BALLENA", "BARCO", "BARCOS", "BAÑO", "BAÑOS", "BEBÉ", "BEBÉS", "BEBER", "BIEN", "BIENES", "BICICLETA", "BICICLETAS", 
"BLANCA", "BLANCAS", "BLUSA", "BLUSAS", "BOLA", "BOLAS", "BOLSOS", "BOLSO", "BOSQUE", "BOSQUES", "BOTÓN", "BOTONES", 
"BOTA", "BOTAS", "BOSTEZAR", "BOSTEZO", "BOSTEZOS", "BOTE", "BOTES", "BOYA", "BOYAS", "BRINCAR", "BRISA", "BRISAS", 
"BÚHO", "BÚHOS", "BUFANDA", "BUFANDAS", "CABALLO", "CABALLOS", "CABRA", "CABRAS", "CACTUS", "CAFÉ", "CALENDARIO", 
"CALENDARIOS", "CALIENTE", "CALIENTES", "CALMA", "CALOR", "CAMAS", "CAMINAR", "CAMINA", "CAMINO", "CAMISA", "CAMISAS", 
"CAMA", "CAMIÓN", "CAMIONES", "CAMPO", "CAMPOS", "CANASTA", "CANDADO", "CANDADOS", "CANTA", "CANTAR", "CAOS", 
"CARACOL", "CARACOLES", "CARNE", "CARNES", "CARRETERA", "CARRO", "CARROS", "CARTÓN", "CARTONES", "CASA", "CASAS", 
"CASCO", "CASCOS", "CELESTE", "CELESTES", "CENTRO", "CERCA", "CERCANO", "CERCANOS", "CERDO", "CERDOS", "CERRAR", 
"CHICA", "CHICAS", "CHICO", "CHICOS", "CIEN", "CIENCIA", "CIENCIAS", "CLARO", "CLAROS", "COCINA", "COCO", "COLA", 
"COLCHÓN", "COLCHONES", "COLORES", "COLOR", "COMEDOR", "COME", "COMER", "COMIDA", "COMO", "COMPÁS", "COMPRAR", 
"COMPRA", "CONO", "CONOS", "CONTAR", "CONTROL", "CONTROLES", "CORBATAS", "CORBATA", "CORDILLERA", "CORDILLERAS", 
"CORTINA", "CORTINAS", "CREER", "CUADRADO", "CUADRADOS", "CUARTO", "CUARTOS", "CUCHARA", "CUCHARAS", "CUCHILLO", 
"CUCHILLOS", "CUIDAR", "CUMPLIR", "DADO", "DADOS", "DEBER", "DECIR", "DELFIN", "DELFINES", "DENSA", "DENSO", 
"DENTRO", "DESPUÉS", "DESAYUNAR", "DESAYUNO", "DESAYUNOS", "DESIERTO", "DESIERTOS", "DESTELLO", "DETRÁS", "DIBUJAR", 
"DIBUJO", "DIBUJOS", "DIFÍCIL", "DIFICULTAD", "DORMIR", "DORMITORIO", "DORMITORIOS", "DUDA", "DUDAS", "ECHAR", 
"ECLIPSE", "ELEFANTE", "ELEFANTES", "EMPUJAR", "EMPUJA", "EMPUJAN", "ENCENDER", "ENCIMA", "ENCONTRAR", "ENCUENTRA", 
"ENCUENTRO", "ENERGÍA", "ENFADO", "ENORME", "ENTRAR", "ENTRADA", "ENTRADAS", "ENTRANDO", "ENVIAR", "ERIZO", "ERIZOS", 
"ERROR", "ERRORES", "ESCALA", "ESCALAN", "ESCALANDO", "ESCALERA", "ESCALERAS", "ESCALÓN", "ESCALONES", "ESCONDE", 
"ESCONDEN", "ESCONDIDO", "ESCONDIDOS", "ESCONDITE", "ESCRIBE", "ESCRIBEN", "ESCRIBIR", "ESCRITORIO", "ESCRITORIOS", 
"ESCUCHAR", "ESFERA", "ESMERALDA", "ESMERALDAS", "ESPACIO", "ESPACIOS", "ESPIRAL", "ESTAR", "ESTRELLA", "ESTRELLAS", 
"ESTUDIO", "ESTUDIOS", "ESTUFA", "ESTUFAS", "EXAMEN", "EXÁMENES", "FÁCIL", "FAMILIA", "FAMILIAS", "FE", "FELICES", 
"FELIZ", "FIESTA", "FIESTAS", "FLAMENCO", "FLAMENCOS", "FLOR", "FLORES", "FRASE", "FRASES", "FRÍO", "FRUTA", "FRUTAS", 
"FROTAR", "FUEGO", "FUEGOS", "FUENTE", "FUENTES", "FUERA", "FUERTE", "FUGAZ", "GALAXIA", "GALAXIAS", "GALLO", "GALLOS", 
"GARAJE", "GARAJES", "GATO", "GATOS", "GIRA", "GIRANDO", "GIRAR", "GORILA", "GORILAS", "GORRA", "GORRAS", "GORRO", 
"GORROS", "GRACIAS", "GRANDE", "GRANDES", "GRIS", "GUANTE", "GUANTES", "HABLAR", "HACER", "HACIA", "HIELO", "HIJO", 
"HUMANOS", "HOGAR", "HOGARES", "HOJA", "HOJAS", "HOLA", "HONGO", "HONGOS", "HORMIGA", "HORMIGAS", "HOY", "HUECO", 
"HUELLA", "HUELLAS", "IDEA", "IDEAS", "IGLESIA", "IGLESIAS", "IGUAL", "ISLA", "ISLAS", "IRSE", "JABALÍ", "JABALÍES", 
"JARDÍN", "JARDINES", "JUGAR", "JUGUETE", "JUGUETES", "LAGO", "LAGOS", "LÁMPARA", "LÁMPARAS", "LANZAR", "LECHE", 
"LEER", "LEJANA", "LEJANAS", "LEJANO", "LEJANOS", "LEJOS", "LENTEJA", "LENTEJAS", "LENTO", "LIBRO", "LIBROS", 
"LIMPIEZA", "LIMPIO", "LLAVE", "LLAVES", "LOBO", "LOBOS", "LUZ", "LUCES", "LUGAR", "MAGIA", "MASA", "MASAS", 
"MESEDORA", "MESA", "MESAS", "MIEL", "MIL", "MOMENTO", "MONTAÑA", "MONTAÑAS", "MUCHOS", "MUEBLE", "MUEBLES", 
"NADA", "NARANJA", "NEGRO", "NINGUN", "NOCHE", "NOVENO", "NUEVE", "NUNCA", "OCHO", "ONCE", "OSCURO", "OTROS", 
"PALABRA", "PALABRAS", "PALO", "PALOS", "PANTALLA", "PANTALLAS", "PANTALÓN", "PANTALONES", "PAPA", "PAPÁ", "PAPEL", 
"PAPELES", "PARA", "PARED", "PAREDES", "PASILLO", "PATIO", "PATOS", "PERDER", "PERRO", "PERSONA", "PERSONAS", 
"PEQUEÑO", "PIE", "PIES", "PINCEL", "PINCELES", "PINTAR", "PINTURA", "PLANETA", "PLANETAS", "PLATO", "PLATOS", 
"POEMA", "POEMAS", "PORQUE", "PRIMER", "PROFESOR", "PROFESORA", "PROFESORES", "PROFESORAS", "PUERTA", "PUERTAS", 
"PUPITRE", "PUPITRES", "QUINTO", "RADIO", "RANA", "RANAS", "RAPIDO", "RARO", "RAYA", "RAYAS", "REAL", "RECIBIR", 
"REDONDO", "REFRI", "REMOLINO", "RENGLÓN", "RENGLONES", "REVISTA", "REVISTAS", "RÍO", "RISA", "RISAS", "ROJO", 
"ROSADO", "RUEDA", "RUEDAS", "SABER", "SALA", "SALIR", "SALUDO", "SALUDOS", "SANDALIA", "SANDALIAS", "SANTA", 
"SANTO", "SASTRE", "SASTRES", "SEGUNDO", "SEIS", "SEMILLA", "SEMILLAS", "SEPTIMO", "SER", "SÍLABA", "SÍLABAS", 
"SILLA", "SILLAS", "SIMPÁTICO", "SITIO", "SOPLO", "SOPLAR", "SORDO", "SORPRENDER", "SUAVE", "SUBIR", "SUCIO", 
"SUELO", "SUEÑO", "SUEÑOS", "SUFICIENTE", "SUEGRA", "SUEGROS", "SUELO", "SUMAR", "SUSURRO", "TABLA", "TABLAS", 
"TABLETA", "TAREA", "TAREAS", "TECHO", "TECLA", "TECLAS", "TELE", "TELEVISOR", "TELEVISORES", "TERCER", "TEXTO", 
"TEXTOS", "TIENDA", "TIENDAS", "TIERRA", "TIJERA", "TIJERAS", "TIPO", "TIPOS", "TODOS", "TORNILLO", "TORNILLOS", 
"TORTA", "TORTAS", "TRABAJO", "TRABAJOS", "TRATAR", "TRAVES", "TRAVESÍA", "TREN", "TRENES", "TRIÁNGULO", "TRIÁNGULOS", 
"TROMPO", "TROMPOS", "TUBO", "TUBOS", "UNO", "VASO", "VASOS", "VECES", "VEGETAL", "VEGETALES", "VER", "VERANO", 
"VERANOS", "VERBO", "VERBOS", "VERDE", "VERDES", "VIENTO", "VIENTOS", "VIEJO", "VIEJA", "VIEJOS", "VIEJAS", 
"VOLVER", "ZAPATO", "ZAPATOS", "MUÑECA", "MUÑECAS", "MUÑECO", "MUÑECOS",
"VENTANA", "VENTANAS", "VESTIDO", "VESTIDOS",
"A", "AL", "CON", "DA", "DAN", "DON", "DAR", "DE", "EL", "EN", "ES", "FE", "HA", "HE", "LA",
"LE", "LO", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
"NO", "QUE", "QUI", "SE", "SI", "SU", "SIN", "TE", "TU", "UN", "VA", "VAN"
"VE", "VEN", "VER", "VI", "WEB", "WI", "Y", "YA", "YO",
  ];

const List<String> silabasEspeciales = [
  "A", "AL", "CON", "DA", "DAN", "DON", "DAR", "DE", "EL", "EN", "ES", "FE", "HA", "HE", "LA",
  "LE", "LO", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
  "NO", "QUE", "QUI", "SE", "SI", "SU", "SIN", "TE", "TU", "UN", "VA", "VAN"
  "VE", "VEN", "VER", "VI", "WEB", "WI", "Y", "YA", "YO",
];

const List<String> IniciosDePalabras = [
  // Combina los valores de iniciosDePalabras3Silabas e iniciosDePalabras4Silabas
"ABA", "ABANI", "ABRA", "ABRI", "AGRE", "AGREGA", "AGU", "ÁGUI", "AHO", "ALMO", 
"ALMOHA", "AMARI", "ANI","ARBUS", "ARDI", "ARE", "ARCO", "ARCOÍ", "ARMA", 
"ARRI", "ASIEN", "AZU", "AZÚ", "BALLE", "BICICLE", "BOTO", "BOSTE","BUFAN", 
"CABA", "CALEN", "CALENDA", "CALI", "CALIEN", "CAMI","CAMIO", "CANAS", 
"CANDA","CARA", "CARACO", "CARRE", "CARRETE", "CARRO", "CARTO", "CELES", 
"COCI", "COLCHO", "COLO", "COME", "COMI", "CONTRO", "CORBA", "CORDI", 
"CORDILLE", "CORTI", "CUADRA",
];

const Map<String, List<String>> silabasPorLetra = {
  "A": ["Á", "A", "AL", "AN", "AR", "AS", "AM"],
  "B": ["B", "BA", "BE", "BI", "BO", "BU", "BAN", "BEN", "BIN", "BON", "BUN", "BLA", "BLE", "BLI", "BLO", "BLU", "BRA", "BRE", "BRI", "BRO", "BRU", "BRAN", "BREN", "BRIN", "BRON", "BRUN"],
  "C": ["CA", "CE", "CI", "CO", "CU", "CAS", "CES", "CIS", "COS", "CUS", "CAN", "CEN", "CIN", "CON", "CUN", "CAl", "CEl", "CIl", "COl", "CUl", "CLA", "CLE", "CLI", "CLO", "CLU",
        "CRA", "CRE", "CRI", "CRO", "CRU", "CIAS", "CAR", "CER", "CIR", "COR", "CUR", "CHA", "CHE", "CHI", "CHO", "CHU",],
  "D": ["D", "DA", "DE", "DI", "DO", "DU", "DAN", "DEN", "DIN", "DON", "DUN", "DAR", "DER", "DIR", "DOR", "DUR",],
  "E": ["É", "E", "EL", "EM", "EN", "ES", "ER"],
  "F": ["F", "FA", "FE", "FI", "FIES", "FO", "FU", "FAL", "FEL", "FIL", "FOL", "FUL", "FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU"],
  "G": ["G", "GA", "GE", "GI", "GO", "GU", "GUA", "GEN", "GUA", "GUE", "GUI", "GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU"],
  "H": ["H", "HA", "HE", "HI", "HIS", "HO", "HU"],
  "I": ["Í", "I", "IS", "IN", "IR", "IM"],
  "J": ["J", "JA", "JE", "JI", "JO", "JU", "JAS", "JES", "JIS", "JOS", "JUS"],
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