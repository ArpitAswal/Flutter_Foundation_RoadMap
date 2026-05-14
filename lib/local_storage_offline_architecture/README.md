# Local Storage & Offline Architecture

This module is designed as an interactive, hands-on learning application that demonstrates every major local storage strategy in Flutter. It covers the core concepts, internal mechanics, and real-world implementation of **SharedPreferences**, **Hive**, **SQLite**, **Drift**, and **Isar**.

---

## 📖 Part 1: What is Local Storage?

### Definition
Local storage means: **Persisting data on the device** so that data survives:
- App restart
- Device reboot
- Offline mode

### Why Local Storage Exists
Without local storage:
- User logs out every restart
- Settings reset
- Offline impossible
- Repeated API calls
- Slow UX

### Real App Use Cases
| Feature | Storage Needed? |
| :--- | :--- |
| Login token | ✅ |
| Theme mode | ✅ |
| Cached products | ✅ |
| Offline chat | ✅ |
| Search history | ✅ |
| User profile | ✅ |

---

## 🔑 Part 2: Types of Local Storage
There are multiple persistence layers.

### Key-Value Storage
Stores `key → value` (e.g. `theme = dark`, `token = abc123`).

### Database Storage
Stores:
- Structured data
- Large lists
- Relationships
Example: Products list, User orders, Chat history.

---

## ⚙️ Part 3: The 5 Big Players in Flutter

### 1. SharedPreferences (Key-Value)
- **What it is:** The default package for small key-value data.
- **Behind the scenes:** It wraps platform-specific code. On Android it uses `SharedPreferences` (XML file). On iOS it uses `NSUserDefaults`.
- **Supported types:** int, double, bool, String, List<String>.
- **The Production Problem:** *Never store large data here.* SharedPreferences loads the ENTIRE file into memory upon initialization. If you store a huge JSON string of 10,000 products, your app's RAM usage will spike.

### 2. Hive (NoSQL Database)
- **What it is:** A lightweight, blazing fast key-value/NoSQL database written in pure Dart.
- **How it works:** It uses "Boxes" (similar to tables in SQL).
- **Pros:** Extremely fast (faster than SQLite), pure Dart (no native dependencies), supports custom objects via TypeAdapters.
- **Cons:** Limited complex querying (no Joins or heavy relational logic).
- **Best for:** Offline caching, shopping carts, local notes.

### 3. SQLite (SQL Database)
- **What it is:** A relational database embedded inside the device (using `sqflite`).
- **How it works:** Uses raw SQL strings (`SELECT * FROM table`).
- **Pros:** Standardized, supports complex relations, joins, and indexing.
- **Cons:** You have to write raw SQL strings (prone to typos), no compile-time safety, lots of boilerplate code.
- **Best for:** Complex enterprise apps with heavy relational data.

### 4. Drift (Type-Safe SQL)
- **What it is:** Formerly called Moor, it is a reactive, type-safe wrapper around SQLite.
- **How it works:** You write Dart classes, run `build_runner`, and it generates all the safe SQL code for you.
- **Pros:** No raw strings! Compile-time safety, built-in Dart Streams (Reactive UI).
- **Cons:** Setup is complex, requires code generation.
- **Best for:** Production-grade apps needing SQL without the raw SQL headache.

### 5. Isar (High-Performance NoSQL)
- **What it is:** Created by the author of Hive, it is an ultra-fast NoSQL database built specifically for Flutter.
- **How it works:** Uses `build_runner` to create indexes and schema.
- **Pros:** Highly scalable, supports full-text search, ACID transactions, and reactive streams.
- **Cons:** Not relational (though it supports links).
- **Best for:** Huge datasets requiring extreme performance and complex search queries.

---

## ⚖️ Part 4: The Ultimate Comparison Table
| Feature | SharedPrefs | Hive | SQLite | Drift | Isar |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Type** | Key-Value | NoSQL | SQL | SQL Wrapper | NoSQL |
| **Speed** | Medium | Very Fast | Fast | Fast | Ultra Fast |
| **Queries** | ❌ | Basic | ✅ Complex | ✅ Complex | ✅ Fast Indexes |
| **Relations** | ❌ | ❌ | ✅ | ✅ | Links |
| **Reactive Streams** | ❌ | ✅ (Watch) | ❌ | ✅ | ✅ |

---

## 🌐 Part 5: Offline-First Architecture

### The Wrong Way (Online-Only)
UI → API → UI
*If there is no internet, the app shows a blank screen or error.*

### The Right Way (Cache-First / Offline-First)
UI → Local Database (Instant Load)
Local Database → Syncs with API in Background
API → Updates Local Database
Local Database → Automatically pushes new data to UI via Streams.

**Why?**
1. App opens instantly.
2. User can read/write data offline.
3. When internet returns, background sync handles the rest.

---

## 🔒 Part 6: Secure Storage (Security Warning)
**NEVER** save JWT tokens, API keys, or Passwords in SharedPreferences or Hive. Those files are unencrypted and can be extracted from rooted/jailbroken devices.
**ALWAYS** use `flutter_secure_storage`.
- **How it works:** Uses Android Keystore and iOS Keychain. It encrypts the data at the hardware level.

---

## 🛠️ What You Will Learn From the Code In This Module

When you run this module (`flutter run -t lib/local_storage_offline_architecture/main.dart`), you get a hands-on, interactive UI. 

**Here is exactly what you will learn by reading the code:**

1. **Step-by-Step Initialization:** Look inside the `data/` folder. Every service (e.g., `sqlite_service.dart`, `hive_service.dart`) has highly detailed, numbered comments explaining exactly how to initialize the database, get system paths, and open files.
2. **Code Snippets in UI:** In every screen of the app, as you click a button (like "Save Token" or "Init DB"), a terminal box at the bottom of the screen dynamically updates to show you the exact block of Dart or SQL code that was executed.
3. **The Repository Pattern:** Check `offline_first/product_repository.dart` to see a real-world implementation of the Cache-First strategy. It shows how to use Dart Generators (`yield*`) to instantly return cached data, fire off an API call, and then yield the updated data.
4. **Code Generation:** See how Drift and Isar require `build_runner` to auto-generate schemas and Type Adapters. Look at `drift_database.dart` to see how Table classes are structured before generation.
5. **Reactive UI Updates:** In `drift_screen.dart` and `isar_screen.dart`, observe how we bind a `StreamBuilder` directly to the database stream. Notice that when we insert or delete data, we *don't* manually call `setState()`—the UI updates automatically because the database pushes the changes through the stream.

---

## 🎯 Part 7: Advanced Interview Round

The following Q&A represents the depth of knowledge expected from a **Senior Flutter Engineer** in a technical interview focused on local persistence and offline architecture.

---

### 🧠 Q1 — SharedPreferences vs Hive

**Interviewer:**

> Why not store product lists in SharedPreferences?

**Strong Answer:**

SharedPreferences is designed for lightweight key-value persistence and **loads its entire dataset into memory** upon initialization.

Large structured datasets such as product lists become:
- **Inefficient** — the whole file is parsed into RAM every cold start
- **Difficult to query** — no filtering, sorting, or pagination is possible
- **Expensive to serialize** — repeatedly converting large JSON strings to/from Dart objects wastes CPU cycles

Hive or SQLite-based solutions are more appropriate for scalable structured persistence.

---

### 🧠 Q2 — Why Repository Layer?

**Interviewer:**

> Why place caching inside the repository instead of the UI?

**Strong Answer:**

Repositories centralize data orchestration between:
- Remote APIs
- Local databases
- In-memory caches

This prevents persistence logic from **leaking into presentation layers**, which would violate the Single Responsibility Principle.

A Repository layer enables:
- **Offline-first architecture** — the UI doesn't care where data comes from
- **Testability** — repositories can be mocked independently of the UI
- **Backend flexibility** — switching from REST to GraphQL only changes the repository, never the UI

---

### 🧠 Q3 — Why DTO Separation Matters Offline?

**Interviewer:**

> Why separate API DTOs from local database entities?

**Strong Answer:**

Backend contracts and local persistence requirements **often evolve independently**.

For example:
- The API may rename a field (`product_name` → `title`), which should only update the DTO layer
- The local database may need to add an `isSynced` boolean field that the API knows nothing about

Separating DTOs from domain entities:
- **Isolates schema changes** — API changes don't cascade into the local DB model
- **Prevents coupling** — API-specific structures (e.g., `created_at` as a Unix timestamp string) don't leak into business logic
- **Enables independent versioning** — you can migrate the local DB schema without waiting for the API to update

---

### 🧠 Q4 — Hive vs SQLite

**Interviewer:**

> When would SQLite outperform Hive?

**Strong Answer:**

SQLite is superior when the data is **relational** and requires:

| Capability | SQLite | Hive |
| :--- | :--- | :--- |
| JOIN across tables | ✅ | ❌ |
| Complex WHERE + ORDER BY + LIMIT | ✅ | ❌ |
| Aggregate functions (COUNT, SUM) | ✅ | ❌ |
| Index-backed queries | ✅ | ❌ (basic) |
| Full ACID transactions | ✅ | ❌ |
| Foreign key constraints | ✅ | ❌ |

**Example:** An order management system that must query *"all orders placed by user X in the last 30 days, grouped by status, ordered by total value"* requires SQLite (or Drift over SQLite). Hive cannot express this query.

Hive is excellent for **simpler object persistence** (caching flat lists, storing user drafts), but it lacks the querying sophistication required in enterprise relational systems.

---

### 🧠 Q5 — Offline-First Architecture

**Interviewer:**

> Why do modern apps prefer offline-first systems?

**Strong Answer:**

Offline-first systems dramatically improve:

1. **Perceived performance** — users see content instantly on cold start because data is already on-device
2. **Reliability** — the app remains fully functional even when the network is absent or unreliable (flights, tunnels, weak signal)
3. **User experience** — no blank screens, no loading spinners on every navigation, no data loss during connectivity drops
4. **Resilience** — partial network failures (timeouts, 500 errors) are gracefully degraded to the local cache

**The Cache-First Pattern (as implemented in this module):**

```
UI → Repository.getProductsCacheFirst()
       ↓
  yield localCache immediately  ←── User sees data in ~0ms
       ↓
  fetch from API in background
       ↓
  update localCache
       ↓
  yield fresh data              ←── UI silently updates
```

By prioritizing local persistence and background synchronization, applications remain responsive and trustworthy even during complete connectivity loss. This is the architecture used by Spotify (offline playlists), Gmail (offline inbox), and Uber (cached map tiles).
