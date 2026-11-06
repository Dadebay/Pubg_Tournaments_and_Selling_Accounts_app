# Backend: Lucky wheel stops on the wrong slice and the spin response is unclear

## Problem

The wheel animates to the slice given by `prize_index` in the spin response, but that slice
is often **not** the prize the player was paid. The player sees the wheel stop on **1000 TMT**
and thinks they won 1000 TMT, while the server actually paid only **1 point**.

### Real request / response (player with cashback 1 → 0)

```
POST /api/games/lucky/spin/        body: {}
200 OK
{
  "won": false,
  "spin_number": 2,
  "points": 1,                      <- what was paid
  "prize": { "id": 8, "label": "1", "points": 1 },
  "prize_index": 7,                 <- the wheel is told to stop on slice #7 (= "1000")
  "cashback": 0,
  "points_balance": 388             <- was 387, so exactly +1 was paid
}
```

The prize list (`GET /api/games/lucky/`) is:

| index | id | label | points |
|-------|----|-------|--------|
| 0 | 1 | 1    | 1    |
| 1 | 2 | 5    | 5    |
| 2 | 3 | 10   | 10   |
| 3 | 4 | 25   | 25   |
| 4 | 5 | 50   | 50   |
| 5 | 6 | 100  | 100  |
| 6 | 7 | 500  | 500  |
| 7 | 8 | 1000 | 1000 |

So `prize_index: 7` points to the **1000** slice, but `points` is `1`. The response is
inconsistent:

- `prize_index` = 7 → slice "1000"
- `prize.id` = 8 → slice "1000" (id 8 is the 1000 slice), but `prize.label` = "1" and `prize.points` = 1.

## What the app does now

The app shows the dialog from `points` (what was really paid), so the player is told
"You won 1 TMT". That is correct, but the **wheel still stops on 1000**, which looks like a lie.

## What we need (please fix)

1. **The wheel must stop on the slice that matches the payout.**
   If the player is paid 1 point, `prize_index` must be the index of a slice whose
   `points` is `1` (index 0 in the list above). If there are several slices with the
   same payout, any of them is fine.
2. **`prize` must describe that same slice.** `prize.id`, `prize.label`, `prize.points` and
   `prize_index` must all refer to one slice, and `prize.points` must equal `points`.
3. **Keep `points_balance` as the new balance** (this already works).
4. **`prize.label` should match the label of the slice** in `GET /api/games/lucky/`
   (e.g. `"1"` for the 1 slice, `"1000"` for the 1000 slice).

### Expected response for the example above

```json
{
  "won": false,
  "spin_number": 2,
  "points": 1,
  "prize": { "id": 1, "label": "1", "points": 1 },
  "prize_index": 0,
  "cashback": 0,
  "points_balance": 388
}
```

## Question about `won`

Every slice pays at least 1 point, so for the player any payout is money. The app now treats
`points > 0` as a win. Please confirm:

- `won: true` is only for the "big" winning slices tied to `spin_no`, and
- consolation payouts (1 point) are `won: false` with `points: 1`.

If that is right, no change is needed for `won`.

## Other points to confirm

- **Spin URL.** The app calls `POST /api/games/lucky/spin/` (no game id in the path, because
  `GET /api/games/lucky/` returns one `game` object without an `id`). This works now.
  Please keep it, or tell us if it changes.
- **Cashback after the spin.** The spin response has `cashback` (remaining). It is correct, please keep it.
- **`spin_price` is `0`** in the game response while the app shows a "Buy spin" button with
  the price. If buying spins is not available yet, return `spin_price: null` and the app will hide the button.
- **Prize labels.** `label` is only a number (`"1000"`). The app adds " TMT". If a slice should
  show other text (for example "5000 UC"), send the full text in `label`.

## How to verify

1. Spin several times with a test user.
2. For each response check: `prize_index` slice in `GET /api/games/lucky/` has `points == points`
   of the response, and `points_balance` increased by exactly `points`.
3. In the app the wheel must stop on the slice that shows the same amount as the result dialog.
