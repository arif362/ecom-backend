### Show All Order Status
___
* **URL :** `BASE_URL + customer_care/api/v1/order_statuses`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "order_placed":0,
  "order_confirmed":1,
  "ready_to_shipment":2,
  "in_transit":3,
  "in_transit_partner_switch":4,
  "in_transit_delivery_switch":5,
  "delivered_to_partner":6,
  "completed":7,
  "cancelled":8,"on_hold":9,
  "sold_to_partner":10,
  "in_transit_reschedule":11,
  "in_transit_cancelled":12,
  "packed_cancelled":13,
  "returned_from_customer":14,
  "partially_returned":15,
  "returned_from_partner":16,
  "ready_to_ship_from_fc":17,
  "in_transit_to_dh":18,
  "cancelled_at_in_transit_to_dh":19,
  "cancelled_at_dh":20,
  "cancelled_at_in_transit_to_fc":21
}
 ```

* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "#{error}"
}
```
### Show All Return Order Status
___
* **URL :** `BASE_URL + customer_care/api/v1/return_statuses`
* **Method :** `GET`
* * **Header :** `Auth-token`
* **URL Params :**

```json
```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
  "initiated": 0,
  "in_partner": 1,
  "in_transit": 2,
  "delivered_to_dh": 4,
  "cancelled": 5,
  "qc_pending": 6,
  "relocation_pending": 7,
  "completed": 9,
  "in_transit_to_fc": 10
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
{
  "message": "#{error}"
}
```
