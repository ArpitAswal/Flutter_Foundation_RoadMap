# 🧭 Flutter Navigation & Routing

Navigation is the backbone of any application, but without structure, it quickly becomes unmaintainable. This module transitions you from basic button clicks to a **scalable, production-grade routing system**.

## 🧠 Core Concepts: The Mental Model

Flutter provides two primary navigation models:

| Model | Name | Use Case |
| :--- | :--- | :--- |
| **Imperative** | Navigator 1.0 | Small/Medium apps, quick MVPs, simple flows. |
| **Declarative** | Navigator 2.0 | Complex apps, Web support, Deep Linking, State-driven UI. |

### The Navigator Stack
Imagine a stack of papers:
- **`push()`**: Add a new screen on top.
- **`pop()`**: Remove the top screen to reveal the one below.
- **Stack Flow**: `Home` → `Details` → `Checkout`

---

## 🏗️ Navigator 1.0: The Production Standard (Imperative)

Most production apps today still rely on Navigator 1.0 because of its simplicity and ease of use.

### 1. Basic Navigation
```dart
// Push a screen
Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailsScreen()));

// Pop a screen
Navigator.pop(context);

// Pass Data
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(name: "Arpit")));
```

### 2. Returning Data (Crucial)
```dart
// Parent Screen
final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectionScreen()));

// Child Screen
Navigator.pop(context, "Selected Value");
```

### 3. Scalable Architecture (onGenerateRoute)
Avoid hardcoding `Navigator.push` everywhere. Instead, centralize your routing:

- **Route Manager**: Define all paths in `AppRoutes`.
- **Route Generator**: Handle logic in `AppRouter.generateRoute`.
- **MaterialApp**: Hook it up using `onGenerateRoute`.

---

## 🚀 GoRouter: The Industry Standard (Declarative)

GoRouter is a powerful wrapper around Navigator 2.0 that simplifies complex routing scenarios like deep linking and nested navigation.

---

## 📖 The Complete Navigation API Cheat Sheet

Understanding *when* to use which method is the difference between a smooth user experience and a broken navigation stack.

### 1. Navigator 1.0 (Imperative)
| Method | Description | Use Case |
| :--- | :--- | :--- |
| **`push()`** | Adds a screen to the top of the stack. | Navigating to a details page. |
| **`pushNamed()`** | Adds a screen using its registered name. | Standard production navigation. |
| **`pushReplacement()`** | Replaces the current screen with a new one. | Login → Dashboard (No back button to login). |
| **`pushReplacementNamed()`** | Same as above, but using a route name. | Production version of replacement. |
| **`pushNamedAndRemoveUntil()`** | Clears the stack until a condition is met, then pushes. | Logout → Login (Clears all user history). |
| **`pop()`** | Removes the top screen from the stack. | Going back or closing a dialog. |
| **`popAndPushNamed()`** | Pops current and immediately pushes a new one. | Switching between similar screens. |
| **`canPop()` / `maybePop()`** | Checks if there's a screen to go back to. | Preventing app exit on back button. |

### 2. GoRouter (Declarative)
| Method | Description | Use Case |
| :--- | :--- | :--- |
| **`context.push()`** | Adds a new location to the stack. | Standard "drill-down" navigation. |
| **`context.go()`** | **Declarative**: Rebuilds the stack to match the target path. | Switching tabs or deep linking. |
| **`context.pushReplacement()`** | Replaces the current location in the stack. | Splash screen → Home. |
| **`context.replace()`** | Replaces the current route without adding to history. | Updating query params or state. |
| **`context.pushNamed()`** | Pushes a route using its unique name. | If using named routes in GoRouter. |
| **`context.pop()`** | Returns to the previous location. | Traditional "back" action. |
| **`context.canPop()`** | Returns true if there is a route to pop. | Safety checks before popping. |

---

## 🛠️ Data Flow & Advanced Features (Production Essentials)

### 1. Passing Data & Parameters
*   **Path Parameters**: `/details/:id` → `state.pathParameters['id']`
*   **Query Parameters**: `/details?name=arpit` → `state.uri.queryParameters['name']`
*   **Extra**: `context.push(path, extra: object)` → Pass complex models directly.

### 2. Advanced Features
*   **ShellRoute**: Wraps sub-routes with a persistent UI (e.g., a Bottom Navigation Bar that doesn't disappear).
*   **Auth Guards**: Use the `redirect` function to protect routes (e.g., redirecting to `/login` if not authenticated).
*   **Deep Linking**: GoRouter is URL-driven, meaning `myapp://profile/123` works natively. **Navigation = State**.

---

## 📊 The Comparison Matrix

| Feature | Navigator 1.0 | Navigator 2.0 (Raw) | GoRouter |
| :--- | :--- | :--- | :--- |
| **Type** | Imperative | Declarative | Declarative Wrapper |
| **Learning Curve** | Easy | Hard | Medium |
| **Deep Linking** | Hard | Native Support | Easy |
| **Web Support** | Limited | Full | Full |
| **Code Complexity** | Low | High | Clean & Modular |

---

## ⚠️ Common Mistakes & Fixes

| Mistake | The Fix |
| :--- | :--- |
| Using `push` for everything | Use `go` when you need to reset or replace the stack. |
| Passing raw data strings | Use **Models** to ensure type safety. |
| Mixing Navigator & GoRouter | Stick to one system per feature area to avoid stack confusion. |
| Hardcoded paths | Use a centralized naming strategy (static constants/methods). |

---

## 🎤 Interview Preparation

### Navigator 1.0 Focus
**Q: Why use `onGenerateRoute`?**
> A: It centralizes navigation logic, allows for dynamic route generation, and simplifies passing complex arguments.

**Q: Difference between `push` and `pushReplacement`?**
> A: `push` adds a screen to the stack; `pushReplacement` removes the current screen and adds the new one, preventing the user from going back to the previous screen.

### GoRouter Focus
**Q: What is a `ShellRoute`?**
> A: It's a way to provide a persistent layout (like a Bottom Bar) that wraps multiple sub-routes without rebuilding the layout on every transition.

**Q: Why is GoRouter preferred for Web?**
> A: It handles browser history, back buttons, and URL synchronization natively, treating the URL as the "Source of Truth."

**Q: How do you handle authentication redirects?**
> A: By using the `redirect` property in the `GoRouter` configuration to check the app's auth state before every navigation event.

---

## 🛠️ Folder Structure Reference
```text
lib/navigation_routes/
├── core/
│   ├── app_routes.dart      # Navigator 1.0 Constants
│   ├── app_router.dart      # Navigator 1.0 Generator
│   └── app_go_router.dart   # GoRouter Configuration (ShellRoute, Guards)
├── screens/
│   ├── home_screen.dart     # Navigator 1.0 Examples
│   ├── go_home_screen.dart  # GoRouter Examples
│   └── ...                  # Shared & Feature Screens
└── main.dart                # Dual-Demo Entry Point
```
