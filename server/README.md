Homeowner Feedback Server
=========================

This is a minimal Shelf-based HTTP server that persists feedback reviews to a MySQL database.

Setup
-----

1. Copy `config_template.json` to `config.json` and fill in your MySQL credentials.

2. Create the `reviews` table in your MySQL database. Example schema:

```sql
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `rating` int DEFAULT 0,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `comment` text,
  `likes` int DEFAULT 0,
  `is_liked` tinyint(1) DEFAULT 0,
  `media_paths` text,
  `contractor_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
);
```

3. Install dependencies and run the server from the `server/` folder:

```
dart pub get; dart run bin/server.dart server/config.json
```

API Endpoints
-------------

- `GET /api/feedback/reviews` — list reviews
- `POST /api/feedback/reviews` — create a review (JSON body)
- `DELETE /api/feedback/reviews/:id` — delete a review
- `PATCH /api/feedback/reviews/:id/like` — toggle like for a review

Notes
-----
- `media_paths` is stored as JSON array (of string paths or URLs).
- This server is intentionally minimal — consider adding input validation and authentication for production.
Feedback Server
================

This is a minimal Dart HTTP server (Shelf) that provides simple REST endpoints for the feedback feature and persists reviews to a MySQL database.

Setup
-----

1. Create `server/config.json` from `server/config_template.json` and fill your MySQL credentials.

2. Ensure the MySQL database exists and create the `reviews` table with the SQL below:

```sql
CREATE TABLE reviews (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  rating INT,
  created_at DATETIME,
  comment TEXT,
  likes INT DEFAULT 0,
  is_liked TINYINT(1) DEFAULT 0,
  media_paths JSON DEFAULT '[]',
  contractor_id VARCHAR(64)
);
```

3. Install dependencies and run the server:

```powershell
cd server
dart pub get
dart run bin/server.dart
```

4. The server listens on port `server_port` from config (default 8080). The Flutter app should point its API base URL to `http://<host>:<server_port>/api/feedback` (default `http://localhost:8080/api/feedback`).

Endpoints
---------
- GET `/api/feedback/reviews` => list reviews
- POST `/api/feedback/reviews` => submit review (body: JSON)
- DELETE `/api/feedback/reviews/{id}` => delete
- PATCH `/api/feedback/reviews/{id}/like` => toggle like
