# 🔮 Async Programming — Futures, Streams & Event Loop

> **Module path:** `lib/async_programming/`
>
> This module is a production-grade implementation of Dart's asynchronous execution model,
> covering the three most critical real-world async patterns every Flutter engineer must master.

---

## Table of Contents

1. [Why Async Exists](#why-async-exists)
2. [Dart's Execution Model](#darts-execution-model)
3. [What is a Future?](#what-is-a-future)
4. [async / await Deep Dive](#async--await-deep-dive)
5. [Error Handling](#error-handling)
6. [The `mounted` Check](#the-mounted-check)
7. [FutureBuilder](#futurebuilder)
8. [Streams](#streams)
9. [StreamBuilder](#streambuilder)
10. [Memory Leaks with Streams](#memory-leaks-with-streams)
11. [Parallel Futures — `Future.wait`](#parallel-futures--futurewait)
12. [Production Architecture](#production-architecture)
13. [Module File Map](#module-file-map)
14. [Assignments Implemented](#assignments-implemented)

---

## Why Async Exists

Mobile apps constantly perform tasks that take time. If these ran synchronously (blocking the UI thread), your app would freeze — a phenomenon Android calls **ANR (Application Not Responding)**.

| Task | Async? |
|---|---|
| API call | ✅ |
| Database read | ✅ |
| File access | ✅ |
| Bluetooth | ✅ |
| Firebase | ✅ |
| Animations | ✅ |

Async allows these operations to run **without blocking the UI thread**, keeping your app at 60fps while data loads in the background.

---

## Dart's Execution Model

Dart is **single-threaded + event loop based**. There is only ONE thread for your Dart code. This is different from Java/Android which use multiple threads. Instead of threads, Dart uses an event loop to handle async work efficiently.

### Core Components

```
┌──────────────┐    ┌───────────────────┐    ┌─────────────────┐
│  Call Stack  │    │  Microtask Queue  │    │   Event Queue   │
│              │    │                   │    │                 │
│ main()       │ ←─ │  Future.microtask │ ←─ │  Future(...)    │
│ function()   │    │  scheduleMicrotask│    │  Timer          │
│ ...          │    │                   │    │  I/O callbacks  │
└──────────────┘    └───────────────────┘    └─────────────────┘
```

### Execution Order — CRITICAL

```dart
void main() {
  print("A");                              // 1. Sync
  Future(() => print("B"));               // 3. Event Queue (last)
  Future.microtask(() => print("C"));     // 2. Microtask Queue (before event queue)
  print("D");                             // 1. Sync
}
```

**Output:**
```
A
D
C
B
```

**Why?**

1. Synchronous code runs first (A, D)
2. Microtask queue drains next (C)
3. Event queue runs last (B)

> **🧠 KEY RULE:** Microtask Queue > Event Queue. Always.

---

## What is a Future?

A `Future<T>` represents **a value that will exist later**. Think of it as a "promise" — you don't have the value right now, but you'll receive it (or an error) at some point.

### States of a Future

```
┌─────────────┐
│ Uncompleted │  ← Future is running, no value yet
└──────┬──────┘
       │
  ┌────┴────┐
  │         │
  ▼         ▼
┌──────┐  ┌────────┐
│ with │  │ with   │
│ value│  │ error  │
└──────┘  └────────┘
```

---

## async / await Deep Dive

```dart
Future<String> fetchUser() async {
  await Future.delayed(const Duration(seconds: 2));
  return "UserName";
}
```

### What `await` REALLY Does

`await` does **NOT** block the thread. Instead:

1. **Pauses** the current function at the `await` keyword
2. **Returns control** to the event loop (UI stays responsive)
3. **Resumes** the function when the Future completes

```
Main starts
↓
fetchUser() called
↓
Hit `await` → function paused, control returns to event loop
↓
[UI frames render, touch events process — 60fps maintained]
↓
Future completes → function resumes from where it paused
↓
Return value available
```

### Internal Future Lifecycle

```dart
Future<void> loadData() async {
  print("Start");       // 1. Runs immediately
  final data = await fetchData();  // 2. Pauses here
  print(data);          // 3. Runs after future completes
}
```

---

## Error Handling

### ❌ BAD — Silent crash

```dart
await apiCall();  // If this throws, the exception propagates unhandled
```

### ✅ GOOD — Production pattern

```dart
try {
  final result = await apiCall();
  // Use result
} catch (e, stackTrace) {
  // e = the exception object
  // stackTrace = where in the code it happened
  debugPrint('Error: $e');
  debugPrint('Stack: $stackTrace');
  // Show user-friendly error message
}
```

**Why is async error handling harder?**

- Async errors can occur AFTER a widget has been disposed
- They surface on a different execution frame than where they were triggered
- Unhandled Future errors fail silently in release builds

---

## The `mounted` Check

This is one of the most common bugs in Flutter applications.

### ❌ DANGEROUS — State set after widget disposed

```dart
await apiCall();
setState(() {});  // Widget may already be removed from tree!
```

### ✅ CORRECT — Always check `mounted`

```dart
await apiCall();

// mounted is a property of State that returns false
// if the widget has been removed from the widget tree
if (!mounted) return;

setState(() {});
```

**Why does this happen?**

When a user navigates away while an API call is in flight, the widget gets disposed. But the async callback still runs and tries to call `setState()` on a disposed widget → exception.

---

## FutureBuilder

`FutureBuilder` rebuilds your widget automatically based on the state of a `Future`.

### Full Pattern

```dart
FutureBuilder<String>(
  future: _myFuture, // must be stored in state, NOT created in build()
  builder: (context, snapshot) {
    // snapshot.connectionState tells you the phase
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    return Text(snapshot.data ?? '');
  },
)
```

### 🔥 CRITICAL Production Warning

```dart
// ❌ NEVER DO THIS — creates a NEW future on every rebuild
FutureBuilder(
  future: apiCall(), // apiCall() is called again on every rebuild!
)

// ✅ CORRECT — future is created ONCE
late Future<String> _future;

@override
void initState() {
  super.initState();
  _future = apiCall(); // created once, reused on every rebuild
}

// In build():
FutureBuilder(
  future: _future, // stable reference
)
```

**Why?** Flutter frequently rebuilds widgets. If you call `apiCall()` inside `build()`, every rebuild triggers a new network request → infinite loop → performance disaster.

In this module, we solve this in the ViewModel: `FutureDemoViewModel` creates the future once in its constructor.

---

## Streams

A `Stream<T>` emits **multiple values over time** — perfect for real-time data.

| Feature | Future | Stream |
|---|---|---|
| Emits | Once | Multiple times |
| Use case | API call | Real-time updates |
| Completion | After one value | After many values (or never) |

### Real-World Stream Examples

| System | Stream |
|---|---|
| Firebase Realtime Database | ✅ |
| Chat messages | ✅ |
| GPS location | ✅ |
| WebSocket | ✅ |
| Sensors (accelerometer) | ✅ |

### Creating a Stream with `async*`

```dart
Stream<int> counterStream() async* {
  // async* marks this as an "asynchronous generator"
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i; // 'yield' pushes a value into the stream
  }
  // After the loop ends, the stream is DONE
}
```

---

## StreamBuilder

`StreamBuilder` is to Streams what `FutureBuilder` is to Futures — it rebuilds the widget on every new stream value.

```dart
StreamBuilder<int>(
  stream: counterStream(),
  builder: (context, snapshot) {
    // ConnectionState lifecycle:
    // none → waiting → active → active → active → done

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.connectionState == ConnectionState.done) {
      return const Text('Stream completed!');
    }

    return Text('Count: ${snapshot.data}');
  },
)
```

### Single Subscription vs Broadcast

```dart
// Single Subscription (default):
// - Only ONE listener allowed
// - Throws StateError if a second listener subscribes
Stream<int> single = counterStream();

// Broadcast:
// - Multiple listeners allowed
// - Each listener receives all future events
Stream<int> broadcast = counterStream().asBroadcastStream();
```

---

## Memory Leaks with Streams

This is the #1 cause of memory leaks in Flutter apps.

### ❌ DANGEROUS — Subscription never cancelled

```dart
class MyWidget extends StatefulWidget { ... }

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    stream.listen((value) {
      setState(() { _data = value; });
    });
    // No reference kept → can NEVER cancel!
    // Stream callbacks fire even after widget is disposed
  }
}
```

### ✅ CORRECT — Cancel in dispose()

```dart
class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<int> _subscription; // Store the handle

  @override
  void initState() {
    super.initState();
    _subscription = stream.listen((value) {
      setState(() { _data = value; });
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel before freeing memory
    super.dispose();
  }
}
```

In this module, the `StreamDemoViewModel` owns the `StreamSubscription` and cancels it in `dispose()`. The `StreamCounterScreen` calls `_viewModel.dispose()` in its own `dispose()`, completing the chain safely.

---

## Parallel Futures — `Future.wait`

### Sequential (slow)

```dart
// B cannot start until A finishes
final user  = await fetchUser();   // 1.5 seconds
final posts = await fetchPosts();  // 2.0 seconds
// Total: 3.5 seconds
```

### Parallel (fast)

```dart
// Both start simultaneously
final results = await Future.wait([
  fetchUser(),   // starts at t=0
  fetchPosts(),  // ALSO starts at t=0
]);
// Total: 2.0 seconds (max of both, not sum)
final user  = results[0] as AppUser;
final posts = results[1] as List<PostSummary>;
```

### When to use each

| Pattern | Use When |
|---|---|
| Sequential | Operation B needs A's result |
| Parallel | Operations are completely independent |

> **⚠️ Warning:** If ANY future in `Future.wait()` fails, the entire wait fails immediately. Use `eagerError: false` or individual try/catch blocks if you want partial results on failure.

---

## Production Architecture

Async code belongs in the **repository** and **ViewModel** layers — NEVER in widgets.

```
┌─────────────────────────────────────────────┐
│  UI Layer (Views)                           │
│  • FutureBuilder / StreamBuilder            │
│  • Shows loading / error / data states      │
│  • Dispatches user actions to ViewModel     │
└────────────────────┬────────────────────────┘
                     │ reads state, calls methods
┌────────────────────▼────────────────────────┐
│  ViewModel (ChangeNotifier)                 │
│  • Owns Future/Stream references            │
│  • Manages StreamSubscription lifecycle     │
│  • Calls repository, maps results to state  │
│  • notifyListeners() to update UI           │
└────────────────────┬────────────────────────┘
                     │ calls service methods
┌────────────────────▼────────────────────────┐
│  Repository / Service                       │
│  • Makes actual API calls / DB queries      │
│  • Returns Future<T> or Stream<T>           │
│  • Has NO knowledge of Flutter or UI        │
└─────────────────────────────────────────────┘
```

---

## Module File Map

```
lib/async_programming/
│
├── main.dart                                   ← Module entry point
│
├── core/
│   ├── models/
│   │   └── user_post.dart                     ← Data models (UserPost, AppUser, etc.)
│   └── services/
│       └── mock_api_service.dart              ← Simulated API + Stream source
│
└── presentation/
    ├── viewmodels/
    │   ├── future_demo_viewmodel.dart         ← Task 1 business logic
    │   ├── stream_demo_viewmodel.dart         ← Task 2 business logic
    │   └── parallel_demo_viewmodel.dart       ← Task 3 business logic
    └── views/
        ├── async_home_screen.dart             ← Module navigation hub
        ├── future_builder_screen.dart         ← Task 1: FutureBuilder
        ├── stream_counter_screen.dart         ← Task 2: StreamBuilder
        └── parallel_async_screen.dart         ← Task 3: Future.wait
```

---

## Assignments Implemented

### Task 1 — FutureBuilder Screen (`future_builder_screen.dart`)

**Requirements:** loading ✅ | success ✅ | error ✅ | retry button ✅

Key patterns demonstrated:
- Future created once in ViewModel constructor (not in `build()`)
- `FutureBuilder` consuming the stable future reference
- `ConnectionState.waiting` → loading indicator
- `snapshot.hasError` → error card with retry button
- Retry replaces the future reference → `FutureBuilder` restarts cleanly
- Error simulation toggle via AppBar switch

### Task 2 — Live Counter Stream (`stream_counter_screen.dart`)

**Requirements:** StreamBuilder ✅ | start/stop ✅ | proper disposal ✅

Key patterns demonstrated:
- `Stream<int>` created with `async*` / `yield`
- Single-subscription → broadcast conversion with `.asBroadcastStream()`
- `StreamSubscription` owned by ViewModel, cancelled in `dispose()`
- `StreamBuilder` reacts to each emitted value
- `ConnectionState.none → waiting → active → done` lifecycle visible in UI
- Animated counter with `ScaleTransition` pulse on each tick

### Task 3 — Sequential vs Parallel (`parallel_async_screen.dart`)

**Requirements:** demonstrate sequential async ✅ | parallel async ✅ | time measurement ✅

Key patterns demonstrated:
- Sequential: `await A; await B;` → total time = A + B (~3.5s)
- Parallel: `await Future.wait([A, B])` → total time = max(A, B) (~2.0s)
- `Stopwatch` measuring real wall-clock time
- Side-by-side result panels showing measured time
- Savings banner showing exact ms difference and percentage improvement
- Code comparison card with annotated snippets
- Usage guide explaining when to use each pattern


