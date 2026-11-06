# Backend issue: Support Chat endpoints return 404

## Problem

The mobile app cannot open the support chat. The very first request fails with a 404:

```
POST http://ucdayy.com.tm:8080/api/support/chats/
Authorization: Bearer <valid access token>
Body: {}

404 Not Found
<pre>Cannot POST /api/support/chats/</pre>
```

"Cannot POST ..." is the server's default "route not found" page. The request reaches the
server with a valid token, so this is **not** an authentication problem: the route
`/api/support/chats/` is not registered (or not deployed) on the `:8080` server.

Because this first call fails, the chat screen shows an error and never loads.

## What we already checked

| Request | Result |
|---------|--------|
| `POST /api/support/chats/` (with token) | `404 Cannot POST` |
| `GET /api/support/chats` (no token) | `404` |
| `GET /api/support/unread/` (no token) | `401` (route exists) |

So `support/unread/` seems to exist, but `support/chats/` does not.

## What is needed

Please make sure all Support Chat endpoints from the Mobile API README are live on
`http://ucdayy.com.tm:8080`. All of them require the `Authorization: Bearer <token>` header.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/api/support/chats/` | Create the user's chat, or return the existing one. No body. |
| `GET` | `/api/support/chats/{id}/` | Get one chat. |
| `GET` | `/api/support/chats/{id}/messages/` | Messages. Supports `?before=<id>` and `?after=<id>`. |
| `POST` | `/api/support/chats/{id}/messages/` | Send a message: JSON `{"body": "..."}` or multipart (`body`, `image`, max 10 MB). |
| `POST` | `/api/support/chats/{id}/read/` | Mark the chat as read by the user. |
| `GET` | `/api/support/unread/` | Unread counts for the badge: `{ "chats", "messages", "last_id" }`. |

Admin replies are written from the web admin panel and must show up in
`GET .../messages/` with `"sender": "admin"` and `"admin": "<agent name>"`.

## How to verify

```bash
curl -i -X POST \
  -H "Authorization: Bearer <access_token>" \
  http://ucdayy.com.tm:8080/api/support/chats/
```

Expected: `200 OK` or `201 Created` with a body like:

```json
{ "id": 3, "status": "open", "unread": 0, "created_date": "2026-11-06T08:00:00Z" }
```

Then:

```bash
curl -i -H "Authorization: Bearer <access_token>" \
  http://ucdayy.com.tm:8080/api/support/chats/3/messages/
```

Expected: `200 OK` with `{ "messages": [], "has_more": false, "user_read_id": 0, "status": "open" }`.

## Question for backend

If the support chat lives on a different host or port than `:8080`, please tell us the
correct base URL. It is a one-line change in the app.

## Done when

- [ ] `POST /api/support/chats/` returns 200/201 with a chat object
- [ ] Messages can be listed and sent (text and image)
- [ ] An admin reply written in the admin panel appears in the app within ~3 seconds
- [ ] Closing the chat in the admin panel returns `"status": "closed"`
