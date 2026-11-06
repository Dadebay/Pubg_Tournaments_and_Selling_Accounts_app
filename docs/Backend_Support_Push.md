# Backend: FCM push for support chat replies

When an admin writes in the support chat and the player is **not** on the chat screen,
the player must get a push notification. Tapping it opens the chat.

## How the app works (already implemented)

After login the app subscribes the device to the FCM topic:

```
support_<user id>
```

`<user id>` is the `user` field of `GET /api/accounts/get-my-account/`
(falls back to `id` if `user` is missing). On logout the app unsubscribes.

> **Please confirm:** the topic must use the same id the app uses. If the backend
> sends to `support_<profile id>` instead of `support_<user id>` (or the other way
> round), tell us and we switch the app.

## What the backend must send

Send one FCM message **to the topic** `support_<user id>` for every admin reply.
Use a message with both `notification` and `data`:

```json
{
  "message": {
    "topic": "support_7",
    "notification": {
      "title": "Goldaw",
      "body": "<first ~100 characters of the admin message, or \"📷 Surat\" for an image>"
    },
    "data": {
      "type": "support",
      "chat_id": "1"
    },
    "android": {
      "priority": "HIGH",
      "notification": { "sound": "default" }
    },
    "apns": {
      "payload": { "aps": { "sound": "default" } }
    }
  }
}
```

Notes:
- `data.type` must be exactly `"support"` (the app also recognises the topic name, but
  please send the field).
- All `data` values must be strings (FCM requirement).
- Send **only for admin messages**, not for the player's own messages.
- Do not send for messages in a chat the player has just read (optional).
- Title/body language: use the player's language if you store it, otherwise Turkmen.

## How the app reacts

| App state | What happens |
|-----------|--------------|
| Chat screen open | No notification; the open chat shows the reply and plays a sound. |
| App open, other screen | A local notification is shown and the chat icon badge refreshes. |
| App in background | The system shows the notification; tapping it opens the chat. |
| App closed | Same; tapping starts the app and opens the chat. |

## Related

- `GET /api/support/unread/` returns `{ "unread": N }`; the app reads `unread` for the badges.
- iOS: FCM needs the APNs key uploaded in the Firebase console, otherwise iOS devices get no push.

## How to test

1. Log in on the phone and open the app once (this subscribes it).
2. In the Firebase console → Cloud Messaging → send a test message to the topic
   `support_<user id>` with data `type = support`.
3. Put the app in the background, send it, tap the notification: the chat must open.
