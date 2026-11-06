# Backend: banners that open a page, a tournament or start a phone call

## Goal

Today a tap on a banner (`GET /api/banners/`) can only open a web link (`url`), or the
banner's own text page. The client wants a banner tap to be able to:

- open a **specific tournament** or **lobby**,
- open an app page: **orders**, **About us**, **UC (wallet)**, Premium, Lucky wheel, Support chat, ...
- **call a phone number** (the phone's dialer opens with the number filled in).

The app side is already done. The backend needs two things: new fields on the banner model
(and in the admin panel), and to send them in the API.

## 1. New fields on the Banner model

| Field       | Type              | Required | Description |
|-------------|-------------------|----------|-------------|
| `action`    | string (choices)  | No       | What a tap does. Default `none`. See the table below. |
| `target_id` | integer, nullable | Only for `tournament` / `lobby` | Id of the tournament or lobby to open. |
| `phone`     | string            | Only for `phone` | Phone number to call, e.g. `+99362000000`. |

The existing `url` field stays as it is (used for `action = url` and as before).

### `action` values

| `action`      | What the app opens | Extra field |
|---------------|--------------------|-------------|
| `none`        | Default. If `url` is a web link it opens in the browser, otherwise the banner's own text page. | – |
| `url`         | The web link from `url`. | `url` |
| `tournament`  | The tournament page. | `target_id` = tournament id |
| `lobby`       | The lobby page. | `target_id` = lobby id |
| `tournaments` | The Tournaments list. | – |
| `lobbies`     | The Lobbies list. | – |
| `uc`          | The UC / wallet page (same as `wallet`). | – |
| `wallet`      | The wallet page. | – |
| `orders`      | The user's orders page. | – |
| `about`       | The About us page. | – |
| `premium`     | The Premium page. | – |
| `lucky`       | The Lucky wheel (Cashback) page. | – |
| `support`     | The support chat. | – |
| `phone`       | Starts a phone call to `phone`. | `phone` |

Unknown values are ignored by the app (it falls back to the `none` behaviour), so new actions can be added later without breaking old app versions.

## 2. API

`GET /api/banners/` must return the new fields on every banner:

```json
[
  {
    "id": 1,
    "title": "New tournament",
    "content": "",
    "image": "https://example.com/media/banners/t.jpg",
    "url": "",
    "action": "tournament",
    "target_id": 12,
    "phone": ""
  },
  {
    "id": 2,
    "title": "Call us",
    "content": "",
    "image": "https://example.com/media/banners/call.jpg",
    "url": "",
    "action": "phone",
    "target_id": null,
    "phone": "+99362000000"
  },
  {
    "id": 3,
    "title": "Your orders",
    "content": "",
    "image": "https://example.com/media/banners/orders.jpg",
    "url": "",
    "action": "orders",
    "target_id": null,
    "phone": ""
  }
]
```

Notes:
- Keep returning `title`, `content`, `image` and `url` exactly as now (`title_tm` / `title_ru` etc. also still work).
- `target_id` and `phone` may be `null` or empty when not used.
- Please add the new fields to the Swagger / OpenAPI schema of the banner.

## 3. Admin panel

On the banner form:

1. A dropdown **"On tap"** (`action`) with the values above (labels in plain words, e.g. "Open tournament", "Open orders", "Call a phone number").
2. A field **"Tournament / lobby"** (`target_id`) shown only for `tournament` and `lobby`. Best as a dropdown of existing tournaments/lobbies, otherwise a plain number input.
3. A field **"Phone number"** (`phone`) shown only for `phone`.
4. The existing **URL** field shown for `url`.

Validation:
- `tournament` / `lobby` → `target_id` is required and must exist (and be of the right kind: a tournament id for `tournament`, a lobby id for `lobby`).
- `phone` → `phone` is required (digits, `+`, spaces and `-` allowed).
- `url` → `url` is required and must start with `http://` or `https://`.

## 4. Quick alternative (no new fields)

If adding fields takes too long, the app also understands special links in the **existing `url` field**.
The admin just types the link as text:

| Link in `url`            | Opens |
|--------------------------|-------|
| `ucdayy://tournament/12` | tournament 12 |
| `ucdayy://lobby/5`       | lobby 5 |
| `ucdayy://tournaments`   | tournaments list |
| `ucdayy://lobbies`       | lobbies list |
| `ucdayy://uc`            | UC / wallet page |
| `ucdayy://orders`        | orders page |
| `ucdayy://about`         | About us page |
| `ucdayy://premium`       | Premium page |
| `ucdayy://lucky`         | Lucky wheel |
| `ucdayy://support`       | support chat |
| `tel:+99362000000`       | phone call |
| `https://...`            | web page in the browser |

This needs **no backend change** at all, but the admin has to type the links by hand,
so the proper fields in sections 1–3 are the recommended solution.

## 5. How to test

1. In the admin panel create a banner with `action = tournament` and a real `target_id`. Open the app home page and tap the banner: the tournament page must open.
2. Create a banner with `action = phone` and `phone = +99362000000`: the phone dialer must open with the number filled in.
3. Create banners with `orders`, `about`, `uc`: the matching page must open.
4. A banner with `action = none` and no URL must still open its own text page.
5. A banner with a deleted tournament in `target_id`: the app shows an error message and does not crash.

## Done when

- [ ] `action`, `target_id` and `phone` exist on the banner model and are in `GET /api/banners/`
- [ ] They can be edited in the admin panel with the validation above
- [ ] The fields are in the Swagger schema
