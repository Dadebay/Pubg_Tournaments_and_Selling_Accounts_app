# Backend task: Privacy Policy & Terms of Use editable from the admin panel

The mobile app (UC Daýy) has two legal pages: **Privacy Policy** and **Terms of Use**
(Ulanyş şertleri). Both pages are empty in the app right now because the admin panel
cannot edit them.

## What is wrong today

| Page | Endpoint | Problem |
|------|----------|---------|
| Privacy Policy | `GET /api/about/privacy/` | The record exists, but `content_tm` and `content_ru` are empty, and there is no place in the admin panel to fill them. |
| Terms of Use | *(none)* | No model, no endpoint, no admin form. The app currently shows the privacy text in its place. |

Current response of `GET /api/about/privacy/`:

```json
{ "id": 1, "title_tm": "", "title_ru": "", "content_tm": "", "content_ru": "" }
```

## What we need

### 1. Admin panel: edit Privacy Policy

Add the existing `privacy` record to the admin panel as a **single editable record**
(no list, no "add new"; the admin only edits the one record).

| Field | Type | Notes |
|-------|------|-------|
| `title_tm` | string | Title, Turkmen (optional) |
| `title_ru` | string | Title, Russian (optional) |
| `content_tm` | rich text (HTML) | Body, Turkmen |
| `content_ru` | rich text (HTML) | Body, Russian |

Use a rich-text editor (headings, bold, lists, links). The app renders HTML,
so HTML in `content_*` is fine.

### 2. New model + admin page: Terms of Use

Create the same kind of single-record model as Privacy Policy:

| Field | Type |
|-------|------|
| `title_tm` | string |
| `title_ru` | string |
| `content_tm` | rich text (HTML) |
| `content_ru` | rich text (HTML) |

### 3. New endpoint

```
GET /api/about/terms/
```

- **Public** (no authentication), exactly like `/api/about/privacy/`.
- Response has the same shape as the privacy endpoint:

```json
{
  "id": 1,
  "title_tm": "Ulanyş şertleri",
  "title_ru": "Условия использования",
  "content_tm": "<h2>1. Umumy düzgünler</h2><p>...</p>",
  "content_ru": "<h2>1. Общие положения</h2><p>...</p>"
}
```

- Return `200` with empty strings if the admin has not filled it yet (not `404`).
- Keep the response a single object (not a list).

## How the app reads it

- Language: the app shows `content_ru` when the user's language is Russian, otherwise
  `content_tm`. If the chosen language is empty it shows nothing for that page, so
  **please fill both languages**.
- Privacy Policy → `GET /api/about/privacy/`
- Terms of Use → `GET /api/about/terms/`
  (until this endpoint exists, the app falls back to the privacy text)
- The text is rendered as HTML, white-on-dark. Avoid inline colors / fixed widths.

## Done when

- [ ] Admin can edit Privacy Policy (TM + RU) in the admin panel
- [ ] Admin can edit Terms of Use (TM + RU) in the admin panel
- [ ] `GET /api/about/privacy/` returns the filled text
- [ ] `GET /api/about/terms/` exists and returns the filled text
