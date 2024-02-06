### Partner list
___

* **URL :** `BASE_URL + /api/v1/partners`
* **Method :** `GET`
* **Header :** `Auth-token`
* **URL Params :**

```json
{
  "status": "delivered_to_partner",
  "start_date_time": "2022-11-29",
  "end_date_time": "2022-12-28"
}
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "id": 178,
    "name": "Honda Seller Storeeee",
    "outlet_name": "Honda Seller Storeeee",
    "route": 106,
    "distributor_name": "Narsingdi Distributor",
    "phone": "0162xxxxxxx",
    "partner_code": "geyueryuryuyeryure",
    "returns": 0,
    "total_orders": 0,
    "total_amount": 0,
    "collected": "0.0",
    "due_payment": "0.0",
    "region_name": ""
  },
  {
    "id": 161,
    "name": "Tahosib ",
    "outlet_name": "Tahosib ",
    "route": 132,
    "distributor_name": "Khulna Distributor",
    "phone": "0171xxxxxxx",
    "partner_code": "03",
    "returns": 0,
    "total_orders": 0,
    "total_amount": 0,
    "collected": "0.0",
    "due_payment": "0.0",
    "region_name": ""
  }
]
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "status_code": 422,
  "message": "Unable to find partner due to #{error}"
}
```
### Partner Details
___

* **URL :** `BASE_URL + /api/v1/partners/:id`
* **Method :** `GET`
* **Header :** `Auth-token`
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
  "message": "Successfully fetched partner details.",
  "data": {
    "id": 174,
    "route": {
      "id": 106,
      "title": "IT-N-303",
      "bn_title": "IT-N-303",
      "phone": "0174xxxxxxx",
      "warehouse_id": 8,
      "created_at": "2021-06-30T12:28:07.664+06:00",
      "updated_at": "2022-12-13T10:32:46.941+06:00",
      "cash_amount": "122183.0",
      "digital_amount": "0.0",
      "sr_point": "Nandail",
      "sr_name": "SR-303",
      "distributor_id": 1,
      "bkash_number": "01517816145",
      "created_by_id": null
    },
    "name": "Hazi Afaj Store",
    "phone": "0172xxxxxxx",
    "image": null,
    "email": "admin111@shopoth.com",
    "password_presence": true,
    "status": "active",
    "schedule": "sat_sun_mon_tues_wed_thurs",
    "tsa_id": null,
    "retailer_code": null,
    "partner_code": "S11P0373",
    "region": null,
    "area": null,
    "territory": null,
    "point": null,
    "owner_name": null,
    "cluster_name": null,
    "sub_channel": null,
    "bn_name": "হাজী আফাজ স্টোর",
    "latitude": null,
    "longitude": null,
    "work_days": [
      {
        "is_opened": false
      },
      {
        "is_opened": true,
        "opening_time": "00:00",
        "closing_time": "00:36"
      },
      {
        "is_opened": true,
        "opening_time": "00:00",
        "closing_time": "00:36"
      },
      {
        "is_opened": true,
        "opening_time": "00:00",
        "closing_time": "00:36"
      },
      {
        "is_opened": true,
        "opening_time": "00:00",
        "closing_time": "00:36"
      },
      {
        "is_opened": true,
        "opening_time": "00:00",
        "closing_time": "00:36"
      },
      {
        "is_opened": true,
        "opening_time": "00:01",
        "closing_time": "00:36"
      }
    ],
    "slug": "hazi-afaj-store",
    "is_commission_applicable": true,
    "bkash_number": null,
    "due_payment": 0,
    "addresses": {
      "id": 3094,
      "area_id": 14,
      "area_name": "Bogra",
      "thana_id": 4,
      "thana_name": "Abhaynagar",
      "district_id": 1,
      "district_name": "Narshingdi",
      "name": "Hazi Afaj Store",
      "address_line": "agami",
      "bn_address_line": null,
      "phone": "0172xxxxxxx",
      "post_code": null
    },
    "meta_info": null,
    "distributor_name": "Narsingdi Distributor",
    "created_by": {
      "id": 7,
      "name": "Sajjad Narshingdi Admin"
    },
    "business_type": "b2c"
  }
}
```
* **Error Response**
* **Code :**`404`
* **Content :**
```json
{
  "success": false,
  "status": 404,
  "message": "Unable to find partner.",
  "data": {}
}
```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch details of a partner.",
  "data": {}
}
```
