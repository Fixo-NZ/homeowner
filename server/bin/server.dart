import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';

class Config {
  final String host;
  final int port;
  final String user;
  final String password;
  final String db;
  final int serverPort;

  Config({required this.host, required this.port, required this.user, required this.password, required this.db, required this.serverPort});

  factory Config.fromFile(String path) {
    final raw = File(path).readAsStringSync();
    final Map<String, dynamic> j = jsonDecode(raw) as Map<String, dynamic>;
    return Config(
      host: j['host'] as String? ?? 'localhost',
      port: (j['port'] as num?)?.toInt() ?? 3306,
      user: j['user'] as String? ?? 'root',
      password: j['password'] as String? ?? '',
      db: j['db'] as String? ?? 'homeowner_db',
      serverPort: (j['server_port'] as num?)?.toInt() ?? 8080,
    );
  }
}

Future<MySqlConnection> connectDb(Config cfg) async {
  final settings = ConnectionSettings(
    host: cfg.host,
    port: cfg.port,
    user: cfg.user,
    password: cfg.password,
    db: cfg.db,
  );
  return await MySqlConnection.connect(settings);
}

Future<Response> _jsonResponse(Object? body, {int status = 200}) async {
  return Response(status, body: jsonEncode(body), headers: {'content-type': 'application/json'});
}

void main(List<String> args) async {
  final configPath = args.isNotEmpty ? args[0] : 'server/config.json';
  if (!File(configPath).existsSync()) {
    print('Please create $configPath from config_template.json and set your DB credentials.');
    exit(1);
  }

  final cfg = Config.fromFile(configPath);
  final conn = await connectDb(cfg);

  final router = Router();

  router.get('/api/feedback/reviews', (Request req) async {
    final results = await conn.query('SELECT id, name, rating, created_at, comment, likes, is_liked, media_paths, contractor_id FROM reviews ORDER BY created_at DESC');
    final list = results.map((row) {
      return {
        'id': row[0],
        'name': row[1],
        'rating': row[2],
        'date': (row[3] as DateTime).toIso8601String(),
        'comment': row[4],
        'likes': row[5],
        'isLiked': (row[6] as int) == 1,
        'mediaPaths': jsonDecode(row[7] ?? '[]'),
        'contractorId': row[8],
      };
    }).toList();
    return _jsonResponse({'data': list});
  });

  router.post('/api/feedback/reviews', (Request req) async {
    final payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final name = payload['name'] as String? ?? 'Anonymous';
    final rating = (payload['rating'] as num?)?.toInt() ?? 0;
    final dateStr = payload['date'] as String? ?? DateTime.now().toIso8601String();
    final comment = payload['comment'] as String? ?? '';
    final likes = (payload['likes'] as num?)?.toInt() ?? 0;
    final isLiked = (payload['isLiked'] as bool?) ?? false;
    final media = payload['mediaPaths'] ?? payload['mediaFiles'] ?? [];
    final contractorId = payload['contractorId'] as String?;

    final dt = DateTime.tryParse(dateStr) ?? DateTime.now();

    final res = await conn.query('INSERT INTO reviews (name, rating, created_at, comment, likes, is_liked, media_paths, contractor_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [
      name,
      rating,
      dt,
      comment,
      likes,
      isLiked ? 1 : 0,
      jsonEncode(media),
      contractorId,
    ]);

    final insertedId = res.insertId;
    final fetch = await conn.query('SELECT id, name, rating, created_at, comment, likes, is_liked, media_paths, contractor_id FROM reviews WHERE id = ?', [insertedId]);
    if (fetch.isNotEmpty) {
      final row = fetch.first;
      return _jsonResponse({'data': {
        'id': row[0],
        'name': row[1],
        'rating': row[2],
        'date': (row[3] as DateTime).toIso8601String(),
        'comment': row[4],
        'likes': row[5],
        'isLiked': (row[6] as int) == 1,
        'mediaPaths': jsonDecode(row[7] ?? '[]'),
        'contractorId': row[8],
      }} , status: 201);
    }

    return _jsonResponse({'error': 'Insert failed'}, status: 500);
  });

  router.delete('/api/feedback/reviews/<id|[0-9]+>', (Request req, String id) async {
    final res = await conn.query('DELETE FROM reviews WHERE id = ?', [int.parse(id)]);
    if (res.affectedRows > 0) return Response(204);
    return _jsonResponse({'error': 'Not found'}, status: 404);
  });

  router.patch('/api/feedback/reviews/<id|[0-9]+>/like', (Request req, String id) async {
    final fetch = await conn.query('SELECT likes, is_liked FROM reviews WHERE id = ?', [int.parse(id)]);
    if (fetch.isEmpty) return _jsonResponse({'error': 'Not found'}, status: 404);
    final row = fetch.first;
    final currentLikes = (row[0] as int?) ?? 0;
    final currentLiked = (row[1] as int?) == 1;
    final newLiked = !currentLiked;
    final newLikes = currentLikes + (newLiked ? 1 : -1);
    await conn.query('UPDATE reviews SET likes = ?, is_liked = ? WHERE id = ?', [newLikes, newLiked ? 1 : 0, int.parse(id)]);
    final updated = await conn.query('SELECT id, name, rating, created_at, comment, likes, is_liked, media_paths, contractor_id FROM reviews WHERE id = ?', [int.parse(id)]);
    final r = updated.first;
    return _jsonResponse({'data': {
      'id': r[0],
      'name': r[1],
      'rating': r[2],
      'date': (r[3] as DateTime).toIso8601String(),
      'comment': r[4],
      'likes': r[5],
      'isLiked': (r[6] as int) == 1,
      'mediaPaths': jsonDecode(r[7] ?? '[]'),
      'contractorId': r[8],
    }});
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, cfg.serverPort);
  print('Server running on port ${server.port}');
}
