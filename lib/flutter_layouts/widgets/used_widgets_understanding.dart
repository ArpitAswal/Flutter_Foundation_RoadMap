/// 1. Column Widget

/*

Column(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisSize: MainAxisSize.max,
  verticalDirection: VerticalDirection.down,
  textDirection: TextDirection.ltr,
  children: [],
)

What each does

| Property           | Meaning                  |
| ------------------ | ------------------------ |
| mainAxisAlignment  | Vertical alignment       |
| crossAxisAlignment | Horizontal alignment     |
| mainAxisSize       | Take full height or wrap |
| verticalDirection  | Reverse layout           |
| textDirection      | Affects alignment        |

*/

/// 2. Row Widget

/*

Same as Column, just axis change

| Axis       | Meaning    |
| ---------- | ---------- |
| Main axis  | Horizontal |
| Cross axis | Vertical   |

 */

/// 3. Expanded VS Flexible

/*

Expanded(
  flex: 2,
  child: Container(),
)
--> Takes all available space (Either horizontally or vertically)

Flexible(
  fit: FlexFit.loose,
  child: Container(),
)
--> Takes as much space as needed (Either horizontally or vertically) and Can shrink if needed.

Key Difference

| Feature          | Expanded | Flexible |
| ---------------- | -------- | -------- |
| Fill space       | Always   | Optional |
| Overflow control | Strict   | Flexible |

 */

/// 4. Flex Widget

/*

Flex(
  direction: Axis.horizontal,
  children: [],
)

When using Flex, you must define how it behaves along its two axes:
1. Direction: Sets the main axis (Axis.horizontal or Axis.vertical).
2. MainAxisAlignment: Controls how children are positioned along the main axis (e.g., start, center, spaceBetween).
3. CrossAxisAlignment: Controls how children are positioned along the perpendicular axis.

When to Use?
. Dynamic axis layouts
. Advanced UI systems
. Space Distribution with Flexible & Expanded

When not to Use?
. Static Orientation
. Wrapping Content
. Large Lists
 */

/// 5. List View

/*

ListView is the most commonly used scrolling widget. It displays its children one after another in the scroll direction (typically vertical).

ListView Types-

1. Basic ListView (The Default Constructor)
The default ListView constructor is essentially a "static" list. You pass a hardcoded list of widgets to its children property.

2. ListView.builder (The Efficient Constructor)
While the basic ListView creates all items at once, the builder constructor uses on-demand rendering. It only creates the widgets that are actually visible on the screen. As the user scrolls, it recycles memory and builds new items, making it incredibly performant.

3. ListView.separated (The Organized Constructor)
This is a specialized version of the builder. It’s exactly like ListView.builder, but it includes an extra callback to place a widget (like a line or a label) between each item.

When to Use vs. When Not to Use

1. Basic ListView
Use it when:
. Small, Fixed Sets of Data: You have a small number of items (e.g., a settings menu with 10 options).
. Static Content: The items aren't coming from an API or a huge database.
. Diverse Content: You want to mix different types of widgets (a header, then a few tiles, then an image) easily.
Do NOT use it when:
. Large or Infinite Lists: The default ListView constructor renders all children at once, even those off-screen. If you have 1,000 items, your app's performance will tank because it tries to build all 1,000 widgets immediately.
. Dynamic Data: If your list changes size constantly based on user input or a database, the .builder or .separated versions are much more efficient.

2. ListView.builder
Use it when:
. Large Lists: You have hundreds or thousands of items.
. Dynamic/API Data: You are displaying data from a database or a network call where the length isn't known until runtime.
. Infinite Scrolling: You want to keep loading more items as the user reaches the bottom.
Do NOT use it when:
. Small, Static Content: If you only have 3 or 4 unique items (like a "Profile," "Settings," and "Logout" button), using a builder is overkill and adds unnecessary complexity.
. Varying Item Types without Logic: If every single item in the list is a completely different widget type (not just different data), a basic ListView is easier to manage.

3. ListView.separated
Use it when:
. Divided Lists: You need dividers, spacers, or even small "Ad" banners between items in a dynamic list.
. Standardized Spacing: You want to ensure consistent visual separation without adding padding inside your item widgets.
Do NOT use it when:
. No Dividers Needed: If your design doesn't require a visual break between items, stick to ListView.builder.
. Items are self-separating: If your items already have their own margins or borders that handle the spacing, the separatorBuilder is redundant.

 */

/// SingleChildScrollView (Scrolling)

/*

SingleChildScrollView is the go-to solution when you have a single block of content that might not fit on smaller screens.

Think of it as a "scrollable wrapper." You use it when you have a fixed layout (like a form or a long article) that needs to be scrollable if the device screen is too short.

SingleChildScrollView(
  child: Column(
    children: [
      SizedBox(height: 300),
    ],
  ),
)

When to Use vs. When Not to Use

Use it when:
. Forms: Perfect for registration or login screens where the keyboard might pop up and cover your input fields, causing an "Overflow" error.
. Static Pages: For "About Us" pages, settings screens, or long articles where the content is a fixed layout rather than a repeating list.
. Small Content: When you have content that fits on a tablet but might need to scroll on a small phone.

Do NOT use it when:
. Infinite/Large Lists: Since it doesn't have a "builder" mechanism, it loads everything in its child widget immediately. If you put 100 items in a Column inside a SingleChildScrollView, you'll face the same performance lag as a basic ListView.
. Dynamic Data Sets: If your data is coming from a list/array, ListView.builder is always the better choice for memory management.

*/