### Customer Order Place
___
* **URL :** `BASE_URL + /partner/api/v1/payment/nagad/complete`
* **Method :** `POST`
* **URL Params :**

```json
{
  "order_id": 123,
  "ip_address": "123.34.65.4"
}

```
* **Success Response**
* **Code :**`200`
* **Content :**
```json
{
    "success": true,
    "status": 200,
    "message": "Successfully completed payment .",
    "data": {
      "redirect_url": "http://sandbox.mynagad.com:10060/check-out/MTIwNzEyMjIxNzM1NS42ODMwMDIwMDcxMDQyMjUuMDAwNTQ3OC40YzBiZGJlMTdhNzJmODk0N2U4Yg=="
    }
}
 ```
* **Error Response**
* **Code :**`422`
* **Content :**
```json
```


