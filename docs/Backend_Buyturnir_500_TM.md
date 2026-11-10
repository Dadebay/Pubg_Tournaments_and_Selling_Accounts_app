# Backend ýalňyşlygy: `POST /api/turnirs/buyturnir/{id}/` → 500 (TypeError)

**Gysgaça netije:** Ýalňyşlyk **serwerde (backend kodunda)**. Programma tarapy adaty, dogry formatly sorag iberýär.
Serwer bu soraga **HTTP 500** bilen jogap berýär we Python kody `TypeError` ýalňyşlygyna düşýär.

---

## 1. Näme bolýar

Oýunçy turnire topar (team) bilen ýazylanda programma şu soragy iberýär:

```
POST http://ucdayy.com.tm:8080/api/turnirs/buyturnir/801/
Authorization: Bearer <access token>
Content-Type: multipart/form-data

name        = <toparyň ady>
extra_name  = <goşmaça at>
user_1      = <1-nji oýunçynyň PUBG ID / ady>
user_2      = <2-nji oýunçy>
user_3      = <3-nji oýunçy>
```

- `801` — turniriň id-si.
- Ähli meýdan (field) setir (string) görnüşinde iberilýär.

## 2. Serwer näme jogap berýär

```
HTTP 500 Internal Server Error
Content-Type: text/html

<title>TypeError at /api/turnirs/buyturnir/801/</title>
... Django-nyň DEBUG sahypasy ...
```

Programmanyň ekranynda görünen ýazgy şudur: **`TypeError at /api/turnirs/buyturnir/801/`**.

## 3. Näme üçin ýalňyşlyk backend-de

| Delil | Düşündiriş |
|-------|------------|
| Jogap **500** | 500 = serwer ýalňyşlygy. Programma tarapyndaky ýalňyşlyk ýa-da nädogry sorag 4xx (400/403/404) bolmaly. |
| Jogabyň başynda `TypeError at /api/turnirs/buyturnir/801/` | Bu Python-yň ýalňyşlygy: bir amal nädogry görnüşli (tip) maglumat bilen ýerine ýetirilýär. Ýagny **view-iň kody** ýykylýar. |
| Jogap HTML (Django DEBUG sahypasy) | Serwer `DEBUG = True` bilen işleýär. Programma JSON garaşýar, ýöne exception geldi. |

Programma tarapy bu soraga **hiç hili hasaplama etmeýär**, diňe forma maglumatyny iberýär. Şonuň üçin `TypeError` programmada däl, `buyturnir` view-iň içinde bolýar.

## 4. Anyk setiri tapmak üçin (hökman gerek)

Men (programma tarapy) **anyk setiri görmeýärin**, sebäbi ekranda diňe `<title>` görünýär. Anyk sebäp **Traceback**-de ýazylan:

1. Şol 500 jogabyň HTML-ini açyň: içinde **"Traceback (most recent call last)"** bölegi bar, ol faýl adyny we setir belgisini görkezýär.
   Ýa-da serwer logunda (`gunicorn`/`uwsgi`/`runserver` çykyşy) `TypeError` setirini tapyň.
2. Aşakdaky soragy özüňiz (curl bilen) iberiň, şonda traceback-i göreris:

```bash
curl -i -X POST http://ucdayy.com.tm:8080/api/turnirs/buyturnir/801/ \
  -H "Authorization: Bearer <TOKEN>" \
  -F "name=Test" -F "extra_name=T1" \
  -F "user_1=111111" -F "user_2=222222" -F "user_3=333333"
```

## 5. Nämä seretmeli (ähtimal sebäpler)

`TypeError` adatça şu ýagdaýlarda bolýar. Şulary view-de barlaň:

- `None` bilen san ýa-da setir goşmak / köpeltmek (mysal: bahasy, limit, balans `None`).
- `int` bilen `str` goşmak ýa-da deňeşdirmek (mysal: `user_1` setir, ýöne san hökmünde ulanylýar).
- Bar bolmadyk (ýa-da `None`) ulanyjyny tapyp, onuň atrybutyna ýüz tutmak (`user_1`, `user_2`, `user_3` boýunça gözleg).
- Turnir id=`801` üçin käbir meýdan (baha, topar sany, limit) `None` ýa-da ýalňyş tipde.
- `request.data` / `request.POST` ýerine ýalňyş obýekt ulanmak (multipart bilen JSON-yň tapawudy).
- Çagyrylyp bolmaýan zady çagyrmak (`'str' object is not callable`) ýa-da `None[...]`.

## 6. Talap edilýän düzedişler

1. `buyturnir` view-däki `TypeError`-y düzetmek (ýokardaky traceback boýunça).
2. **Adaty ýalňyşlyklar üçin 500 däl, 400 + JSON** gaýtarmak:
   ```json
   { "error": "user_2 tapylmady" }
   ```
   Programma `error` meýdanyny ulanyja görkezýär.
3. Önümçilik (production) serwerinde **`DEBUG = False`** bolmaly. Häzir ulanyjylara kodyň içki maglumatlary (faýl ýollary, sazlamalar) iberilýär, bu howpsuzlyk meselesi.

## 7. Barlag

- [ ] Ýokardaky `curl` soragy 200/201 gaýtarýar ýa-da düşnükli `400` + `error` berýär (500 däl).
- [ ] Turnire topar bilen ýazylyp bolýar, soňra topar agzalary sahypasynda görünýär.
- [ ] Ýalňyş maglumat (boş `user_1`, bar bolmadyk ulanyjy) 500 däl, 400 berýär.
