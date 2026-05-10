# 🔮 Async Programming — Futures, Streams & Event Loop

> **Module path:** `lib/async_programming/`
>
> This module is a production-grade implementation of Dart's asynchronous execution model,
> covering everything from the event loop basics to advanced isolate-based parallel processing.

---

## Table of Contents

1. [Architecture: Production-Grade Layering](#architecture-production-grade-layering)
2. [Dart's Execution Model & Event Loop](#darts-execution-model--event-loop)
3. [Futures: One-Time Async Operations](#futures-one-time-async-operations)
4. [async / await & Internal Workings](#async--await--internal-workings)
5. [FutureBuilder: Deep Dive & Common Pitfalls](#futurebuilder-deep-dive--common-pitfalls)
6. [Streams: Continuous Data Flow](#streams-continuous-data-flow)
7. [StreamBuilder & Lifecycle Responsibility](#streambuilder--lifecycle-responsibility)
8. [Broadcast Streams vs Single-Subscription](#broadcast-streams-vs-single-subscription)
9. [Parallelism: Future.wait vs Records](#parallelism-futurewait-vs-records)
10. [Advanced: Completer & StreamController](#advanced-completer--streamcontroller)
11. [Isolates: True Parallel CPU Work](#isolates-true-parallel-cpu-work)
12. [Zones & Global Error Handling](#zones--global-error-handling)
13. [Common Mistakes & Performance Implications](#common-mistakes--performance-implications)
14. [Advanced Interview Round (Q&A)](#advanced-interview-round-qa)
15. [Module File Map](#module-file-map)

---

## Architecture: Production-Grade Layering

In production, async code must be separated into clear layers. Mixing network calls with UI code makes apps impossible to test and scale.

### ✅ Correct Separation (Implemented in this module)
```
UI (View) → ViewModel (State) → Repository → Data Source
```

1. **View (UI)**: Consumes state via `FutureBuilder`/`StreamBuilder`.
2. **ViewModel**: Orchestrates jobs, handles `dispose()`, and holds stable Future/Stream references.
3. **Repository**: Orchestrates multiple data sources (e.g., Cache + Network) and transforms DTOs to Domain Models.
4. **Data Source**: Lowest level. Only knows how to fetch raw data (e.g., Dio, Firebase, Hive).

---

## Dart's Execution Model & Event Loop

Dart is **single-threaded**. It manages concurrency via an **Event Loop** architecture.

### Execution Order — CRITICAL
1. **Synchronous Call Stack**: Everything in your `main()` runs first.
2. **Microtask Queue**: High-priority tasks (e.g., `Future.microtask`). These run **before** the event queue.
3. **Event Queue**: Standard async tasks (e.g., `Future`, `Timer`, I/O, User input).

> **⚠️ WARNING:** Overloading the Microtask queue can "starve" the Event queue, making your UI unresponsive to touch events.

---

## Futures: One-Time Async Operations

A `Future<T>` represents a value that will exist later. It handles tasks like:
- `authRepository.login()` (Network)
- `hiveBox.put(...)` (Disk I/O)
- `FirebaseAuth.instance.signIn` (Auth delay)

---

## async / await & Internal Workings

When you hit `await`, Dart does **NOT** block the thread or create a new thread.

### Internally:
1. The current function is **paused**.
2. Control is **returned to the event loop** immediately (UI stays responsive).
3. The Future completion callback is **queued** in the Event Loop.
4. The function **resumes** once the event loop reaches that callback.

---

## FutureBuilder: Deep Dive & Common Pitfalls

### 🔍 Why caching the Future is MANDATORY
`FutureBuilder` stores the **Future reference**, not the **Future result**.

**❌ The Mistake:**
```dart
FutureBuilder(
  future: apiCall(), // 😱 New future + New network request on EVERY rebuild!
)
```
**✅ The Solution:**
Cache the Future in `initState()` or a ViewModel to maintain a stable reference across rebuilds.

---

## Streams: Continuous Data Flow

Use Streams for data that arrives multiple times over time:
- Chat systems / Live events
- Firebase realtime updates
- GPS tracking / Sensors
- WebSockets

### StreamController
While `async*` is great for simple generators, `StreamController` is used to create streams manually (e.g., in a Chat Service).

---

## Broadcast Streams vs Single-Subscription

| Type | Subscription Limit | Use Case |
|---|---|---|
| **Single-Subscription** | One listener only | File reading, HTTP body |
| **Broadcast** | Multiple simultaneous listeners | Auth state, Chat events |

> **⚠️ Broadcast Tradeoff:** Broadcast streams do **NOT** buffer missed events. Late listeners miss all data emitted before they subscribed.

---

## Parallelism: Future.wait vs Records

When tasks are independent, run them in parallel to save time.

### Traditional: `Future.wait`
```dart
final results = await Future.wait([fetchA(), fetchB()]);
final a = results[0] as TypeA; // Manual casting required
```

### Modern (Dart 3.0+): Records `.wait`
```dart
final (a, b) = await (fetchA(), fetchB()).wait; // Type-safe and cleaner!
```
Total time = `max(latency_A, latency_B)` instead of `latency_A + latency_B`.

---

## Advanced: Completer & StreamController

### 🏁 Completer
A `Completer` allows you to manually complete a Future from an external event.
- **Use Case**: Waiting for a WebSocket handshake or bridging older callback-based APIs to Futures.

### 🕹️ StreamController
The standard way to produce streams manually. Always `close()` your controllers in `dispose()` to prevent memory leaks.

---

## Isolates: True Parallel CPU Work

Dart logic normally runs on a single **UI Isolate**. Heavy CPU tasks (large JSON parsing, image processing) block this isolate and cause **UI jank**.

### ✅ The Solution: `compute()`
Moves the heavy task to a **Worker Isolate**.
```dart
final result = await compute(heavyTask, data);
```
**Use Isolate for:** Large JSON parsing, Image compression, Encryption, AI processing.

---

## Zones & Global Error Handling

`Zones` allow you to wrap your app in an environment for global error handling.

```dart
runZonedGuarded(() {
  runApp(MyApp());
}, (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack);
});
```

---

## Common Mistakes & Performance Implications

1. **Calling Future in `build()`**: Triggers duplicate requests on every theme change or keyboard toggle.
2. **Missing `mounted` check**: Calling `setState` after an `await` on a disposed widget causes crashes.
3. **Sequential Independent APIs**: Fetching user info, then posts, then settings one by one instead of using parallel `.wait`.
4. **Blocking the UI thread**: Running complex math or JSON parsing on the main isolate.

---

## Advanced Interview Round (Q&A)

### 🧠 Q1 — FutureBuilder Architecture
**Interviewer:** Why is creating Future directly inside build dangerous?
**Answer:** Because build can execute multiple times (rebuilds, theme changes, etc). If recreated, you start new async tasks and network requests on every frame, causing inconsistent state and wasted resources.

### 🧠 Q2 — Stream Architecture
**Interviewer:** Why would you convert a stream to broadcast?
**Answer:** If multiple consumers (UI, Analytics, State) need the same data stream. Note: Broadcast streams don't replay old events.

### 🧠 Q3 — Async Performance
**Interviewer:** Why does Future.wait improve performance?
**Answer:** It starts independent tasks concurrently. Total wait time drops from A+B to max(A,B).

### 🧠 Q4 — Production Streams
**Interviewer:** Why must StreamSubscription be cancelled?
**Answer:** To prevent memory leaks and "state-after-dispose" exceptions. Active subscriptions keep references alive even after a screen is gone.

### 🧠 Q5 — Isolates Scenario
**Interviewer:** Your app freezes while parsing a 20MB JSON file. Why?
**Answer:** Large CPU tasks block the single-threaded Event Loop. Frame rendering stops. The fix is moving the task to a worker isolate via `compute()`.

---

## Module File Map

```
lib/async_programming/
├── core/
│   ├── data_sources/       ← Raw Data Fetching
│   ├── repositories/       ← Business logic & orchestration
│   └── services/           ← Isolate & CPU tasks
└── presentation/
    ├── viewmodels/         ← State & Lifecycle (dispose)
    └── views/              ← UI Consumers
```

## App View

<img width="1344" height="2992" alt="Screenshot_20260510_173830" src="https://github.com/user-attachments/assets/22f6e407-2657-4f44-9391-ce801be786a5" />

<img width="1344" height="2992" alt="Screenshot_20260510_173838" src="https://github.com/user-attachments/assets/624d25d5-a507-4fd7-b2d6-3b48cba6b819" />

<img width="1344" height="2992" alt="Screenshot_20260510_173845" src="https://github.com/user-attachments/assets/a39bd5cc-2828-45b3-9bca-2e69043785c9" />

<img width="1344" height="2992" alt="Screenshot_20260510_173856" src="https://github.com/user-attachments/assets/c9ddfce4-e469-44a9-88dd-3a3140983ca7" />

<img width="1344" height="2992" alt="Screenshot_20260510_173911" src="https://github.com/user-attachments/assets/e2270cdc-528a-4b8e-8ff7-d91314c44a90" />