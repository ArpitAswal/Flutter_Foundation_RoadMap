# 🌐 Networking Architecture in Flutter

> **Module path:** `lib/api_networking/`
>
> Enterprise-grade networking covering HTTP, Dio, GraphQL, Repository Pattern, DTO mapping, Interceptors, Retry, Exception Mapping, and full CRUD.

---

## Table of Contents

1. [Why Networking Exists](#1-why-networking-exists)
2. [Networking Flow — Real App](#2-networking-flow--real-app)
3. [HTTP vs Dio vs GraphQL — Full Comparison](#3-http-vs-dio-vs-graphql--full-comparison)
4. [When to Use What?](#4-when-to-use-what)
5. [Repository Pattern](#5-repository-pattern-very-important)
6. [Full CRUD — Code Examples](#6-full-crud--code-examples)
7. [Production Patterns — Deep Dive](#7-production-patterns--deep-dive)
8. [REST Architecture](#8-rest-architecture)
9. [JSON Serialization](#9-json-serialization)
10. [DTO vs Domain Model](#10-dto-vs-domain-model-advanced)
11. [Dio Internals & Token Refresh](#11-dio-internals--token-refresh-flow-critical)
12. [GraphQL Deep Dive](#12-graphql-deep-dive)
13. [Exception Mapping](#13-exception-mapping-very-important)
14. [Interview Round Q&A](#14-interview-round-qa)

---

## 1. Why Networking Exists

Apps without networking are **local-only**. Real production apps need networking for:

| Use Case | Example |
|---|---|
| Authentication | Login, JWT tokens |
| Cloud sync | Firebase, Supabase |
| Product fetching | E-commerce catalogs |
| Payments | Stripe, Razorpay |
| Chat | Real-time messaging |
| Analytics | Event tracking |
| Notifications | Push via FCM |

---

## 2. Networking Flow — Real App

**Bad apps** mix network calls directly in the UI:
```dart
// ❌ WRONG — tightly coupled, untestable
onPressed: () async {
  final res = await Dio().get('https://api.com/products');
}
```

**Production apps** separate every concern:

```
UI (View)
  ↓
ViewModel (State Management)
  ↓
Repository (Abstraction + Mapper)
  ↓
Remote Data Source (HTTP / Dio / GraphQL)
  ↓
Backend API
  ↓
JSON Response → DTO → Domain Model → UI
```

> **Key Rule:** The UI never sees raw JSON or DTOs. The Data Source never knows about UI or business logic.

---

## 3. HTTP vs Dio vs GraphQL — Full Comparison

### `http` Package

The official, lightweight Dart networking package.

**Internal Working:**
1. Wraps lower-level `dart:io` networking
2. Creates HTTP request manually
3. Sends TCP/HTTPS request
4. Waits for raw response
5. You must manually parse the body

| Strength | Weakness |
|---|---|
| Lightweight | No interceptors |
| Official Dart package | Manual jsonDecode everywhere |
| Easy to understand | No retry / cancel built-in |
| | No auth middleware |

**Used in:** Small apps, SDKs, prototypes, learning projects.

---

### Dio

Full-featured HTTP client. Think of it as **Express middleware for networking**.

**Internal Working (Request Pipeline):**
```
Request Created
  ↓
onRequest Interceptors   ← inject auth, log, modify headers
  ↓
Transformer              ← encode request body
  ↓
dart:io HttpClient       ← actual TCP socket
  ↓
Transformer              ← decode response body (auto JSON!)
  ↓
onResponse Interceptors  ← log, transform
  ↓
Your Code
```

| Strength | Notes |
|---|---|
| Interceptors | Auth injection, retry, logging |
| Auto JSON | No jsonDecode needed |
| CancelToken | Lifecycle-safe requests |
| Timeout config | connectTimeout, receiveTimeout |
| Retry | Custom retry logic |
| Multipart upload | File uploads built-in |

**Used in:** Enterprise apps, fintech, social media, SaaS systems.

---

### GraphQL

A query language for APIs created by **Meta**.

**The REST Problem:**
```
REST — Multiple Endpoints, All Data Returned:
GET /user      → {id, name, email, avatar, age, address, ...}
GET /posts     → [{id, title, body, author, comments, ...}]
GET /comments  → [...]

You needed only: name + post titles  ← Overfetching!
```

**GraphQL Solution — Single Endpoint, Exact Fields:**
```graphql
query {
  user(id: 1) { name }
  posts { title }
}
# Returns ONLY what you asked for
```

| Strength | Weakness |
|---|---|
| Single endpoint | Complex backend setup |
| Prevents overfetching | Caching is harder |
| Strong schema/types | Higher learning curve |
| Frontend controls shape | Not all backends support it |

**Used in:** Large-scale apps, super apps, multi-platform ecosystems.

---

## 4. When to Use What?

| Scenario | Choice |
|---|---|
| Learning / prototyping | `http` |
| Small app, no auth | `http` |
| Production app with auth | `Dio` |
| Token refresh needed | `Dio` |
| File uploads | `Dio` |
| Backend already has GraphQL | `graphql_flutter` |
| Multiple UI data shapes from one source | GraphQL |

> **Rule of thumb:** Most Flutter production apps use **Dio**. Switch to GraphQL only when the backend supports it.

---

## 5. Repository Pattern (Very Important)

The Repository is the **abstraction layer** between ViewModels and data sources.

**Without Repository — Tightly Coupled:**
```dart
// ❌ ViewModel knows about Dio and raw JSON
final response = await Dio().get('https://api.com/products');
final products = response.data['products']; // raw map
```

**With Repository — Clean:**
```dart
// ✅ ViewModel knows nothing about how data is fetched
final products = await _repository.getProducts();
```

**Real Benefits:**

| Benefit | How |
|---|---|
| Testability | Inject mock repository in tests |
| Backend swap | Change HTTP→GraphQL in 1 file |
| Cache merge | Repository fetches local then remote |
| Separation | ViewModel is UI logic only |

---

## 6. Full CRUD — Code Examples

### HTTP CRUD
```dart
final baseUri = 'https://dummyjson.com';

// GET
final response = await http.get(Uri.parse('$baseUri/products'));
final data = jsonDecode(response.body); // Manual!

// POST
await http.post(
  Uri.parse('$baseUri/products/add'),
  headers: {'Content-Type': 'application/json'}, // Must set manually
  body: jsonEncode({'title': 'Flutter Product'}), // Must encode manually
);

// PUT
await http.put(
  Uri.parse('$baseUri/products/1'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'title': 'Updated Title'}),
);

// DELETE
await http.delete(Uri.parse('$baseUri/products/1'));
```

### Dio CRUD
```dart
final dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

// GET — URI is relative, no parsing needed
final response = await dio.get('/products');
final data = response.data; // Already decoded! No jsonDecode()

// POST — Map auto-encoded to JSON body
await dio.post('/products/add', data: {'title': 'Flutter Product'});

// PUT
await dio.put('/products/1', data: {'title': 'Updated Title'});

// DELETE
await dio.delete('/products/1');
```

### GraphQL CRUD
```dart
final client = GraphQLClient(
  cache: GraphQLCache(),
  link: HttpLink('https://countries.trevorblades.com/'),
);

// QUERY (Read)
final result = await client.query(QueryOptions(
  document: gql(r'''
    query GetCountries {
      countries { code name emoji capital }
    }
  '''),
));

// MUTATION (Write)
await client.mutate(MutationOptions(
  document: gql(r'''
    mutation AddProduct($title: String!, $price: Float!) {
      addProduct(title: $title, price: $price) { id title }
    }
  '''),
  variables: {'title': 'New Product', 'price': 99.99},
));
```

---

## 7. Production Patterns — Deep Dive

### Interceptors (Very Important)

Middleware that runs automatically on every request/response.

```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    // ✅ Inject auth token to EVERY request automatically
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  },
  onResponse: (response, handler) {
    print('✅ ${response.statusCode} ${response.requestOptions.path}');
    return handler.next(response);
  },
  onError: (error, handler) {
    print('❌ ${error.type} ${error.response?.statusCode}');
    return handler.next(error);
  },
));
```

**Real Production Uses:**

| Use Case | What It Does |
|---|---|
| Auth token | Auto-inject header |
| Logging | Print all requests |
| Retry | Re-attempt on failure |
| Token refresh | Handle 401 silently |
| Analytics | Track API usage |

---

### Retry Mechanism

Mobile internet is unstable. A request may fail due to a brief network blip.

```dart
Future<T> withRetry<T>(Future<T> Function() operation) async {
  int attempt = 0;
  while (attempt < 3) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= 3) rethrow;
      // Exponential backoff: 500ms → 1000ms → 1500ms
      await Future.delayed(Duration(milliseconds: 500 * attempt));
    }
  }
  throw Exception('Failed after 3 retries');
}
```

> **⚠️ Production Warning:** Blind retries can overload servers. Always use exponential backoff and limit retries to idempotent requests (GET, PUT, DELETE).

---

### Timeout Handling

Without a timeout, a slow server will hang your app **forever**.

```dart
final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 10), // Time to establish connection
  receiveTimeout: const Duration(seconds: 10), // Time to receive data
  sendTimeout: const Duration(seconds: 10),    // Time to upload data
));
```

---

### Request Cancellation

When a user leaves a screen, the in-flight request should stop. Without cancellation:
- Wastes bandwidth and battery
- Can call `setState()` on a disposed widget → **crash**

```dart
final cancelToken = CancelToken();

// Start request with token
await dio.get('/products', cancelToken: cancelToken);

// Cancel it (e.g., in dispose())
cancelToken.cancel('User left the screen');
```

```dart
@override
void dispose() {
  cancelToken.cancel(); // ✅ Clean up
  super.dispose();
}
```

---

### Debouncing Search Requests

**Problem:** User types `a`, `ab`, `abc` → triggers 3 separate API calls.
**Solution:** Wait 500ms after they stop typing, then fire ONE call.

```dart
Timer? _debounce;

void onSearch(String query) {
  _debounce?.cancel(); // Cancel previous timer
  _debounce = Timer(const Duration(milliseconds: 500), () async {
    await dio.get('/products/search?q=$query');
  });
}

@override
void dispose() {
  _debounce?.cancel(); // ✅ Always clean up
  super.dispose();
}
```

---

### Exception Handling

Map raw transport errors into user-friendly messages.

```dart
try {
  await dio.get('/products');
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      throw TimeoutAppException();
    case DioExceptionType.connectionError:
      throw NetworkException();
    case DioExceptionType.badResponse:
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.statusCode);
    case DioExceptionType.cancel:
      throw CancelledByUserException();
    default:
      throw UnknownAppException();
  }
}
```

---

## 8. REST Architecture

**REST (Representational State Transfer)** is the architectural style that standardizes communication between client and server over HTTP.

**Before REST:** Systems were tightly coupled with no standard protocol. Each API was unique.

**REST Principles:**

| Principle | Meaning |
|---|---|
| Resource-Based | Everything is a resource: `/users`, `/products`, `/orders` |
| Stateless | Every request is self-contained — server remembers nothing |
| Uniform Interface | Standard HTTP methods for all operations |

**Uniform Interface:**

| HTTP Method | REST Meaning | Example |
|---|---|---|
| GET | Read | `GET /products` |
| POST | Create | `POST /products` |
| PUT / PATCH | Update | `PUT /products/1` |
| DELETE | Remove | `DELETE /products/1` |

**Full Request Lifecycle:**
```
Flutter App
  ↓ Dio / http
  ↓ TCP/IP Connection
  ↓ HTTPS Request
  ↓ Backend Server
  ↓ Database Query
  ↓ JSON Response
  ↓ DTO.fromJson()
  ↓ Repository Mapper
  ↓ Domain Model
  ↓ UI Update
```

---

## 9. JSON Serialization

APIs speak JSON strings. Flutter works with Dart objects. **Serialization** bridges this gap.

```dart
// Raw API response (String):
// '{"id": 1, "title": "Phone", "price": 299.99}'

// Manual Deserialization (JSON → Object)
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] as int,
    title: json['title'] as String,
    price: (json['price'] as num).toDouble(),
  );
}

// Manual Serialization (Object → JSON)
Map<String, dynamic> toJson() => {
  'id': id,
  'title': title,
  'price': price,
};
```

**⚠️ Problem with Manual Serialization in Large Apps:**
- Repetitive boilerplate across every model
- Error-prone (typos in string keys)
- Hard to maintain

**✅ Production Solution — Code Generation:**
```dart
@JsonSerializable()
class Product {
  final int id;
  final String title;
  
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
```
Use `json_serializable` or `freezed` to auto-generate the parsing logic.

---

## 10. DTO vs Domain Model (Advanced)

Most developers never learn this properly. It is one of the most important architectural patterns.

### What is a DTO?

**Data Transfer Object** — mirrors the exact raw API response structure.

```dart
// DTO matches the API contract exactly
class ProductDto {
  final int? id;
  final String? title;    // API sends "title"
  final num? price;       // API sends num, not double
  final String? thumbnail;
}
```

### What is a Domain Model?

**Business-friendly** structure used by the UI.

```dart
// Domain Model is clean, non-nullable, business-named
class Product {
  final int id;
  final String name;      // Renamed from "title" for business clarity
  final double price;     // Converted to double
  final String imageUrl;  // Renamed from "thumbnail"
}
```

### Why Separate Them?

```
API today:    { "title": "Phone",    "product_img": "url" }
API tomorrow: { "name":  "Phone",    "thumbnail":   "url" }

Without DTO:  Entire app breaks — every widget using "title" must change
With DTO:     Only ProductDto + _mapDtoToDomain() changes. UI: zero changes.
```

**Production Flow:**
```
API JSON  →  ProductDto.fromJson()  →  repository._map(dto)  →  Product (Domain)  →  UI
```

---

## 11. Dio Internals & Token Refresh Flow (Critical)

### Dio Request Pipeline

```
Your Code calls: dio.get('/products')
  ↓
1. onRequest Interceptors  ← Inject headers, log
  ↓
2. Transformer             ← Encode request body
  ↓
3. dart:io HttpClient      ← Actual TCP network call
  ↓
4. Transformer             ← Decode response body (auto JSON)
  ↓
5. onResponse Interceptors ← Log, transform data
  ↓
Your Code receives: response.data (already decoded Map)
```

This pipeline is **why Dio exists** — it enables auth, retries, analytics as middleware.

### Token Refresh Flow

**Problem:** Access tokens expire → API returns `401 Unauthorized`.

**Bad UX:** Force logout → user loses work → bad reviews.

**Production Flow:**
```
Your request hits the API
  ↓
401 Unauthorized received
  ↓
onError Interceptor catches it
  ↓
Lock: _isRefreshing = true (prevents race condition)
  ↓
Call /refresh-token endpoint
  ↓
Receive new access token
  ↓
Update original request headers
  ↓
Retry original request via dio.fetch(requestOptions)
  ↓
Return response → User never notices anything happened
```

**Code:**
```dart
onError: (DioException e, handler) async {
  if (e.response?.statusCode == 401 && !_isRefreshing) {
    _isRefreshing = true;
    try {
      final newToken = await _refreshToken();
      e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await dio.fetch(e.requestOptions);
      return handler.resolve(retryResponse); // ✅ Silent recovery
    } finally {
      _isRefreshing = false;
    }
  }
  return handler.next(e);
},
```

> **⚠️ Race Condition:** 5 widgets load simultaneously → all get 401 → all call refresh. The `_isRefreshing` lock ensures only ONE refresh call happens.

---

## 12. GraphQL Deep Dive

### Architecture

GraphQL uses a **single endpoint** (`/graphql`) for everything. Unlike REST's many endpoints, everything flows through one gateway.

```
REST:     GET /users, GET /posts, GET /comments   (3 requests)
GraphQL:  POST /graphql  with query body           (1 request, exact fields)
```

### Operations

**1. Query — Read Data**
```graphql
query GetCountries {
  countries {
    code
    name
    emoji
    capital
    # We did NOT request population, languages, etc. → No overfetch!
  }
}
```

**2. Mutation — Write Data**
```graphql
mutation AddProduct($title: String!, $price: Float!) {
  addProduct(title: $title, price: $price) {
    id
    title
    price
  }
}
```

**3. Subscription — Realtime Data (WebSocket)**
```graphql
subscription OnNewMessage {
  newMessage {
    id
    text
    sender
  }
}
```

Used for: Chat systems, live dashboards, collaborative apps.

### Why GraphQL is Powerful

The **frontend** decides the exact shape of data. The backend does not over-send. In large apps where 10 different screens need 10 different data shapes from the same entity, GraphQL eliminates the need for 10 endpoints.

---

## 13. Exception Mapping (Very Important)

Raw exceptions must **never** reach the UI.

**Why?**
```
// ❌ What the user sees without mapping:
"SocketException: OS Error: Connection refused, errno = 111, address = localhost"

// ✅ What the user should see with mapping:
"No Internet Connection."
```

**Production Solution — Sealed Class:**
```dart
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No Internet Connection.']);
}
class TimeoutAppException extends AppException {
  const TimeoutAppException([super.message = 'Connection timed out.']);
}
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please log in again.']);
}
class ServerException extends AppException {
  final int? statusCode;
  const ServerException(this.statusCode, [super.message = 'Server error.']);
}
class CancelledByUserException extends AppException {
  const CancelledByUserException([super.message = 'Request cancelled.']);
}
```

**ViewModel catches cleanly:**
```dart
try {
  products = await _repository.getProducts();
} on AppException catch (e) {
  errorMessage = e.message; // Always user-friendly
}
```

---

## 14. Interview Round Q&A

### 🧠 Q1 — HTTP vs Dio
**Q:** Why choose Dio over http in production?

**A:** Dio provides a middleware-style networking architecture through interceptors, which enables centralized auth injection, silent 401 token refresh, global retry logic, and request cancellation. The `http` package is lightweight and suitable for simple use cases but lacks these enterprise-oriented abstractions.

---

### 🧠 Q2 — Repository Pattern
**Q:** Why introduce repositories instead of calling Dio directly from the ViewModel?

**A:** Repositories abstract data access from application layers. Benefits: testability (mock repository in tests), backend independence (swap REST→GraphQL in one file), cache integration, and clean separation of concerns. Without repositories, networking logic leaks into state layers and becomes unmaintainable.

---

### 🧠 Q3 — GraphQL vs REST
**Q:** Why might GraphQL outperform REST in large frontend systems?

**A:** GraphQL allows clients to request exactly the required fields, reducing overfetching and minimizing the need for multiple endpoint calls. Especially powerful when different screens require different subsets of data from the same entity. However, GraphQL introduces backend complexity and caching challenges.

---

### 🧠 Q4 — Retry Mechanism Design
**Q:** Why should retry mechanisms be carefully designed?

**A:** Blind retries can overload servers, duplicate transactions (especially on POST), and worsen outages. Production retry systems should include exponential backoff, retry limits (max 3), idempotency awareness (only retry GET/PUT/DELETE, not POST unless guaranteed idempotent), and network-state detection.

---

### 🧠 Q5 — Cancellation Scenario
**Q:** Why cancel requests when a screen is disposed?

**A:** Unnecessary in-flight requests waste bandwidth, battery, memory, and CPU. More critically, they will call back into disposed widgets causing `setState() called after dispose()` crashes. Cancellation ensures lifecycle-safe networking.

---

### 🧠 Q6 — DTO vs Domain Model
**Q:** Why separate DTOs from domain models?

**A:** DTOs represent backend contracts; domain models represent business logic. Separating them prevents backend schema changes from propagating through the entire application. Only the DTO and repository mapper change — the UI, ViewModel, and tests are completely unaffected.

---

### 🧠 Q7 — Token Refresh Race Condition
**Q:** Five requests return 401 simultaneously. What problem occurs?

**A:** Without synchronization, all five requests trigger a token refresh simultaneously. This causes: 5 refresh API calls, potential token invalidation (server may only allow one refresh per token), and inconsistent state. Production fix: use a boolean lock (`_isRefreshing`) so only the first 401 triggers refresh while others wait.

---

### 🧠 Q8 — Exception Handling
**Q:** Why map network exceptions into a sealed class?

**A:** Raw exceptions like `SocketException` and `DioException` contain OS-level error messages that are meaningless and frightening to users. Mapping them to a sealed `AppException` hierarchy allows the UI to display human-friendly messages, enables exhaustive pattern matching with `switch`, and keeps error-handling logic centralized in the data layer rather than scattered through ViewModels.

---

## Module File Map

```
lib/api_networking/
├── core/
│   ├── models/
│   │   ├── dtos/
│   │   │   └── product_dto.dart       ← Raw API contract
│   │   ├── domain/
│   │   │   └── product.dart           ← Business model (no nulls)
│   │   └── country.dart               ← GraphQL response model
│   ├── network/
│   │   ├── dio_client.dart            ← Dio + Interceptors + Token Refresh
│   │   ├── graphql_client.dart        ← GraphQL client setup
│   │   └── app_exceptions.dart        ← Sealed exception hierarchy
│   ├── data_sources/
│   │   ├── product_remote_data_source.dart  ← HTTP + Dio CRUD (returns DTOs)
│   │   └── graphql_remote_data_source.dart  ← GraphQL Query + Mutation
│   └── repositories/
│       └── networking_repository.dart  ← DTO→Domain mapping + Retry
└── presentation/
    ├── viewmodels/
    │   ├── http_viewmodel.dart         ← HTTP screen state (SRP)
    │   ├── dio_viewmodel.dart          ← Dio screen state + Cancel + Debounce
    │   └── graphql_viewmodel.dart      ← GraphQL screen state
    └── views/
        ├── networking_home_screen.dart ← Hub with architecture diagram
        ├── http_demo_screen.dart       ← 5-tab CRUD (GET/POST/PUT/DELETE)
        ├── dio_demo_screen.dart        ← 6-tab CRUD + Advanced
        └── graphql_demo_screen.dart    ← Query + Mutation tabs
```

## App View

<img width="1344" height="2992" alt="Screenshot_20260510_173143" src="https://github.com/user-attachments/assets/46b36442-ae39-4deb-9d1b-cc7bb6c6b528" />

<img width="1344" height="2992" alt="Screenshot_20260510_173152" src="https://github.com/user-attachments/assets/75835b12-031a-4fb4-beb5-7a6c59e6baf7" />

<img width="1344" height="2992" alt="Screenshot_20260510_173210" src="https://github.com/user-attachments/assets/788a4c93-5fcf-4a68-8d73-c18c0c4d9fcf" />

<img width="1344" height="2992" alt="Screenshot_20260510_173218" src="https://github.com/user-attachments/assets/fba9de26-9b2e-44af-b996-08c49811ab6a" />



