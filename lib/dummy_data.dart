import 'model/api_data_model.dart';

List<ApiEntry> dummyDataList = [
  ApiEntry(
    title: "Get All Posts",
    endpoint: "https://jsonplaceholder.typicode.com/posts",
    method: "GET",
    requestBody: "{}",
    responseBody: """
{
  "userId": 1,
  "id": 1,
  "title": "Sample Title",
  "body": "Sample body content"
}
""",
  ),

  ApiEntry(
    title: "Create Post",
    endpoint: "https://jsonplaceholder.typicode.com/posts",
    method: "POST",
    requestBody: """
{
  "title": "New Post",
  "body": "Post content",
  "userId": 1
}
""",
    responseBody: """
{
  "id": 101,
  "title": "New Post",
  "body": "Post content",
  "userId": 1
}
""",
  ),

  ApiEntry(
    title: "User Login",
    endpoint: "https://reqres.in/api/login",
    method: "POST",
    requestBody: """
{
  "email": "eve.holt@reqres.in",
  "password": "cityslicka"
}
""",
    responseBody: """
{
  "token": "QpwL5tke4Pnpja7X"
}
""",
  ),

  ApiEntry(
    title: "Get Single User",
    endpoint: "https://reqres.in/api/users/2",
    method: "GET",
    requestBody: "{}",
    responseBody: """
{
  "data": {
    "id": 2,
    "email": "janet.weaver@reqres.in",
    "first_name": "Janet",
    "last_name": "Weaver",
    "avatar": "https://reqres.in/img/faces/2-image.jpg"
  }
}
""",
  ),

  ApiEntry(
    title: "Get All Products",
    endpoint: "https://dummyjson.com/products",
    method: "GET",
    requestBody: "{}",
    responseBody: """
{
  "products": [
    {
      "id": 1,
      "title": "iPhone 9",
      "price": 549
    }
  ]
}
""",
  ),

  ApiEntry(
    title: "Add Product",
    endpoint: "https://dummyjson.com/products/add",
    method: "POST",
    requestBody: """
{
  "title": "New Phone",
  "price": 299
}
""",
    responseBody: """
{
  "id": 101,
  "title": "New Phone",
  "price": 299
}
""",
  ),
];