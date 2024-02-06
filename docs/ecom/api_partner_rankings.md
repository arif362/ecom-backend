### get date filter options
___

* **URL :** `BASE_URL + /shop/api/v1/partner_ranking/date_options`
* **Method :** `GET`
* * **Header :** `Auth Token`
* **URL Params :**

```json
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "message": "Successfully fetched date options",
  "status_code": 200,
  "data": [
    {
      "key": "mega",
      "value": "Mega"
    },
    {
      "key": "week1",
      "value": "Week - 01 (17 October - 23 October)"
    },
    {
      "key": "week2",
      "value": "Week - 02 (24 October - 30 October)"
    },
    {
      "key": "week3",
      "value": "Week - 03 (31 October - 06 November)"
    },
    {
      "key": "week4",
      "value": "Week - 04 (07 November - 14 November)"
    }
  ]
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch date options",
   "data": {}
}
```
### Fetch partner list for ranking
___

* **URL :** `BASE_URL + /shop/api/v1/partner_ranking/list`
* **Method :** `GET`
* **URL Params :**

```json
{
  "district_id": 2
}
```
* **Success Response**
 * **Code :**`200`
 * **Content :**
```json
{
  "message": "Successfully fetched partner list",
  "status_code": 200,
  "data": [
    {
      "ranking": 1,
      "outlet_name": "Noakhali Maijdee",
      "partner_code": null,
      "order_placed_num": 0,
      "order_completed_num": 0,
      "total_point": 0,
      "eligible_for_mega": "No",
      "slug": "noakhali-maijdee"
    }
  ]
}
```
* **Error Response**
 * **Code :**`422`
 * **Content :**
```json
{
   "success": false,
   "status": 422,
   "message": "Unable to fetch partner list",
   "data": {}
}
```
