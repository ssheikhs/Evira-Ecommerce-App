# Evira Order API (mock server)

A tiny local REST API built with [json-server](https://github.com/typicode/json-server).
The app saves placed orders here and reads a user's order history from it.

## Run it

```bash
cd mock_server
npm install
npm start
```

The API runs on **http://localhost:3001**.

| Method | Endpoint             | Used for               |
| ------ | -------------------- | ---------------------- |
| POST   | `/orders`            | Save a new order       |
| GET    | `/orders?userId=1`   | A user's order history |

## Connecting from the app

| Where the app runs   | Order API URL                                  |
| -------------------- | ---------------------------------------------- |
| Android emulator     | `http://10.0.2.2:3001` (default)               |
| iOS simulator        | `http://localhost:3001` (default)              |
| Real phone on Wi-Fi  | `flutter run --dart-define=ORDER_API_URL=http://<your-PC-IP>:3001` |

If the server is not running, the app still works: orders are also saved on
the device and history falls back to that copy.

> `db.json` changes every time an order is placed. Reset it to
> `{ "orders": [] }` before committing if you do not want test orders in Git.
