# Backend: buying a "For sale" account with the wallet balance (NEW)

## What is new

Until now the account pages (`GET /api/accounts/get-post/{id}/`) were only an ad: the app showed
the account and a "Call" button. The client now wants the player to **buy the account inside the app,
paying from the wallet balance** (the same balance used for UC and tournaments, `points_balance`).

The buy button is already in the app. The backend has no purchase endpoint yet, so it has to be added.

## What the app sends

When the player taps **Buy** on an account page, the app asks for two values (pre-filled from the
player's profile) and then calls one endpoint:

- **Gmail** – the e-mail address the account data (login, password, recovery info) is sent to.
- **PUBG ID** – the buyer's PUBG id.

## Endpoint

```
POST /api/accounts/buy-post/{post_id}/
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "gmail": "player@gmail.com",
  "pubg_id": "5123456789"
}
```

`post_id` is the id of the post, the same id as in `GET /api/accounts/get-post/{id}/`.
The price is **always taken from the post on the server**, never from the app.

### What the server must do (in one database transaction)

1. Check the token (401 if missing/invalid).
2. Load the post by `post_id`. 404 if it does not exist.
3. Check that the post is still for sale (not sold, not hidden/blocked). 409 if it was already sold.
4. Validate `gmail` (valid e-mail) and `pubg_id` (digits, at least 5). 400 with `error` if not.
5. Check that the player's balance is at least the price. 400 with `error` if not enough.
6. **Lock the post row** (`SELECT ... FOR UPDATE`) so two players cannot buy the same account at the same moment.
7. Subtract the price from the player's balance (`points`), write a transaction/history entry.
8. Mark the post as **sold** (hide it from the lists `get-posts`, `get-vip-posts` or return it with a `sold` flag).
9. Create an **order** (see below) so the admin can send the account data to the Gmail and so it
   appears in the player's order history (`My orders`).
10. Return the success answer.

### Success: `200 OK` (or `201`)

```json
{
  "order_id": 128,
  "post_id": 42,
  "price": "3000.00",
  "points_balance": "1200.00",
  "status": "pending"
}
```

The app reads `points_balance` and shows it as the new balance. If the field is missing the app
reloads the balance from `GET /api/accounts/get-my-account/`.

### Errors

| Status | When | Body |
|--------|------|------|
| `400` | Not enough balance, invalid Gmail, invalid PUBG id | `{ "error": "..." }` (the text is shown to the player; use the app language if you can, otherwise Turkmen) |
| `401` | Not signed in | `{ "detail": "..." }` |
| `404` | Post does not exist | `{ "error": "..." }` |
| `409` | Account already sold | `{ "error": "..." }` |

The app shows `error` as is. For 409 the app shows its own "This account is already sold" text.

## Order and admin panel

The account data is delivered **manually by the admin** (or automatically if you already store it):

- Create an **Account order** record: `id`, `user`, `post`, `price`, `gmail`, `pubg_id`, `status`, `created_date`.
- `status`: `pending` (just bought) → `completed` (data sent) or `cancelled` (money returned).
- In the admin panel show these orders with the buyer's Gmail and PUBG id, and a button/action to mark
  `completed` or `cancelled`. **Cancelling must return the price to the buyer's balance.**
- Send a push notification (FCM) to the buyer when the status changes, if possible.
- Please add these orders to the player's order history API (the app's **My orders** page), with a type
  such as `"type": "account"` so the app can show them.

## Notifications for the admin (optional)

Notify the admin (panel badge, Telegram bot or e-mail) when a new account order arrives, because the data
has to be sent to the buyer's Gmail.

## Rules to keep in mind

- **Never trust the app**: the price and the post state come from the database.
- The balance change, the post state change and the order creation must happen **together or not at all** (transaction).
- Protect against double taps: the same player pressing Buy twice must create one order only.
- A player must not be able to buy their own post.
- Keep a log (who, when, which post, price, balance before/after).

## Swagger

Please add the endpoint to the Swagger / OpenAPI docs with the request and the responses above.

## How to test

1. Player with enough balance buys post 42 → 200, balance reduced by the price, post no longer in the lists, order visible in admin.
2. Same player (or another) buys post 42 again → 409.
3. Player with too little balance → 400 with an `error` text, nothing changed.
4. Invalid Gmail (`abc`) or empty PUBG id → 400.
5. Not signed in → 401.
6. Admin cancels the order → the price is back on the buyer's balance.

## Done when

- [ ] `POST /api/accounts/buy-post/{post_id}/` works as above
- [ ] The balance, the post state and the order change in one transaction
- [ ] Admin can see the orders (Gmail, PUBG id) and complete/cancel them (cancel refunds)
- [ ] Orders appear in the player's order history
- [ ] The endpoint is in Swagger
