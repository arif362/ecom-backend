### Get order payment collection report for finance.
___
* **URL :** `BASE_URL + finance/api/v1/payment_reports/report`
* **Method :** `GET`
* **Headers :** `Auth_token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
[
  {
    "order_id":6098,
    "fc_id":8,
    "rider_id":null,
    "route_id":106,
    "partner_id":151,
    "shipping_type":"pick_up_point",
    "payment_type":"cash_on_delivery",
    "amount":"4000.0",
    "order_date":"2022-12-12T16:30:27.600+06:00",
    "completed_at":"2022-12-12T00:00:00.000+06:00",
    "rider_collected_at":"",
    "sr_collected_at":"2022-12-12T16:36:35.606+06:00",
    "reconciliation_at":"2022-12-12T16:36:57.935+06:00",
    "deposited_at":"2022-12-12T16:37:32.296+06:00",
    "received_at":"2022-12-25T14:31:38.377+06:00"
  },
  {
    "order_id":6097,
    "fc_id":8,
    "rider_id":null,
    "route_id":106,
    "partner_id":151,
    "shipping_type":"pick_up_point",
    "payment_type":"nagad_payment",
    "amount":"4000.0",
    "order_date":"2022-12-12T16:09:36.977+06:00",
    "completed_at":"2022-12-12T16:18:09.739+06:00",
    "rider_collected_at":"",
    "sr_collected_at":"2022-12-12T16:18:41.237+06:00",
    "reconciliation_at":"2022-12-12T16:19:02.286+06:00",
    "deposited_at":"2022-12-12T16:37:32.292+06:00",
    "received_at":"2022-12-25T14:31:38.377+06:00"
  }]
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "Unable to fetch payment collection report",
  "status_code": 422
}
```


