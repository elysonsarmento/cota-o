import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

main() {
  menu();
}

void menu() {
  print('################# Início #################');
  print('\nSelecione uma das opções abaixo:');
  print('1 - Ver a cotação de hoje');
  print('2 - Registrar a cotação de hoje');
  print('3 - Ver cotação registrada');

  String option = stdin.readLineSync();

  switch (int.parse(option)) {
    case 1:
      today();
      break;
    case 2:
      registerData();
      break;
    case 3:
      listData();
      break;
    default:
      print('\n\nOps, opção inválida. Selecione uma opção válida!\n\n');
      menu();
      break;
  }
}

void registerData() async {
  var hgData = await getData();
  dynamic fileData = readFile();

  fileData = (fileData != null && fileData.length > 0
      ? json.decode(fileData)
      : List());

  bool exist = false;
  fileData.forEach((data) {
    if (data['date'] == now()) exist = true;
  });
  if (!exist) {
    fileData.add({"date": now(), "data": "${hgData['data']}"});

    Directory dir = Directory.current;
    File file = File(dir.path + '/meu_arquivo.txt');
    RandomAccessFile raf = file.openSync(mode: FileMode.write);

    raf.writeStringSync(json.encode(fileData).toString());
    raf.flushSync();
    raf.closeSync();
    print('\n\nDados salvos');
  } else
    print(
        "\n\nRegistro não adicioonado, já existe log financeiro de hoje cadastrado!");
}

listData() {
  dynamic fileData = readFile();
  fileData = (fileData != null && fileData.length > 0
      ? json.decode(fileData)
      : List());
  print('\n\n Listagem dos dados');

  fileData.forEach((data) {
    print('${data['date']} -> ${data['data']}');
  });
}

String readFile() {
  Directory dir = Directory.current;
  File file = File(dir.path + '/meu_arquivo.txt');
  if (!file.existsSync()) {
    print('Arquivo não encontrado');
    return null;
  }
  return file.readAsStringSync();
}

void today() async {
  var data = await getData();
  print('\n\n################# HG Brasil - Cotação ################# ');
  print('${data['date']} -> ${data['data']}');
}

Future getData() async {
  String url = "https://api.hgbrasil.com/finance?key=5d052c19";
  http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    var data = json.decode(response.body)['results']['currencies'];
    var usd = data['USD'];
    var eur = data['EUR'];
    var gbp = data['GBP'];
    var ars = data['ARS'];
    var btc = data['BTC'];

    Map formatedData = Map();
    formatedData['date'] = now();
    formatedData['data'] =
    '${usd['name']}: ${usd['buy']} | ${eur['name']}: ${eur['buy']} | ${gbp['name']}: ${gbp['buy']} | ${ars['name']}: ${ars['buy']} | ${btc['name']}: ${btc['buy']}';

    return formatedData;
  } else
    throw Exception('Falhou!');
}

String now() {
  var now = new DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(
      2, '0')}/${now.year.toString().padLeft(2, '0')}';
}
