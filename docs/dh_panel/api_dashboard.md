### Dashboard

----
* **URL :** `BASE_URL + /distributors/api/v1/dashboard`
* **Method :** `GET`

* **URL Params :**

```json
{
  "start_date_time": "2022-01-01",
  "end_date_time": "2022-07-01"
}
```

* **Success Response**
* **Code :**`200`
* **Content :**

```json
{
  "success": true,
  "status": 200,
  "message": "Successfully fetched dashboard details.",
  "data": {
    "total_completed_order": 98,
    "total_completed_order_value": 45608,
    "collectable_cash_from_market": 5067,
    "cash_collected_by_sr": 43002,
    "cash_deposit_to_shopoth": 145321,
    "dist_margin": 125337,
    "partner_margin": 91552,
    "campaign_names": [
      "Eid sale",
      "Pohela boishakh"
    ]
  }
}
```

* **Error Response**
* **Code :**`422`
* **Content :**

```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch dashboard details.",
  "data": {}
}
```
### Dashboard Order summary

----
* **URL :** `BASE_URL + /distributors/api/v1/dashboard/order_summary`
* **Method :** `GET`

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
  "message": "Successfully fetched order summary.",
  "data": {
    "order_processing_at_cwh": 123,
    "return_request": 40,
    "return_collectable_by_sr": 921,
    "in_transit_to_dh": 762,
    "delivery_pending": 542,
    "in_transit_orders_count": 98,
    "in_transit_orders": [
      {
        "order_id": 29756,
        "status": "Completed",
        "status_type": "completed",
        "shipping_type": "pick_up_point",
        "order_type": "induced",
        "price": "740.0",
        "warehouse_name": "Khulna FC",
        "date": "2022-01-09T18:41:09.230+06:00"
      }
    ]
  }
}
```

* **Error Response**
* **Code :**`422`
* **Content :**

```json
{
  "success": false,
  "status": 422,
  "message": "Unable to fetch order summary.",
  "data": {}
}
```
