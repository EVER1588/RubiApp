import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_tts/flutter_tts.dart';

const List<String> palabrasValidas = [
"A", "AL", "CON", "DA", "DAN", "DAR", "DE", "DEL", "DI", "DON", "EL", "EN", "ES", 
"FÉ", "HA", "HE", "IR", "LA", "LAS", "LE", "LES", "LO", "LOS", "LUZ", 
"MAS", "ME", "MES", "MI", "MIS", "NI", "NO", "NOS", "DOS", 
"QUE", "QUI", "SE", "SER", "SI", "SIN", "SU", "SUS", "FÉ", "FAN", "FIN", 
"TAL", "TAN", "TE", "TEN", "TU", "TUS", "UN", "GEL", 
"VA", "VAN", "VE", "VEN", "VER", "VES", "VI", "VOY", "VOZ", 
"WEB", "WI", "Y", "YA", "YO", "BUS", "CRUZ", "HAN", "HAN", "HAS",

"ABAJO", "ABANICO", "ABRAZAR", "ABRIGO", "ABRIGOS", "ABRIR", "AGREGADO", "AGREGAN", "AGREGAR", "AGUA", "AGUJA", "AGUJAS", 
"ÁGUILA", "ÁGUILAS", "AHORA", "ALGO", "ALLÁ", "ALMOHADA", "ALMOHADAS", "ALTO", "ALTOS", "AMARILLO", "AMARILLOS", 
"AMIGA", "AMIGAS", "AMIGO", "AMIGOS", "AMA", "AMAN", "AMO", "AMOR", "ANDAR", "ANIMAL", "ANIMALES", "ANTES", "AQUÍ", "ARBOL", "ÁRBOL", 
"ARBUSTO", "ARBUSTOS", "ARDILLA", "ARDILLAS", "ARENA", "ARENAS", "ARCOÍRIS", "ARMARIO", "ARMARIOS", "ARRIBA", 
"ASIENTO", "AVE", "AVES", "AYER", "AZUL", "AZULES", "AZÚCAR", "BAILAR", "BAILES", "BAJO", "BAJOS", "BALLENAS", 
"BALLENA", "BARCO", "BARCOS", "BAÑO", "BAÑOS", "BEBÉ", "BEBÉS", "BEBER", "BIEN", "BIENES", "BICICLETA", "BICICLETAS", 
"BLANCA", "BLANCAS", "BLUSA", "BLUSAS", "BONITA", "BONITAS", "BONITO", "BONITOS", "BOLA", "BOLAS", "BOLSOS", "BOLSO", "BOSQUE", "BOSQUES", "BOTÓN", "BOTONES", 
"BOTA", "BOTAS", "BOSTEZAR", "BOSTEZO", "BOSTEZOS", "BOTE", "BOTES", "BOYA", "BOYAS", "BRINCAR", "BRISA", "BRISAS", 
"BÚHO", "BÚHOS", "BUFANDA", "BUFANDAS", "CABALLO", "CABALLOS", "CABRA", "CABRAS", "CACTUS", "CAFÉ", "CALENDARIO", 
"CALENDARIOS", "CALIENTE", "CALIENTES", "CALMA", "CALOR", "CAMAS", "CAMINAR", "CAMINA", "CAMINO", "CAMISA", "CAMISAS", 
"CAMA", "CAMIÓN", "CAMIONES", "CAMPO", "CAMPOS", "CANASTA", "CANDADO", "CANDADOS", "CANTA", "CANTAR", "CAOS", 
"CARACOL", "CARACOLES", "CARNE", "CARNES", "CARRETERA", "CARRO", "CARROS", "CARTÓN", "CARTONES", "CASA", "CASAS", 
"CASCO", "CASCOS", "CELESTE", "CELESTES", "CENTRO", "CERCA", "CERCANO", "CERCANOS", "CERDO", "CERDOS", "CERRAR", 
"CHICA", "CHICAS", "CHICO", "CHICOS", "CIEN", "CIENCIA", "CIENCIAS", "CLIP", "CLARO", "CLAROS", "COCINA", "COCO", "COLA", 
"COLCHÓN", "COLCHONES", "COLORES", "COLOR", "COMEDOR", "COME", "COMER", "COMIDA", "COMO", "COMPÁS", "COMPRAR", 
"COMPRA", "CONO", "CONOS", "CONTAR", "CONTROL", "CONTROLES", "CORBATAS", "CORBATA", "CORDILLERA", "CORDILLERAS", 
"CORTINA", "CORTINAS", "CREER", "CUADRADO", "CUADRADOS", "CUARTO", "CUARTOS", "CUCHARA", "CUCHARAS", "CUCHILLO", 
"CUCHILLOS", "CUMPLIR", "DADO", "DADOS", "DEBER", "DECIR", "DELFIN", "DELFINES", "DENSA", "DENSO", 
"DENTRO", "DESPUÉS", "DESAYUNAR", "DESAYUNO", "DESAYUNOS", "DESIERTO", "DESIERTOS", "DESTELLO", "DETRÁS", "DIBUJAR", 
"DIBUJO", "DIBUJOS", "DIFÍCIL", "DIFICULTAD", "DRONE", "DORMIR", "DORMITORIO", "DORMITORIOS", "DUDA", "DUDAS", "ECHAR", 
"ECLIPSE", "ELEFANTE", "ELEFANTES", "EMPUJAR", "EMPUJA", "EMPUJAN", "ENCIMA", "ENCONTRAR", "ENCUENTRA", 
"ENCUENTRO", "ENERGÍA", "ENFADO", "ENORME", "ENTRAR", "ENTRADA", "ENTRADAS", "ENTRANDO", "ENVIAR", "ERIZO", "ERIZOS", 
"ERROR", "ERRORES", "ESCALA", "ESCALAN", "ESCALANDO", "ESCALERA", "ESCALERAS", "ESCALÓN", "ESCALONES", "ESCONDE", 
"ESCONDEN", "ESCONDIDO", "ESCONDIDOS", "ESCONDITE", "ESCRIBE", "ESCRIBEN", "ESCRIBIR", "ESCRITORIO", "ESCRITORIOS", 
"ESCUCHAR", "ESFERA", "ESMERALDA", "ESMERALDAS", "ESPACIO", "ESPACIOS", "ESPIRAL", "ESTA", "ESTAS", "ESTAR", "ESTE", "ESTO", "ESTRELLA", "ESTRELLAS", 
"ESTUDIO", "ESTUDIOS", "ESTUFA", "ESTUFAS", "EXAMEN", "EXÁMENES", "FÁCIL", "FAMILIA", "FAMILIAS", "FELICES", 
"FELIZ", "FIESTA", "FIESTAS", "FLAMENCO", "FLAMENCOS", "FLOR", "FLORES", "FRASE", "FRASES", "FRÍO", "FRUTA", "FRUTAS", 
"FROTAR", "FUEGO", "FUEGOS", "FUENTE", "FUENTES", "FUERA", "FUERTE", "FUGAZ", "GALAXIA", "GALAXIAS", "GALLO", "GALLOS", 
"GARAJE", "GARAJES", "GATO", "GATOS", "GIRA", "GIRANDO", "GIRAR", "GORILA", "GORILAS", "GORRA", "GORRAS", "GORRO", 
"GORROS", "GRACIAS", "GRANDE", "GRANDES", "GRIS", "GUANTE", "GUANTES", "HABLAR", "HACER", "HACE", "HACEN", "HACEMOS", "HACIA", "HIELO", "HIJO", 
"HOGAR", "HOGARES", "HOJA", "HOJAS", "HOLA", "HONGO", "HONGOS", "HORMIGA", "HORMIGAS", "HOY", "HUECO", 
"HUELLA", "HUELLAS", "IDEA", "IDEAS", "IGLESIA", "IGLESIAS", "IGUAL", "ISLA", "ISLAS", "IRSE", "JABALÍ", "JABALÍES", 
"JARDÍN", "JARDINES", "JUGAR", "JUGUETE", "JUGUETES", "LAGO", "LAGOS", "LÁMPARA", "LÁMPARAS", "LANZAR", "LECHE", 
"LEER", "LEJANA", "LEJANAS", "LEJANO", "LEJANOS", "LEJOS", "LENTEJA", "LENTEJAS", "LENTO", "LIBRO", "LIBROS", 
"LIMPIEZA", "LIMPIO", "LLAVE", "LLAVES", "LOBO", "LOBOS", "LUCES", "LUGAR", "MAGIA", "MAMÁ", "MASA", "MASAS", 
"MESEDORA", "MESA", "MESAS", "MIEL", "MIL", "MOMENTO", "MONTAÑA", "MONTAÑAS", "MUCHO", "MUCHOS", "MUEBLE", "MUEBLES", 
"NADA", "NARANJA", "NEGRO", "NINGUN", "NOCHE", "NOVENO", "NUEVE", "NUNCA", "OCHO", "ONCE", "OSCURO", "OTROS", 
"PALABRA", "PALABRAS", "PALO", "PALOS", "PANTALLA", "PANTALLAS", "PANTALÓN", "PANTALONES", "PAPA", "PAPÁ", "PAPEL", 
"PAPELES", "PARA", "PARED", "PAREDES", "PASILLO", "PATIO", "PATOS", "PERDER", "PERRO", "PERSONA", "PERSONAS", 
"PEQUEÑO", "PIE", "PIES", "PINCEL", "PINCELES", "PINTAR", "PINTURA", "PLANETA", "PLANETAS", "PLATO", "PLATOS", 
"POEMA", "POEMAS", "PORQUE", "PRIMER", "PROFESOR", "PROFESORA", "PROFESORES", "PROFESORAS", "PUERTA", "PUERTAS", 
"PUPITRE", "PUPITRES", "QUINTO", "RADIO", "RANA", "RANAS", "RAPIDO", "RARO", "RAYA", "RAYAS", "REAL", "RECIBIR", 
"REDONDO", "REFRI", "REMOLINO", "RENGLÓN", "RENGLONES", "REVISTA", "REVISTAS", "RÍO", "RISA", "RISAS", "ROJO", 
"ROSADO", "SABER", "SALA", "SALIR", "SALUDO", "SALUDOS", "SANDALIA", "SANDALIAS", "SANTA", 
"SANTO", "SASTRE", "SASTRES", "SEGUNDO", "SEIS", "SEMILLA", "SEMILLAS", "SEPTIMO", "SER", "SÍLABA", "SÍLABAS", 
"SILLA", "SILLAS", "SIMPÁTICO", "SITIO", "SOPLO", "SOPLAR", "SORDO", "SORPRENDER", "SUAVE", "SUBIR", "SUCIO", 
"SUELO", "SUEÑO", "SUEÑOS", "SUFICIENTE", "SUEGRA", "SUEGROS", "SUMAR", "SUSURRO", "TABLA", "TABLAS", 
"TABLETA", "TAREA", "TAREAS", "TECHO", "TECLA", "TECLAS", "TELE", "TELEVISOR", "TELEVISORES", "TERCER", "TEXTO", 
"TEXTOS", "TIENDA", "TIENDAS", "TIERRA", "TIJERA", "TIJERAS", "TIPO", "TIPOS", "TODOS", "TORNILLO", "TORNILLOS", 
"TORTA", "TORTAS", "TRABAJO", "TRABAJOS", "TRATAR", "TRAVES", "TRAVESÍA", "TREN", "TRENES", "TRIÁNGULO", "TRIÁNGULOS", 
"TROMPO", "TROMPOS", "TUBO", "TUBOS", "UNO", "VASO", "VASOS", "VECES", "VEGETAL", "VEGETALES", "VERANO", 
"VERANOS", "VERBO", "VERBOS", "VERDE", "VERDES", "VIENTO", "VIENTOS", "VIEJO", "VIEJA", "VIEJOS", "VIEJAS", 
"VOLVER", "ZAPATO", "ZAPATOS", "MUÑECA", "MUÑECAS", "MUÑECO", "MUÑECOS",
"VENTANA", "VENTANAS", "VESTIDO", "VESTIDOS", "PLATA", "PLANTAS", "CEPILLO", "CEPILLOS", "CONEJO", "CONEJOS",
"PERICO", "PERICOS", "BOMBILLO", "BOMBILLOS", "CONEJITO", "METRO", "METROS", 
"KILÓMETRO", "QUIERO", "QUIERE", "QUIERES", "QUIEREN", "MURO", "PILA", "BATERIA", "BATERIAS", 
"RUEDA", "RUEDAS", "BRILLANTE", "BRILLANTES", "BRILLAR", "BRILLO", "BRILLITOS", "CANDELA", "CANDELAS", 
"ACOSTAR", "ACOSTADO", "ACOSTADA", "DORIR", "DORMIDO", "DORMIDA", "DURMINENDO", "PEINA", "PEINADO", "PEINADOS", 
"PEINANDO", "PEINANDOSE", "BOTELLA", "SABE", "SABEN", "SABES", "SUPER", "SUPE", "RAYO", "RAYOS", "TRUENO", "TRUENOS", 
"RELAMPAGO", "RELAMPAGOS", "MANDO", "MANDOS", "CAMARA", "CAMARAS", "LLAVERO", "LLAVEROS", "COLLAR", "COLLARES", 
"SOMBRILLA", "VENTILADOR", "CARGADOR", "CARGADORES", "CARGADO", "CARGANDO", "CARGA", "NAVE", "NAVES", "NAVEGA", 
"NAVEGAN", "NAVEGANTE", "NAVEGANTES", "VELERO", "VELEROS", "VELA", "MAR", "HUMANO", "HUMANOS", "HUNAMIDAD", 
"CUELLO", "DIENTE", "DIENTES", "TOBILLO", "TOBILLOS", "TALÓN", "TALONES", "MEDIA", "MEDIAS", "CALSETÍN", "LLAMA", 
"LLAMAR", "LLAMAN", "CELULAR", "CELULARES", "TELÉFONO", "TELÉFONOS", "PORTÁTIL", "PORTÁTILES", "VIDEO", "VIDEOS", "VIDEOJUEGO", 
"VIDEOJUEGOS", "CEJA", "CEJAS", "PESTAÑA", "PESTAÑAS", "LABIO", "LABIOS", "HOMBRO", "HOMBROS", "PECHO", "PANZA", 
"PANSA", "CADERA", "ESTÓMAGO", "ESPALDA", "TRASERO", "UÑA", "UÑAS", "CODO", "CODOS", "RODILLA", "RODILLAS", "FRENTE", 
"CONSOLA", "CONSOLAS", "JUGO", "JUGOS", "MONTE", "MONTA", "MONTAN", "MONTANDO", "SACA", "SACAR", "SACATE", "RETROVISOR", "RETROVISORES", 
"ALTAVOZ", "ALTAVOCES", "ESTIRA", "ESTIRAR", "ESTIRANDO", "MANO", "MANOS", "DEDO", "DEDOS", "BRAZO", "BRAZOS", "PIERNA", 
"PIERNAS", "CABEZA", "OJO", "OJOS", "NARÍZ", "BOCA", "OREJA", "OREJAS", "PELA", "PELAN", "PELANDO", "PELO", "PELÓN", 
"CABELLO", "HERMOSA", "HERMOSAS", "HERMOSO", "HERMOSOS", "LINDA", "LINDAS", "LINDO", "LINDOS", 
"JADE", "RUBÍ", "CUIDA", "CUIDAR", "CUIDAN", "CUIDARTE", "NECESITA", "NECESITAN", "NECESITO", 
"JUNTO", "JUNTAS", "JUNTOS", "LIBRETO", "LIBRETA", "LIBRETAS", "LIBRE", "LIBRES", "MIRADA", "MIRADAS", "MIRA", "MIRAN", 
"MIRAS", "VIDRIO", "VIDRIOS", "CABLE", "CABLES", "PASO", "PASOS", "PISA", "PISADA", "PISADAS", "PISAN", "NUESTRA", 
"NUESTRAS", "NUESTRO", "NUESTROS", "LENTE", "LENTES", "VIVE", "VIVO", "VIVEN", "VIVIMOS", "PIEL", "CONMIGO", "CONTIGO", 
"FIEL", "FIELES", "PENSAR", "PIENSA", "PIENSO", "PIENSAN", "PENSAMOS", "ABRASO", "GUSTA", "LOCA", "LOCAS", "LOCO", "LOCOS", 
"DÍA", "DÍAS", "FOTO", "FOTOS", "FOTOGRAFÍA", "FOTOGRAFÍAS", "TENER", "TENERTE", "TENEMOS", "RECUERDO", "RECUERDOS", "TENIA",
"FALTA", "FALTAN", "FALTANDO", "TERMINA","TERMINAN", "TERMINÓ", "TERMINARON", "POCO", "POQUITO", "APAGA", "APAGAR", "APAGÓ", "APAGÓN", 
"ENCENDER", "ENCENDI", "ENCENDIÓ", "ENCIENDE", "ENCENDIDO", "ENTENDER", "ENTIENDE", "ENTIENDEN", "VEZ", "CORAZÓN", "SOLO", "SOLA", 
"SOLEDAD", "SOLITA", "SOLITARIO", "SUELE", "SUELEN", "ÁNGEL", "ÁNGELES", "ANGELICAL", "ACOMPAÑA", "COMPAÑIA", "COMPAÑERO", "COMPAÑERA", 
"PASADO", "PASA", "PASAN", "PASAMOS", "PASARON", "RETRO", "YENDO", "VAMOS", "FRASCO", "PLAN",
];

const List<String> silabasEspeciales = [
  "A", "AL", "CON", "DA", "DAN", "DAR", "DE", "EL", "EN", "ES", "FÉ", "HA", "HE", "LA",
  "LE", "LO", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
  "NO", "QUE", "QUI", "SE", "SI", "SU", "SIN", "TE", "TU", "UN", "VA", "VAN"
  "VE", "VEN", "VER", "VI", "WEB", "WI", "Y", "YA", "YO",
];

const List<String> IniciosDePalabras = [
  // Combina los valores de iniciosDePalabras3Silabas e iniciosDePalabras4Silabas
"ABA", "ABRA", "ABRI", "AGRE", "AGREGA", "AGU", "ÁGUI", "AHO", "ALMO", "ALMOHA", 
"AMARI", "ANI","ARBUS", "ARDI", "ARE", "ARCO", "ARCOÍ", "ARMA", "ARRI", "ASIEN", 
"AZU", "AZÚ", "BALLE", "BICICLE", "BOTO", "BOSTE", "BUFAN", "CABA", "CALEN", 
"CALENDA", "CALI", "CALIEN", "CAMI", "CAMIO", "CANAS", "CANDA", "CARA", "CARACO", 
"CARRE", "CARRETE", "CARRO", "CARTO", "CELES", "COCI", "COLCHO", "COLO", "COME", 
"COMI", "CONTRO", "CORBA", "CORDI", "CORDILLE", "CORTI", "CUA", "CUADRA", "CUCHA", 
"CUCHI", "DELFINES",  "DESA", "DESAYU", "DESI", "DESIER", "DESTE", "DIBU", "DIFÍ", 
"DIFICUL", "DORMI", "DORMITO", "DORMITO", "ECLIP", "ELE", "ELEFAN", "EMPU", "ENCEN", 
"ENCI", "ENCON", "ENCONTRA", "ENCUEN", "ENER", "ENFA", "ENOR", "ERI", "ERRO", "ESCA", 
"ESCA", "ESCALE", "ESCALO", "ESCON", "ESCONDI", "ESCRI", "ESCRITO", "ESCU", "ESFE", 
"ESME", "ESMERAL", "ESPA", "ESPI", "ESTRE", "ESTU", "EXA", "EXÁME", "FAMI", "FAMILI", 
"FELI", "FELICE",  "FLAME", "FLAMEN", "GALA", "GALAXI", "GARA", "GIRA", "GIRAN", 
"GORI", "GORILAS", "GORRA", "GORRAS", "HUMA", "HOGA", "HORMI", "IGLE", "IGLESI", 
"JABA", "JARDI", "JUGUE", "LÁMPA", "LEJA", "LENTE", "LIMPI", "LIMPIE", "MESE", "MESEDO", 
"MOME", "MOMEN", "MONTA", "MUE", "NARA", "NARAN", "NOVE", "OSCU", "PANTA", "PANTALO",
"PAPE", "PARE", "PERSO", "PEQUE", "PINCE", "PINTU", "PLANE", "POE", "PROFE", "PROFESO",
"PUPI", "RAPI", "RECI", "REDON", "REMO", "REMOLI", "RENGLO", "REVIS", "SALU", "SANDA", 
"SANDALI", "SEGU", "SEGUN", "SEMI", "SEPTI", "SÍLA", "SIMPA", "SIMPATI", "SORPRE", 
"SORPREN", "SUFI", "SUFI", "SUFICI", "SUFICIEN", "SUSU", "TABLE", "TIJE", "TORNI", 
"TRABA", "TRAVE", "TRSBECI", "TRIÁN", "TRIÁNGU", "VEGE", "VETEGA", "VEGETAL", "VERA", 
"ZAPA", "MUÑE", "VENTA", "VESTI", "BOTE", "TRUE", "RELAM", "RELAMPA", "COLLA", "SOMBRI",
"CEPI", "CONE", "PERI", "BOMBI", "CONEGI", "KILÓ", "KILÓME", "QUIE", "BATE", "BATERI",
"RUE", "BRILLAN", "BRILLI", "CANDE", "ACOS", "ACOSTA", "DORMI", "DURMIEN", "PEINAN", 
"VENTI", "VENTILA", "CARGA", "VELE", "HUMA", "HUMANI", "DIEN", "TOBI", "TALO", "CALSE", 
"CELU", "TELÉ", "TELÉFO", "PORTÁ", "VIDE", "VIDEOJU", "VIDEOJUE", "PESTA", "CADE", "ESTÓ", 
"ESTÓMA", "ESPA", "ESPAL", "TRASE", "RODI", "CONSO", "RETROVI", "RETROVSO", "RETROVISORE", 
"ALTAVO", "ALTAVOCE", "ESTI", "PIER", "CABE", "HERMO", "BONI", "NECE", "NECESI", "VIDRI", 
"NUES", "VIVI", "CONMI", "CONTI", "PIEN", "PENSA", "ABRA", "FOTOGRA", "FOTOGRAFÍ", "TENE", 
"RECU", "RECUER", "TENI", "TERMI", "TERMINARO", "POQUI", "APA", "ENCE", "ENCEN", "ENCI", 
"ENCIEN", "ENTE", "ENTEN", "ENTENDE", "ENTI", "ENTIEN", "CORA", "CORAZÓ", "SOLE", "SOLEDA", 
"SOLI", "SOLITARI", "SUE", "ÁNGE", "ÁNGELE", "ANGE", "ANGELI", "ANGELICA", "ACO", "ACOM", 
"ACOMPA", "COMPA", "COMPAÑI", "COMPAÑE", "PASAMO", "PASARO", "HACEMO",

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
    "comunes": ["BA", "BE", "BI", "BO", "BU"],
    "trabadas": ["BLA", "BLE", "BLI", "BLO", "BLU", "BRA", "BRE", "BRI", "BRO", "BRU", 
                 "BLAS", "BLES", "BLIS", "BLOS", "BLUS", "BRAS", "BRES", "BRIS", "BROS", "BRUS",
                 "BLAN", "BLEN", "BLIN", "BLON", "BLUN", "BRAN", "BREN", "BRIN", "BRON", "BRUN"],
    "mixtas": ["BAL", "BEL", "BIL", "BOL", "BUL", "BAM", "BEM", "BIM", "BOM", "BUM", 
               "BAN", "BEN", "BIN", "BON", "BUN", "BAR", "BER", "BIR", "BOR", "BUR", 
               "BAS", "BES", "BIS", "BOS", "BUS"],
  },
  "C": {
    "comunes": ["CA", "CE", "CI", "CO", "CU", "CLA", "CLE", "CLI", "CLO", "CLU",],
    "trabadas": ["CHA", "CHE", "CHI", "CHO", "CHU", "CRA", "CRE", "CRI", "CRO", "CRU",
                "CLAS", "CLES", "CLIS", "CLOS", "CLUS", "CRAS", "CRES", "CRIS", "CROS", "CRUS",
                "CLAN", "CLEN", "CLIN", "CLON", "CLUN", "CRAN", "CREN", "CRIN", "CRON", "CRUN"],
    "mixtas": ["CAL", "CEL", "CIL", "COL", "CUL", "CAM", "CEM", "CIM", "COM", "CUM", 
               "CAN", "CEN", "CIN", "CON", "CUN", "CAR", "CER", "CIR", "COR", "CUR", 
               "CAS", "CES", "CIS", "COS", "CUS"],
  },
  "D": {
    "comunes": ["DA", "DE", "DI", "DO", "DU"],
    "trabadas": ["DLA", "DLE", "DLI", "DLO", "DLU", "DRA", "DRE", "DRI", "DRO", "DRU", 
                 "DLAS", "DLES", "DLIS", "DLOS", "DLUS", "DRAS", "DRES", "DRIS", "DROS", "DRUS",
                 "DLAN", "DLEN", "DLIN", "DLON", "DLUN", "DRAN", "DREN", "DRIN", "DRON", "DRUN"],
    "mixtas": ["DAL", "DEL", "DIL", "DOL", "DUL", "DAM", "DEM", "DIM", "DOM", "DUM", 
               "DAN", "DEN", "DIN", "DON", "DUN", "DAR", "DER", "DIR", "DOR", "DUR", 
               "DAS", "DES", "DIS", "DOS", "DUS"],
  },
  "E": {
    "comunes": ["EL", "EM", "EN", "ES", "ER"],
    "trabadas": [],
    "mixtas": [],
  },
  "F": {
    "comunes": ["FA", "FE", "FI", "FO", "FU"],
    "trabadas": ["FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU", 
                 "FLAS", "FLES", "FLIS", "FLOS", "FLUS", "FRAS", "FRES", "FRIS", "FROS", "FRUS",
                 "FLAN", "FLEN", "FLIN", "FLON", "FLUN", "FRAN", "FREN", "FRIN", "FRON", "FRUN"],
    "mixtas": ["FAL", "FEL", "FIL", "FOL", "FUL", "FAM", "FEM", "FIM", "FOM", "FUM", 
               "FAN", "FEN", "FIN", "FON", "FUN", "FAR", "FER", "FIR", "FOR", "FUR", 
               "FAS", "FES", "FIS", "FOS", "FUS"],
  },
  "G": {
    "comunes": ["GA", "GE", "GI", "GO", "GU"],
    "trabadas": ["GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU", 
                 "GLAS", "GLES", "GLIS", "GLOS", "GLUS", "GRAS", "GRES", "GRIS", "GROS", "GRUS",
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
    "comunes": ["LA", "LE", "LI", "LO", "LU"],
    "trabadas": ["LLA", "LLE", "LLI", "LLO", "LLU"],
    "mixtas": ["LLAN", "LLEN", "LLIN", "LLON", "LLUN", "LLAS", "LLES", "LLIS", "LLOS", "LLUS",],
  },
  "M": {
    "comunes": ["MA", "ME", "MI", "MO", "MU"],
    "trabadas": [],
    "mixtas": ["MAL", "MEL", "MIL", "MOL", "MUL", "MAS", "MES", "MIS", "MOS", "MUS"],
  },
  "N": {
    "comunes": ["NA", "NE", "NI", "NO", "NU"],
    "trabadas": [],
    "mixtas": [],
  },
  "Ñ": {
    "comunes": ["ÑA", "ÑE", "ÑI", "ÑO", "ÑU"],
    "trabadas": [],
    "mixtas": [],
  },
  "O": {
    "comunes": ["OS", "ON"],
    "trabadas": [],
    "mixtas": [],
  },
  "P": {
    "comunes": ["PA", "PE", "PI", "PO", "PU"],
    "trabadas": ["PLA", "PLE", "PLI", "PLO", "PLU", "PRA", "PRE", "PRI", "PRO", "PRU", 
                 "PLAS", "PLES", "PLIS", "PLOS", "PLUS", "PRAS", "PRES", "PRIS", "PROS", "PRUS",
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
    "trabadas": [],
    "mixtas": [],
  },
  "S": {
    "comunes": ["SA", "SE", "SI", "SO", "SU"],
    "trabadas": ["SLA", "SLE", "SLI", "SLO", "SLU"],
    "mixtas": [],
  },
  "T": {
    "comunes": ["TA", "TE", "TI", "TO", "TU"],
    "trabadas": ["TLA", "TLE", "TLI", "TLO", "TLU", "TRA", "TRE", "TRI", "TRO", "TRU", 
                 "TLAS", "TLES", "TLIS", "TLOS", "TLUS", "TRAS", "TRES", "TRIS", "TROS", "TRUS",
                 "TLAN", "TLEN", "TLIN", "TLON", "TLUN", "TRAN", "TREN", "TRIN", "TRON", "TRUN"],
    "mixtas": ["TAL", "TEL", "TIL", "TOL", "TUL", "TAM", "TEM", "TIM", "TOM", "TUM", 
               "TAN", "TEN", "TIN", "TON", "TUN", "TAR", "TER", "TIR", "TOR", "TUR", 
               "TAS", "TES", "TIS", "TOS", "TUS"],
  },
  "U": {
    "comunes": ["UN", "UR", "US"],
    "trabadas": [],
    "mixtas": [],
  },
  "V": {
    "comunes": ["VA", "VE", "VI", "VO", "VU"],
    "trabadas": [],
    "mixtas": [],
  },
  "W": {
    "comunes": ["WEB", "WI"],
    "trabadas": [],
    "mixtas": [],
  },
  "X": {
    "comunes": ["XA", "XE", "XI"],
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
    "mixtas": [],
  },
};


// Función para acentuar automáticamente una sílaba
String acentuarSilaba(String silaba) {
  if (silaba.isEmpty) return silaba;
  
  // Mapa de vocales a sus versiones acentuadas
  const Map<String, String> vocalesAcentuadas = {
    'A': 'Á',
    'E': 'É',
    'I': 'Í',
    'O': 'Ó',
    'U': 'Ú',
    'a': 'á',
    'e': 'é',
    'i': 'í',
    'o': 'ó',
    'u': 'ú',
  };
  
  // Buscar la primera vocal en la sílaba
  for (int i = 0; i < silaba.length; i++) {
    String letra = silaba[i];
    if ('AEIOUaeiou'.contains(letra)) {
      // Reemplazar la vocal con su versión acentuada
      return silaba.substring(0, i) + 
             vocalesAcentuadas[letra]! + 
             silaba.substring(i + 1);
    }
  }
  
  // Si no se encontró vocal, devolver la sílaba original
  return silaba;
}

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