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
