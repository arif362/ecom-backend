### Get all thana based on district_id
___
* **URL :** `BASE_URL + customer_care/api/v1/thanas/search`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "district_id": 1
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id":4,
    "district_id":1,
    "name":"Abhaynagar",
    "bn_name":"অভয়নগর",
    "is_deleted":false,
    "created_at":"2021-01-14T13:09:43.563+06:00",
    "updated_at":"2022-08-02T14:47:10.045+06:00",
    "home_delivery":false,
    "distributor_id":1
  },
  {
    "id":20,
    "district_id":1,
    "name":"Banani",
    "bn_name":"Banani",
    "is_deleted":false,
    "created_at":"2021-11-17T11:37:38.611+06:00",
    "updated_at":"2021-11-17T11:37:38.611+06:00",
    "home_delivery":null,
    "distributor_id":1
  }
]
```
