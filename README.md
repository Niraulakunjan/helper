## How to Run the House Helper App

### Backend (Django)

```bash
cd /Users/kunjan/helper/backend
python3 manage.py createsuperuser   # create admin user
python3 manage.py runserver
```

Server runs at: http://127.0.0.1:8000
Admin panel:    http://127.0.0.1:8000/admin/

Seed some services first via the admin panel (e.g., Cleaning, Electrician, Plumber).

---

### Flutter App

```bash
export PATH="$PATH:/Users/kunjan/helper/flutter/bin"
cd /Users/kunjan/helper/frontend
flutter devices                     # list connected devices/simulators
flutter run                         # run on a connected device or emulator
```

> If using iOS Simulator, open it first via Xcode or `open -a Simulator`
> If using Android Emulator, start it from Android Studio

---

### WebSocket Test (from browser)
Connect to:
```
ws://127.0.0.1:8000/ws/chat/<user_id>/<helper_id>/
```
Send JSON:
```json
{"message": "Hello!", "sender_id": 1, "receiver_id": 2}
```
# helper
