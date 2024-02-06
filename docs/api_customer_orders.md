**Customer Oders**
----
####BASE_URL = "http://api-v2.shopoth.shop/"


### Create Order with Cart Items:

* **URL**: ``BASE_URL + /shop/api/v1/customer_orders``

* **Method:** `POST`
*  **Headers:** User auth`


  * **URL Params:**
  * params do
    * requires :cart_id, type: Integer
    * requires :shipping_type, type: String
    * optional :full_name, type: String
    * optional :phone, type: String
    * optional :new_address, type: Hash do
      * requires :district_id, type: Integer
      * requires :thana_id, type: Integer
      * requires :area_id, type: Integer
      * requires :full_name, type: String
      * requires :phone, type: String
      * requires :home_address, type: String
      * optional :alternative_phone, type: String
      * optional :post_code, type: Integer
      * optional :title, type: String, default: 'others'
      * optional :remember, type: Boolean
    * end
    * optional :partner_id, type: Integer
    * optional :rider_id, type: Integer
    * optional :billing_address_id, type: Integer
    * optional :shipping_address_id, type: Integer
    * requires :form_of_payment, type: String
    * optional :domain, type: String
    * optional :customer_device_id, type: Integer
    * optional :tenure, type: Integer
  * end

* **Success Response:**
* **Code:** `201`
    * **Content:**

```json
 {
  "success": true,
  "status": 200,
  "message": "Successfully created customer order.",
  "data": {
    "id": 3292,
    "number": null,
    "item_count": 1,
    "special_instruction": null,
    "pay_type": "cash_on_delivery",
    "cart_total_price": "191.0",
    "for_whom": null,
    "completed_at": null,
    "coupon_code": null,
    "created_at": "2021-09-26T10:32:34.314+06:00",
    "updated_at": "2021-09-26T10:32:34.314+06:00",
    "customer_type": true,
    "customer_id": 26,
    "total_discount_amount": "0.0",
    "total_price": "191.0",
    "billing_address_id": null,
    "shipping_address_id": null,
    "partner_id": 115,
    "shipping_type": "pick_up_point",
    "warehouse_id": 8,
    "shipping_charge": "0.0",
    "order_type": "organic",
    "order_status_id": 1,
    "pay_status": "non_extended",
    "rider_id": null,
    "name": "Gazi Salahuddin",
    "phone": "01967579580",
    "pin": "4680",
    "cancellation_reason": null,
    "partner_commission": "0.0",
    "preferred_delivery_date": null,
    "is_customer_paid": false,
    "next_shipping_type": null,
    "next_partner_id": null,
    "holding_fee": "0.0",
    "promotion_id": null,
    "customer_orderable_id": 26,
    "customer_orderable_type": "User",
    "return_coupon": false
  }
}
```
* ** Error Response:**
* **Code:** `422`
* ** If Cart value less than 180tk
  * **Content:**
```json
{
    "message": "Cart value must be greater or equal to 180tk",
    "status_code": 422
}
```

* ** Error Response:**
* **Code:** `404`
* ** If any product count is zero in cart
  * **Content:**
```json
{
    "message": "Please provide valid quantity",
    "status_code": 404
}
```
* ** Error Response:**
* **Code:** `404`
* ** If products are unavailable
  	* **Content:**
```json
{
    "message": "**{product1, product2, ..}** are stock out!",
    "status_code": 422
}
```
* ** Error Response:**
* **Code:** `404`
* ** If any other error occurs
  	* **Content:**
```json
{
    "message": "**{error reason}**",
    "status_code": 422
}
```
