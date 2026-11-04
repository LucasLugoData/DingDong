typedef TaggedWord = (String, String);

class ReadingExercise {
  const ReadingExercise({
    required this.readingTitle,
    required this.ideaQuestion,
    required this.options,
    required this.correctIndex,
    required this.taggedSentences,
  });

  final String readingTitle;
  final String ideaQuestion;
  final List<String> options;
  final int correctIndex;
  final List<List<TaggedWord>> taggedSentences;
}

const readingExercises = <ReadingExercise>[
  ReadingExercise(
    readingTitle: 'Mi familia',
    ideaQuestion: '¿De qué trata principalmente el texto?',
    options: ['La familia de Xiao Ming', 'Un viaje a Pekín', 'Un día en el colegio', 'La comida favorita'],
    correctIndex: 0,
    taggedSentences: [
      [('我', 'sujeto'), ('叫', 'verbo'), ('小明', 'objeto'), ('，', 'partícula'), ('我', 'sujeto'), ('是', 'verbo'), ('中国人', 'sustantivo'), ('。', 'partícula')],
      [('我家', 'lugar'), ('有', 'verbo'), ('四', 'número'), ('口', 'clasificador'), ('人', 'sustantivo'), ('：', 'partícula'), ('爸爸', 'sustantivo'), ('、', 'partícula'), ('妈妈', 'sustantivo'), ('、', 'partícula'), ('姐姐', 'sustantivo'), ('和', 'partícula'), ('我', 'sujeto'), ('。', 'partícula')],
      [('姐姐', 'sujeto'), ('在', 'partícula'), ('北京', 'lugar'), ('上', 'verbo'), ('大学', 'objeto'), ('。', 'partícula')],
    ],
  ),
  ReadingExercise(
    readingTitle: 'Mi día',
    ideaQuestion: '¿Qué cuenta principalmente el texto?',
    options: ['La rutina diaria de quien habla', 'Una visita al médico', 'Una excursión familiar', 'Una clase de deporte'],
    correctIndex: 0,
    taggedSentences: [
      [('我', 'sujeto'), ('每天', 'tiempo'), ('早上', 'tiempo'), ('七', 'número'), ('点', 'clasificador'), ('起床', 'verbo'), ('。', 'partícula')],
      [('我', 'sujeto'), ('坐', 'verbo'), ('公交车', 'objeto'), ('去', 'verbo'), ('学校', 'lugar'), ('，', 'partícula'), ('路上', 'lugar'), ('要', 'verbo'), ('二十', 'número'), ('分钟', 'tiempo'), ('。', 'partícula')],
      [('晚上', 'tiempo'), ('我', 'sujeto'), ('在', 'partícula'), ('家', 'lugar'), ('看', 'verbo'), ('书', 'objeto'), ('，', 'partícula'), ('有时候', 'adverbio'), ('也', 'adverbio'), ('看', 'verbo'), ('电视', 'objeto'), ('。', 'partícula')],
    ],
  ),
  ReadingExercise(
    readingTitle: 'En el restaurante',
    ideaQuestion: '¿Cuál es la idea central del texto?',
    options: ['Una comida con un amigo en un restaurante', 'Comprar comida para casa', 'Trabajar como camarero', 'Aprender a cocinar arroz'],
    correctIndex: 0,
    taggedSentences: [
      [('今天', 'tiempo'), ('中午', 'tiempo'), ('，', 'partícula'), ('我', 'sujeto'), ('和', 'partícula'), ('朋友', 'sustantivo'), ('去', 'verbo'), ('饭馆', 'lugar'), ('吃饭', 'verbo'), ('。', 'partícula')],
      [('朋友', 'sujeto'), ('想', 'verbo'), ('喝', 'verbo'), ('茶', 'objeto'), ('，', 'partícula'), ('我', 'sujeto'), ('想', 'verbo'), ('喝', 'verbo'), ('水', 'objeto'), ('。', 'partícula')],
      [('服务员', 'sujeto'), ('问', 'verbo'), ('：', 'partícula'), ('“', 'partícula'), ('你们', 'sujeto'), ('想', 'verbo'), ('吃', 'verbo'), ('什么', 'objeto'), ('？', 'partícula'), ('”', 'partícula')],
    ],
  ),
  ReadingExercise(
    readingTitle: 'De compras',
    ideaQuestion: '¿Qué sucede principalmente en el texto?',
    options: ['La persona ve una prenda cara y vuelve a casa', 'La persona compra ropa para un amigo', 'La dependienta busca una tienda', 'La persona vende comida'],
    correctIndex: 0,
    taggedSentences: [
      [('周末', 'tiempo'), ('我', 'sujeto'), ('去', 'verbo'), ('商店', 'lugar'), ('买', 'verbo'), ('东西', 'objeto'), ('。', 'partícula')],
      [('我', 'sujeto'), ('看见', 'verbo'), ('一', 'número'), ('件', 'clasificador'), ('红色', 'adjetivo'), ('的', 'partícula'), ('衣服', 'objeto'), ('，', 'partícula'), ('非常', 'adverbio'), ('漂亮', 'adjetivo'), ('。', 'partícula')],
      [('太', 'adverbio'), ('贵', 'adjetivo'), ('了', 'partícula'), ('！', 'partícula'), ('我', 'sujeto'), ('没', 'adverbio'), ('买', 'verbo'), ('，', 'partícula'), ('就', 'adverbio'), ('回', 'verbo'), ('家', 'lugar'), ('了', 'partícula'), ('。', 'partícula')],
    ],
  ),
  ReadingExercise(
    readingTitle: 'El invierno en Pekín',
    ideaQuestion: '¿De qué trata principalmente el texto?',
    options: ['El invierno frío de Pekín y la preferencia por el verano', 'Un viaje de verano a la playa', 'La ropa que se compra en invierno', 'El clima de todas las estaciones'],
    correctIndex: 0,
    taggedSentences: [
      [('北京', 'lugar'), ('的', 'partícula'), ('冬天', 'tiempo'), ('很', 'adverbio'), ('冷', 'adjetivo'), ('，', 'partícula'), ('常常', 'adverbio'), ('刮', 'verbo'), ('风', 'objeto'), ('。', 'partícula')],
      [('昨天', 'tiempo'), ('下雪', 'verbo'), ('了', 'partícula'), ('，', 'partícula'), ('外面', 'lugar'), ('都', 'adverbio'), ('是', 'verbo'), ('白色', 'adjetivo'), ('的', 'partícula'), ('。', 'partícula')],
      [('我', 'sujeto'), ('更', 'adverbio'), ('喜欢', 'verbo'), ('夏天', 'tiempo'), ('，', 'partícula'), ('因为', 'partícula'), ('可以', 'verbo'), ('去', 'verbo'), ('游泳', 'verbo'), ('。', 'partícula')],
    ],
  ),
  ReadingExercise(
    readingTitle: 'Aprender chino',
    ideaQuestion: '¿Cuál es la idea central del texto?',
    options: ['El progreso y los planes de alguien que estudia chino', 'Una clase sobre la historia de China', 'Un profesor que aprende a nadar', 'Un viaje de estudios a Pekín'],
    correctIndex: 0,
    taggedSentences: [
      [('我', 'sujeto'), ('学', 'verbo'), ('汉语', 'objeto'), ('已经', 'adverbio'), ('一', 'número'), ('年', 'tiempo'), ('了', 'partícula'), ('。', 'partícula')],
      [('现在', 'tiempo'), ('我', 'sujeto'), ('每天', 'tiempo'), ('写', 'verbo'), ('十', 'número'), ('个', 'clasificador'), ('字', 'objeto'), ('，', 'partícula'), ('读', 'verbo'), ('一点儿', 'número'), ('课文', 'objeto'), ('。', 'partícula')],
      [('明年', 'tiempo'), ('我', 'sujeto'), ('想', 'verbo'), ('去', 'verbo'), ('中国', 'lugar'), ('旅游', 'verbo'), ('，', 'partícula'), ('跟', 'partícula'), ('中国人', 'sustantivo'), ('说', 'verbo'), ('汉语', 'objeto'), ('。', 'partícula')],
    ],
  ),
];
