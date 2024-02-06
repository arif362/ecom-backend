**create a questionnaire**
----
Create questionnaire

* **URL**: ``BASE_URL + /api/v1/questionnaires``

* **Method: `POST`**

*  **URL Params**
   `{ "question": "is it ok?",
      "bn_title": "smartphone",
      "category_id": 2,    
      "questionnaire_type": "inbound"
   }`
   
**get a new questionnaire**
----

* **URL**: ``BASE_URL + /api/v1/questionnaires``

* **Method:**  `GET`

* **URL Params** `None`

* **Success Response:**

    * **Code:** 200 <br />
      **Content:** `{ id : 12, question: Is it ok?, category_id: 10, type: DhPurchaseOrder }`

**get a questionnaire by category_id and type**
----
* **URL**: ``BASE_URL + /api/v1/questionnaires/list``

* **Method:** `GET`

* **URL Params**
  `{ "category_id": 2,    
     "questionnaire_type": "inbound"
  }`
  
* **Success Response:**

    * **Code:** 200 <br />
      **Content:** `{ id : 12, question: Is it ok?, category_id: 10, type: DhPurchaseOrder }`
      
**create failed_qc**
----
<_This api can create a FailedQc._>

* **URL**: ``BASE_URL + /api/v1/questionnaires/create_failed_qc``

* **Method:** `post`

* **URL Params**

   `variant_id=[integer]`
   `purchase_order_id=[string]`
   
   **Optional**

   `question_list=[Array]`
   `type=[string]`
   `quantity=[integer]`
  
* **Success Response:**

    * **Code:** 201 <br />
      **Content:** `{ id : 12, variant_id: 15, quantity: 10, failable_id: 14 failable_type: DhPurchaseOrder }`
      