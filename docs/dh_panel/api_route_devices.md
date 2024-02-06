**Route Device APIs**
----

### Connect to a sr device

* **URL :** `BASE_URL + /distributors/api/v1/route_devices/connect`

* **Method :** `POST`

* **URL Params :**

```json
{
    "route_device": {
        "unique_id": "626396",
        "password_hash": "123456",
        "route_id": 2
    }
}
```
* **Success Response**
    * **Code :**`200`
    * **Content :**
```json
{
  "success": true,
  "status": 200,
  "message": "Successfully connected.",
  "data": {
    "id": 1,
    "route_id": 1,
    "password_hash": "$2a$12$BXyhdFC1BiVcIHwXWs58z.k8ocDTSgq3TfLGrAQjxutxy4ogZ3PQS",
    "unique_id": "626396",
    "device_id": "1",
    "created_at": "2022-07-25T16:06:33.152+06:00",
    "updated_at": "2022-08-07T15:08:34.522+06:00"
  }
}
```
* **Error Response**
    * **Code :**`200`
    * **Content :**
```json
{
    "success": false,
    "status": 422,
    "message": "Unable to connect route device.",
    "data": {}
}
```

### Disconnect a sr device

* **URL :** `BASE_URL + /distributors/api/v1/route_devices/:route_id/disconnect`

* **Method :** `PUT`

* **URL Params :**

```json
```
* **Success Response**
    * **Code :**`200`
    * **Content :**
```json
{
    "success": true,
    "status": 200,
    "message": "Disconnected successfully.",
    "data": {}
}
```
* **Error Response**
    * **Code :**`200`
    * **Content :**
```json
{
    "success": false,
    "status": 422,
    "message": "Unable to disconnect route device.",
    "data": {}
}
```
