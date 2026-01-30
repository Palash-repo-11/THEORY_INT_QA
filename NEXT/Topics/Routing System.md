# 📘 Next.js Catch‑All Routing – Real‑World Guide

This document explains **`[...slug]`** and **`[[...slug]]`** in **Next.js App Router** with **real‑world use cases**, architecture decisions, and production‑style code examples.

---

## 📌 Prerequisites

* Next.js **13+ App Router**
* Basic understanding of file‑based routing
* Familiarity with React Server Components

---

# 1️⃣ Catch‑All Routes `[...slug]`

## 🧠 What it is

A **catch‑all route** matches **one or more URL segments**.

```txt
/docs/react
/docs/react/hooks
/docs/react/hooks/useEffect
```

⚠️ `/docs` **does NOT work**.

---

## ✅ Real‑World Use Case: Documentation System

Used by:

* Framework docs (Next.js, React)
* API references
* Knowledge bases

Each section can be nested infinitely.

---

## 📁 Folder Structure

```txt
app/
 └─ docs/
    └─ [...slug]/
       └─ page.tsx
```

---

## 🔗 URL Mapping

| URL                         | params.slug                     |
| --------------------------- | ------------------------------- |
| /docs/react                 | ["react"]                       |
| /docs/react/hooks           | ["react", "hooks"]              |
| /docs/react/hooks/useEffect | ["react", "hooks", "useEffect"] |

---

## 🧩 Real‑World Code Example

```tsx
// app/docs/[...slug]/page.tsx

type DocsMap = Record<string, string>;

const docsContent: DocsMap = {
  "react": "React Introduction",
  "react/hooks": "React Hooks Overview",
  "react/hooks/useEffect": "useEffect Deep Dive",
};

export default function DocsPage({ params }: { params: { slug: string[] } }) {
  const path = params.slug.join("/");
  const content = docsContent[path];

  if (!content) {
    return <h1>404 – Documentation Not Found</h1>;
  }

  return (
    <article>
      <h1>{path}</h1>
      <p>{content}</p>
    </article>
  );
}
```

---

## 🎯 Why `[...slug]` is Ideal Here

* Enforces at least one path segment
* Supports unlimited nesting
* Clean URL structure
* Scales well with MDX/static docs

---

# 2️⃣ Optional Catch‑All Routes `[[...slug]]`

## 🧠 What it is

Matches **zero or more segments**.

```txt
/blog
/blog/react
/blog/react/useEffect
```

`params.slug` may be **undefined**.

---

## ✅ Real‑World Use Case: Blog System

Used by:

* Medium‑style blogs
* Dev.to‑like platforms
* Marketing sites

One page handles:

* Blog home
* Category
* Individual post

---

## 📁 Folder Structure

```txt
app/
 └─ blog/
    └─ [[...slug]]/
       └─ page.tsx
```

---

## 🔗 URL Mapping

| URL                   | params.slug            |
| --------------------- | ---------------------- |
| /blog                 | undefined              |
| /blog/react           | ["react"]              |
| /blog/react/useEffect | ["react", "useEffect"] |

---

## 🧩 Real‑World Code Example

```tsx
// app/blog/[[...slug]]/page.tsx

export default function BlogPage({ params }: { params: { slug?: string[] } }) {
  // Blog Home
  if (!params.slug) {
    return (
      <section>
        <h1>Blog Home</h1>
        <p>Latest articles...</p>
      </section>
    );
  }

  // Category Page
  if (params.slug.length === 1) {
    return <h1>Category: {params.slug[0]}</h1>;
  }

  // Blog Post Page
  if (params.slug.length === 2) {
    const [category, post] = params.slug;
    return <h1>{post} (Category: {category})</h1>;
  }

  return <h1>Invalid Blog Route</h1>;
}
```

---

## 🎯 Why `[[...slug]]` is Ideal Here

* Single page handles all blog routes
* No duplicated components
* Cleaner architecture
* SEO‑friendly URLs

---

# 🔥 `[...slug]` vs `[[...slug]]`

| Feature     | `[...slug]`   | `[[...slug]]`      |
| ----------- | ------------- | ------------------ |
| Base route  | ❌ Not allowed | ✅ Allowed          |
| params.slug | Always array  | Array or undefined |
| Best use    | Docs, APIs    | Blogs, marketing   |

---

## 🧠 Interview‑Ready Explanation

> Use **`[...slug]`** when at least one path segment is mandatory, such as documentation systems.
>
> Use **`[[...slug]]`** when both the base route and nested routes should be handled by the same page, such as blogs.

---

## 🚀 Next Topics You Can Add

* MDX integration with slugs
* `generateStaticParams`
* SEO metadata from slug
* Dynamic breadcrumbs
* CMS‑driven routing (Notion / Sanity)

---

**End of document**




# 🧭 How Next.js Routing Works Internally (App Router)

This document explains **what happens internally in Next.js when a user requests a URL**, focusing on **Next.js 13+ App Router**. It covers routing, rendering, data fetching, streaming, and client-side navigation — step by step.

---

## 🧠 High-Level Flow

When a user visits a URL like:

```
https://example.com/blog/42?tab=comments
```

Next.js performs the following major steps:

1. Receives the HTTP request
2. Matches the request path to a filesystem route
3. Executes middleware (if any)
4. Resolves layouts and route segments
5. Renders Server Components
6. Streams HTML and RSC payload
7. Hydrates Client Components

---

## 1️⃣ Request Hits the Next.js Server

Depending on the deployment environment:

| Environment | Request Handler            |
| ----------- | -------------------------- |
| Vercel      | Edge Function / Serverless |
| Self-hosted | Node.js server             |
| `next dev`  | Dev Node server            |

Before routing, Next.js checks:

* Middleware
* Static asset cache
* Route manifest

---

## 2️⃣ File-System Route Matching

Next.js uses **file-based routing**. There is **no route configuration file**.

### Example Directory Structure

```
app/
 ├─ blog/
 │   └─ [id]/
 │       └─ page.tsx
 └─ layout.tsx
```

### Request: `/blog/42`

Internal steps:

1. URL path split → `["blog", "42"]`
2. Folder traversal starts from `app/`
3. Matches:

   * `blog` → static segment
   * `[id]` → dynamic segment
4. Params extracted:

```ts
params = { id: "42" }
```

> 📌 Dynamic routes are compiled into efficient matchers during build time.

---

## 3️⃣ Middleware Execution (Optional)

If `middleware.ts` exists:

```ts
export function middleware(req: NextRequest) {
  // auth, rewrite, redirect
}
```

Middleware runs **before rendering** and can:

* Redirect
* Rewrite paths
* Block requests

Usually executed on the **Edge Runtime**.

---

## 4️⃣ Layout & Route Segment Resolution

For `/blog/42`, Next.js resolves:

```
app/layout.tsx
app/blog/layout.tsx (if exists)
app/blog/[id]/page.tsx
```

Each folder is a **route segment**.

### Segment Tree (Internal)

```
RootLayout
 └─ BlogLayout
     └─ BlogPage (id=42)
```

This tree is rendered as **React Server Components (RSC)**.

---

## 5️⃣ Server vs Client Components

Next.js determines execution environment per component:

| Component Type             | Runs On |
| -------------------------- | ------- |
| Server Component (default) | Server  |
| `"use client"`             | Browser |

Server Components:

* Execute first
* Fetch data securely

Client Components:

* Converted into placeholders
* Hydrated later in the browser

---

## 6️⃣ Data Fetching & Caching

Example:

```ts
await fetch("/api/post/42", { cache: "force-cache" })
```

Next.js:

* Intercepts `fetch`
* Applies caching rules
* Supports ISR via `revalidate`

Cache keys are derived from:

* URL
* Headers
* Route params
* Segment boundaries

---

## 7️⃣ Rendering Strategy Decision

Next.js automatically decides how to render:

| Condition         | Strategy     |
| ----------------- | ------------ |
| No dynamic data   | Static (SSG) |
| `revalidate` used | ISR          |
| Cookies / headers | Dynamic SSR  |
| Edge compatible   | Edge SSR     |

---

## 8️⃣ Streaming HTML (App Router Superpower 🚀)

Rendering is **streamed**, not blocking.

Flow:

1. HTML shell sent immediately
2. Server Components streamed
3. RSC payload (`__next_flight__`) sent
4. Browser progressively renders UI

This enables faster TTFB and perceived performance.

---

## 9️⃣ Client-Side Hydration

In the browser:

1. HTML is already visible
2. JS bundles load
3. Client Components hydrate
4. Router becomes interactive

Hooks become active:

* `useRouter`
* `useParams`
* `useSearchParams`

---

## 🔁 Client-Side Navigation (`next/link`)

```tsx
<Link href="/blog/43" />
```

What happens:

1. Full page reload is prevented
2. Only RSC payload is requested
3. Segment tree is updated
4. Shared layouts are preserved
5. Only changed components re-render

> 💡 This is why layouts don’t remount on navigation.

---

## 🆚 Pages Router vs App Router

| Pages Router         | App Router          |
| -------------------- | ------------------- |
| `pages/index.tsx`    | `app/page.tsx`      |
| `getServerSideProps` | Server Components   |
| Full page render     | Partial tree render |
| No streaming         | Streaming           |
| Client-first         | Server-first        |

---

## 🧠 Interview One-Liner

> When a user requests a path, Next.js matches it against a build-time route manifest, resolves layouts and segments, executes Server Components on the server, streams HTML and RSC payloads, and hydrates only Client Components — enabling fast, cached, and partial navigation.

---

## ✅ Key Takeaways

* Routing is filesystem-based
* App Router is server-first
* Layouts persist across navigation
* Streaming improves performance
* Only changed segments re-render

---

📌 **Recommended for:**

* Interviews
* System design discussions
* Debugging routing & rendering issues
* Understanding performance optimizations
