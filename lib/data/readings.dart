/// Textos de lectura graduados. Cada frase: original, transcripción, traducción.
/// El campo [Reading.lang] permite añadir textos de otros idiomas más adelante.
class Reading {
  const Reading({
    required this.title,
    required this.original,
    required this.level,
    required this.sentences,
    this.lang = 'zh',
  });

  final String title;
  final String original;
  final String level;
  final String lang;
  final List<(String, String, String)> sentences;
}

const readings = [
  Reading(
    title: 'Mi familia',
    original: '我的家',
    level: 'HSK 1',
    sentences: [
      ('我叫小明，我是中国人。', 'Wǒ jiào Xiǎo Míng, wǒ shì Zhōngguó rén.', 'Me llamo Xiao Ming, soy chino.'),
      ('我家有四口人：爸爸、妈妈、姐姐和我。', 'Wǒ jiā yǒu sì kǒu rén: bàba, māma, jiějie hé wǒ.', 'En mi familia somos cuatro: papá, mamá, mi hermana mayor y yo.'),
      ('爸爸是医生，妈妈是老师。', 'Bàba shì yīshēng, māma shì lǎoshī.', 'Papá es médico y mamá es profesora.'),
      ('姐姐在北京上大学。', 'Jiějie zài Běijīng shàng dàxué.', 'Mi hermana mayor va a la universidad en Pekín.'),
      ('我很喜欢我的家。', 'Wǒ hěn xǐhuan wǒ de jiā.', 'Me gusta mucho mi familia.'),
    ],
  ),
  Reading(
    title: 'Mi día',
    original: '我的一天',
    level: 'HSK 1',
    sentences: [
      ('我每天早上七点起床。', 'Wǒ měitiān zǎoshang qī diǎn qǐchuáng.', 'Todos los días me levanto a las siete de la mañana.'),
      ('我坐公交车去学校，路上要二十分钟。', 'Wǒ zuò gōngjiāochē qù xuéxiào, lùshang yào èrshí fēnzhōng.', 'Voy al colegio en autobús; el trayecto dura veinte minutos.'),
      ('上午我学习汉语，下午我去运动。', 'Shàngwǔ wǒ xuéxí Hànyǔ, xiàwǔ wǒ qù yùndòng.', 'Por la mañana estudio chino y por la tarde hago deporte.'),
      ('晚上我在家看书，有时候也看电视。', 'Wǎnshang wǒ zài jiā kàn shū, yǒu shíhou yě kàn diànshì.', 'Por la noche leo en casa; a veces también veo la tele.'),
      ('我十一点睡觉。', 'Wǒ shíyī diǎn shuìjiào.', 'Me acuesto a las once.'),
    ],
  ),
  Reading(
    title: 'En el restaurante',
    original: '去饭馆',
    level: 'HSK 2',
    sentences: [
      ('今天中午，我和朋友去饭馆吃饭。', 'Jīntiān zhōngwǔ, wǒ hé péngyou qù fànguǎn chī fàn.', 'Hoy al mediodía he ido a comer a un restaurante con un amigo.'),
      ('服务员问：“你们想吃什么？”', 'Fúwùyuán wèn: “Nǐmen xiǎng chī shénme?”', 'El camarero preguntó: «¿Qué queréis comer?».'),
      ('我说：“我们要一个鱼、一个菜和两碗米饭。”', 'Wǒ shuō: “Wǒmen yào yí ge yú, yí ge cài hé liǎng wǎn mǐfàn.”', 'Dije: «Queremos un pescado, un plato de verdura y dos cuencos de arroz».'),
      ('朋友想喝茶，我想喝水。', 'Péngyou xiǎng hē chá, wǒ xiǎng hē shuǐ.', 'Mi amigo quiere beber té y yo quiero agua.'),
      ('菜很好吃，也不贵。', 'Cài hěn hǎochī, yě bú guì.', 'La comida estaba muy rica y además no era cara.'),
    ],
  ),
  Reading(
    title: 'De compras',
    original: '买东西',
    level: 'HSK 2',
    sentences: [
      ('周末我去商店买东西。', 'Zhōumò wǒ qù shāngdiàn mǎi dōngxi.', 'El fin de semana fui a una tienda a comprar cosas.'),
      ('我看见一件红色的衣服，非常漂亮。', 'Wǒ kànjiàn yí jiàn hóngsè de yīfu, fēicháng piàoliang.', 'Vi una prenda roja muy bonita.'),
      ('我问：“这件衣服多少钱？”', 'Wǒ wèn: “Zhè jiàn yīfu duōshao qián?”', 'Pregunté: «¿Cuánto cuesta esta prenda?».'),
      ('服务员说：“三百块。”', 'Fúwùyuán shuō: “Sānbǎi kuài.”', 'La dependienta dijo: «Trescientos yuanes».'),
      ('太贵了！我没买，就回家了。', 'Tài guì le! Wǒ méi mǎi, jiù huí jiā le.', '¡Demasiado caro! No lo compré y me volví a casa.'),
    ],
  ),
  Reading(
    title: 'El invierno en Pekín',
    original: '北京的冬天',
    level: 'HSK 2',
    sentences: [
      ('北京的冬天很冷，常常刮风。', 'Běijīng de dōngtiān hěn lěng, chángcháng guā fēng.', 'El invierno en Pekín es muy frío y a menudo hace viento.'),
      ('昨天下雪了，外面都是白色的。', 'Zuótiān xià xuě le, wàimiàn dōu shì báisè de.', 'Ayer nevó y fuera todo estaba blanco.'),
      ('我穿了很多衣服，可是还觉得冷。', 'Wǒ chuānle hěn duō yīfu, kěshì hái juéde lěng.', 'Me puse mucha ropa, pero aun así tenía frío.'),
      ('我更喜欢夏天，因为可以去游泳。', 'Wǒ gèng xǐhuan xiàtiān, yīnwèi kěyǐ qù yóuyǒng.', 'Prefiero el verano, porque puedo ir a nadar.'),
    ],
  ),
  Reading(
    title: 'Aprender chino',
    original: '学汉语',
    level: 'HSK 3',
    sentences: [
      ('我学汉语已经一年了。', 'Wǒ xué Hànyǔ yǐjīng yì nián le.', 'Ya llevo un año estudiando chino.'),
      ('开始的时候，我觉得汉字很难。', 'Kāishǐ de shíhou, wǒ juéde Hànzì hěn nán.', 'Al principio, los caracteres me parecían muy difíciles.'),
      ('现在我每天写十个字，读一点儿课文。', 'Xiànzài wǒ měitiān xiě shí ge zì, dú yìdiǎnr kèwén.', 'Ahora escribo diez caracteres al día y leo un poco de texto.'),
      ('老师说我的发音越来越好了。', 'Lǎoshī shuō wǒ de fāyīn yuè lái yuè hǎo le.', 'El profesor dice que mi pronunciación es cada vez mejor.'),
      ('明年我想去中国旅游，跟中国人说汉语。', 'Míngnián wǒ xiǎng qù Zhōngguó lǚyóu, gēn Zhōngguó rén shuō Hànyǔ.', 'El año que viene quiero viajar a China y hablar chino con la gente de allí.'),
    ],
  ),
];
