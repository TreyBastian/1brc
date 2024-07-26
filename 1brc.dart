import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

final newLine = 10;
final semiColon = 59;
final minus = 45;

class Result {
  double total = 0;
  double? min = null;
  double? max = null;
  double count = 0;

  void incrementCount() {
    this.count += 1;
  }

  void addToTotal(double value) {
    this.total += value;
  }

  void processMin(double value) {
    if (this.min == null || this.min! > value) {
      this.min = value;
    }
  }

  void processMax(double value) {
    if (this.max == null || this.max! < value) {
      this.max = value;
    }
  }

  double avg() {
    return (this.total / this.count);
  }
}

final Map<String, Result> res =
    SplayTreeMap<String, Result>((a, b) => a.compareTo(b));

void main() async {
  final file = File('measurements.txt').openSync();
  final fileSize = file.lengthSync();
  final maxLineLength = 106;

  final threadCount = Platform.numberOfProcessors;

  final chunkSize = fileSize ~/ threadCount;
  final offsets = <int>[];

  int offset = 0;
  for (int i = 0; i < threadCount; i++) {
    offsets.add(offset);

    offset += chunkSize;

    if (offset >= fileSize) {
      break;
    }
    file.setPositionSync(offset);
    var line = file.readSync(maxLineLength);

    offset += line.indexOf(newLine) + 1;
  }
  final processor =
      List<Future<Map<String, Result>>>.generate(offsets.length, (int i) {
    var end = offsets.length == i + 1 ? fileSize : offsets[i + 1];
    return Isolate.run(() => processChunk(offsets[i], end));
  });
  for (var res in await Future.wait(processor)) {
    addResults(res);
  }

  printResults();
}

void addResults(Map<String, Result> results) {
  results.forEach((key, val) {
    res.putIfAbsent(key, () => new Result())
      ..addToTotal(val.total)
      ..processMin(val.min!)
      ..processMax(val.max!)
      ..count += val.count;
  });
}

Future<Map<String, Result>> processChunk(int start, int end) async {
  final res = new HashMap<String, Result>();
  final file = File("measurements.txt");
  List<int> buffer = List<int>.filled(106, 0);
  String line = '';
  int ct = 0;
  List<String> split;
  await for (var chunk in file.openRead(start, end)) {
    for (var b in chunk) {
      if (b != newLine) {
        buffer[ct] = b;
        ct++;
      } else {
        line = utf8.decode(buffer.take(ct).toList());
        split = line.split(';');
        var value = double.parse(split[1]);
        res.putIfAbsent(split[0], () => new Result())
          ..addToTotal(value!)
          ..processMin(value)
          ..processMax(value)
          ..incrementCount();
        ct = 0;
      }
    }
  }
  return res;
}

void printResults() {
  res.forEach((key, value) {
    print('$key;${value.min};${value.avg().toStringAsFixed(1)};${value.max}');
  });
}
