### Fetch help topics
___

* **URL :** `BASE_URL + /shop/api/v1/help_topics`
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
  "message": "Successfully Fetch",
  "data": [
    {
      "id": 65,
      "title": "Account Deactivation & Deletion Information",
      "slug": "account-deactivation-deletion-information",
      "bn_title": "অ্যাকাউন্ট নিষ্ক্রিয়করণ এবং মুছে ফেলার তথ্য",
      "article_count": 1
    },
    {
      "id": 64,
      "title": "afsgdhjk",
      "slug": "afsgdhjk",
      "bn_title": "ert",
      "article_count": 1
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
   "message": "Failed to fetch",
   "data": {}
}
```
### Fetch help topics by slug
___

* **URL :** `BASE_URL + /shop/api/v1/help_topics/:slug`
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
  "message": "Successfully Fetch",
  "data": [
    {
      "id": 10,
      "title": "about us article",
      "slug": "about-us-article",
      "bn_title": "1.আমাদের সম্পর্কে নিবন্ধ",
      "body": "<p>Paragraphs are the building blocks of papers. Many students define paragraphs in terms of length: a paragraph is a group of at least five sentences, a paragraph is half a page long, etc. In reality, though, the unity and coherence of ideas among sentences is what constitutes a paragraph. A paragraph is defined as “a group of sentences or a single sentence that forms a unit” (Lunsford and Connors 116). Length and appearance do not determine whether a section in a paper is a paragraph. For instance, in some styles of writing, particularly journalistic styles, a paragraph can be just one sentence long. Ultimately, a paragraph is a sentence or group of sentences that support one main idea. In this handout, we will refer to this as the “controlling idea,” because it controls what happens in the rest of the paragraph.</p>",
      "bn_body": "<p>রাজধানীর রামপুরায় গড়ে তোলেন হোমল্যান্ড সিকিউরিটি অ্যান্ড গার্ড সার্ভিস লিমিটেড প্রতিষ্ঠান। সাধারণ মানুষকে প্রতারিত করে জমি-জমা ও ফ্ল্যাট বিক্রি, সরকারি চাকরি দেওয়ার নামে প্রতারণার মাধ্যমে হাতিয়ে নেন বিপুল অর্থ। গড়ে তোলেন সম্পদের পাহাড়। শুধু তাই নয়, প্রতারণার কৌশল হিসেবে গণ্যমান্য ব্যক্তিদের সঙ্গে ছবি তুলে তা বাঁধিয়ে রাখতেন অফিস কার্যালয়ে। নিজেকে কথিত মানবাধিকার সংস্থার প্রতিষ্ঠাতা চেয়ারম্যান হিসেবে পরিচয় দিতেন শাহীরুল। সঙ্গে রাখতেন একাধিক অস্ত্রও। খুব শৈল্পিকভাবে দীর্ঘ ১৯ বছরের প্রতারণা চালিয়ে ঢাকায় গড়ে তোলেন ৫০ কোটি টাকারও বেশি সম্পদ। ঢাকায় দুইটি ফ্ল্যাট, দুইটি বাড়ি, দুইটি বিলাসবহুল গাড়ি ও ২৪ কাঠা জমি রয়েছে এই প্রতারকের।</p>",
      "position": 0,
      "help_topic_id": 8,
      "help_topic_name": "About Us",
      "help_topic_slug": "about-us2"
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
   "message": "Failed to fetch",
   "data": {}
}
```
