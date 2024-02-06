## **App Notification APIs** ##
----

## ***Remote uniqueness check for customer acquisition.***

* **URL**: `BASE_URL + shop/api/v1/app_notifications
* **Method:** `GET`
* **URL Params:** `None`
```
```
* **Success Response:**

 ```json
 {
  "success": true,
  "status": 200,
  "message": "Notifications fetched successfully",
  "data": [
    {
      "id": 5894,
      "message": "You have earned 50 BDT for successful registration of customer",
      "read": true,
      "created_at": "2022-09-27T18:01:01.830+06:00",
      "title": "Congratulations!",
      "bn_title": "অভিনন্দন!",
      "bn_message": "গ্রাহকের সফল নিবন্ধনের জন্য আপনি  ৫০ টাকা উপার্জন করেছেন"
    },
    {
      "id": 5893,
      "message": "\"M Rahman\" has been successfully registered through your reference",
      "read": true,
      "created_at": "2022-09-27T18:01:01.799+06:00",
      "title": "Successful customer registration",
      "bn_title": "সফল গ্রাহক নিবন্ধন",
      "bn_message": "আপনার রেফারেন্সের মাধ্যমে \"X\" সফলভাবে নিবন্ধিত হয়েছে"
    },
    {
      "id": 5892,
      "message": "\"M Rahman\" has been successfully registered through your reference",
      "read": true,
      "created_at": "2022-09-27T17:52:13.235+06:00",
      "title": "Successful customer registration",
      "bn_title": "সফল গ্রাহক নিবন্ধন",
      "bn_message": "আপনার রেফারেন্সের মাধ্যমে \"X\" সফলভাবে নিবন্ধিত হয়েছে"
    }
  ]
}
```

* **Error Response:**
    * **Code:** `200`
    * **Content:**
      ```json
      {
      "success": false,
      "status": 422,
      "message": "Unable to unable to fetched app notifications due to #{error}.",
      "data": {}
      }
      ```
----
