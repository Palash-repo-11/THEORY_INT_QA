# Next.js Rendering Strategies - Complete Guide

## Table of Contents
1. [Introduction to Rendering Types](#introduction-to-rendering-types)
2. [Detailed Explanation of Each Strategy](#detailed-explanation-of-each-strategy)
3. [SSR vs SSG: Key Differences](#ssr-vs-ssg-key-differences)
4. [How Next.js Determines Rendering Strategy](#how-nextjs-determines-rendering-strategy)

---

## Introduction to Rendering Types

### Overview
* **CSR** (Client Side Rendering)
* **SSR** (Server Side Rendering)
* **SSG** (Static Site Generation)
* **ISR** (Incremental Static Regeneration)

---

# Detailed Explanation of Each Strategy

## CSR (Client-Side Rendering)

### How it works:
The server sends a minimal HTML shell to the browser, and JavaScript runs on the client to fetch data and render the content. This is the traditional React approach.

### In Next.js:
```javascript
'use client'
import { useState, useEffect } from 'react'

export default function UserProfile() {
  const [user, setUser] = useState(null)
  
  useEffect(() => {
    fetch('/api/user')
      .then(res => res.json())
      .then(data => setUser(data))
  }, [])
  
  if (!user) return <div>Loading...</div>
  return <div>{user.name}</div>
}
```

### When to use:
- Highly interactive dashboards or apps
- Pages behind authentication where SEO doesn't matter
- Real-time data that changes frequently
- When you need access to browser APIs

### Pros:
- Rich interactivity
- Reduces server load
- Great for dynamic, personalized content

### Cons:
- Slower initial page load
- Poor SEO (content not in initial HTML)
- Blank screen while JavaScript loads
- Not great for users with slow connections

---

## SSR (Server-Side Rendering)

### How it works:
The HTML is generated on the server for each request. The server fetches data, renders the page, and sends fully formed HTML to the client.

### In Next.js:
```javascript
// App Router (Next.js 13+)
async function getUser() {
  const res = await fetch('https://api.example.com/user', {
    cache: 'no-store' // This makes it SSR
  })
  return res.json()
}

export default async function UserProfile() {
  const user = await getUser()
  return <div>{user.name}</div>
}
```

### When to use:
- Content that changes frequently
- Personalized content based on cookies/headers
- SEO-critical pages with dynamic data
- Real-time data displays (stock prices, news feeds)

### Pros:
- Great SEO (full HTML sent to crawlers)
- Fast initial page render
- Works without JavaScript enabled
- Always fresh data

### Cons:
- Slower response times (server must render each request)
- Higher server costs and load
- Increased latency for users far from server
- Can't cache the response easily

---

## SSG (Static Site Generation)

### How it works:
Pages are pre-rendered at build time. HTML is generated once and reused for every request until you rebuild.

### In Next.js:
```javascript
// App Router - default behavior for pages without dynamic data
export default async function BlogPost() {
  const posts = await fetch('https://api.example.com/posts')
    .then(res => res.json())
  
  return (
    <div>
      {posts.map(post => (
        <article key={post.id}>{post.title}</article>
      ))}
    </div>
  )
}

// For dynamic routes
export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts')
    .then(res => res.json())
  
  return posts.map(post => ({
    slug: post.slug
  }))
}
```

### When to use:
- Blogs, documentation, marketing sites
- Content that doesn't change often
- Landing pages
- E-commerce product pages (if products don't change frequently)

### Pros:
- Blazing fast (just serving HTML files)
- Best SEO possible
- Low server costs
- Can be served from CDN globally
- Very scalable

### Cons:
- Build times increase with more pages
- Data can become stale
- Need to rebuild to update content
- Not suitable for user-specific content

---

## ISR (Incremental Static Regeneration)

### How it works:
Combines SSG and SSR. Pages are statically generated, but they can be regenerated in the background after a specified interval while serving the stale version.

### In Next.js:
```javascript
// App Router
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 60 } // Revalidate every 60 seconds
  })
  return res.json()
}

export default async function Blog() {
  const posts = await getPosts()
  return <div>{posts.map(post => <article key={post.id}>{post.title}</article>)}</div>
}

// Or using revalidatePath/revalidateTag for on-demand revalidation
```

### When to use:
- E-commerce sites with thousands of products
- News sites with frequent updates
- Blogs with regular new content
- Any site where you want SSG speed but fresher data

### Pros:
- Fast like SSG
- Content stays relatively fresh
- Scales to millions of pages
- Low server load (regenerates only when needed)
- Can revalidate on-demand

### Cons:
- First user after revalidation interval gets stale data
- Complexity in understanding when pages regenerate
- Potential for serving stale content
- Cache invalidation can be tricky

---

## Comparison Table

| Feature | CSR | SSR | SSG | ISR |
|---------|-----|-----|-----|-----|
| **SEO** | Poor | Excellent | Excellent | Excellent |
| **Performance** | Slow initial | Medium | Fastest | Fast |
| **Freshness** | Always fresh | Always fresh | Stale | Mostly fresh |
| **Server Load** | Low | High | Minimal | Low |
| **Build Time** | Fast | N/A | Can be slow | Can be slow |
| **Scalability** | Excellent | Poor | Excellent | Excellent |

---

## Modern Next.js Approach (App Router)

Next.js 13+ with the App Router uses a more nuanced system:

- **Static by default**: Components are static unless they use dynamic functions
- **Automatic optimization**: Next.js chooses the best strategy
- **Streaming**: Combine static and dynamic parts in the same page

```javascript
// This page mixes static and dynamic content
export default async function Dashboard() {
  // Static content (generated at build)
  const stats = await getStats()
  
  return (
    <div>
      <StaticHeader stats={stats} />
      {/* Dynamic content (rendered per request) */}
      <Suspense fallback={<Loading />}>
        <DynamicUserData />
      </Suspense>
    </div>
  )
}
```

---

# SSR vs SSG: Key Differences

## The Core Difference

**SSG (Static Site Generation):**
- HTML is generated **once at build time**
- The same pre-built HTML file is served to every user
- Like baking bread in advance and serving it from the shelf

**SSR (Server-Side Rendering):**
- HTML is generated **on every request**
- Fresh HTML is created for each user when they visit
- Like baking fresh bread for each customer who walks in

---

## Timing: When Does Rendering Happen?

### SSG
```
Developer runs: npm run build
      ↓
Next.js generates HTML for all pages
      ↓
HTML files stored on server/CDN
      ↓
User requests page → Instant HTML delivery (already exists)
```

### SSR
```
User requests page
      ↓
Server receives request
      ↓
Server fetches data & renders HTML
      ↓
HTML sent to user
```

---

## Code Comparison

### SSG Example
```javascript
// This runs ONCE during build
export default async function ProductPage() {
  const product = await fetch('https://api.example.com/product/123')
    .then(res => res.json())
  
  // This HTML is generated at build time
  return (
    <div>
      <h1>{product.name}</h1>
      <p>Price: ${product.price}</p>
    </div>
  )
}
```

**What happens:**
- You run `npm run build`
- Next.js fetches the product data
- Generates an HTML file: `product-123.html`
- Every user gets this exact same HTML file

### SSR Example
```javascript
// This runs on EVERY request
async function getProduct() {
  const res = await fetch('https://api.example.com/product/123', {
    cache: 'no-store' // Forces SSR
  })
  return res.json()
}

export default async function ProductPage() {
  const product = await getProduct()
  
  // This HTML is generated fresh for each request
  return (
    <div>
      <h1>{product.name}</h1>
      <p>Price: ${product.price}</p>
    </div>
  )
}
```

**What happens:**
- User visits the page
- Server fetches current product data
- Server generates HTML with latest data
- Sends HTML to user
- Next user triggers the same process again

---

## Data Freshness

### SSG
```javascript
// Build happens at 9 AM
npm run build
// Product price in DB: $100 → HTML shows $100

// Price changes in DB at 10 AM to $150
// HTML still shows $100 (stale data)

// Until you rebuild...
npm run build  // Now HTML shows $150
```

**Data is frozen at build time**

### SSR
```javascript
// User A visits at 9 AM
// Product price: $100 → User sees $100

// Price changes to $150 at 10 AM

// User B visits at 10:30 AM
// Server fetches current price: $150 → User sees $150
```

**Data is always current**

---

## Performance Implications

### SSG
```
User Request → CDN → Instant HTML (0.01s)
```
- HTML is pre-built, just needs to be transferred
- Can be cached at CDN edge locations worldwide
- **Fastest possible page load**

### SSR
```
User Request → Server → Fetch Data → Render HTML → Send (0.5s)
```
- Server must do work on every request
- Cannot cache the full response (it's dynamic)
- **Slower, but acceptable with good infrastructure**

---

## Real-World Analogy

### SSG = Restaurant Menu Board
- The menu is printed once
- Same menu shown to all customers
- Super fast (just look up)
- Need to reprint if prices change
- Perfect for: content that rarely changes

### SSR = Made-to-Order Food
- Each order prepared fresh
- Customized for each customer
- Takes time to prepare
- Always fresh ingredients
- Perfect for: personalized or frequently changing content

---

## When to Use Each

### Use SSG when:
✅ Content is the same for all users
✅ Content doesn't change frequently
✅ You can rebuild when content changes
✅ Performance is critical
✅ You want to minimize server costs

**Examples:**
- Blog posts
- Documentation
- Marketing landing pages
- About/Contact pages
- Product catalog (if updates are infrequent)

### Use SSR when:
✅ Content is personalized per user
✅ Content changes very frequently
✅ You need real-time data
✅ Content depends on request headers/cookies
✅ You can't predict what pages will be requested

**Examples:**
- User dashboards
- Social media feeds
- Shopping carts
- Search results
- Real-time analytics
- Admin panels

---

## Infrastructure Impact

### SSG
```
Build Time: 10 minutes (for 10,000 pages)
Request Time: 0.01s
Server Load: Minimal (just serving files)
Hosting Cost: Low (can use simple CDN)
```

### SSR
```
Build Time: Fast (no pre-rendering)
Request Time: 0.2-0.5s per request
Server Load: High (processing each request)
Hosting Cost: Higher (need server infrastructure)
```

---

## The Hybrid Approach: ISR

Many real applications use **ISR** (Incremental Static Regeneration) which combines both:

```javascript
async function getProduct() {
  const res = await fetch('https://api.example.com/product/123', {
    next: { revalidate: 3600 } // Revalidate every hour
  })
  return res.json()
}

export default async function ProductPage() {
  const product = await getProduct()
  return <div>{product.name}: ${product.price}</div>
}
```

- Fast like SSG (serves static HTML)
- Fresh like SSR (regenerates periodically)
- Best of both worlds for many use cases

---

## Quick Decision Tree

```
Does content change for each user?
├─ YES → SSR
└─ NO → Does content change frequently?
    ├─ YES → SSR or ISR
    └─ NO → SSG
```

---

# How Next.js Determines Rendering Strategy

## App Router (Next.js 13+) - Modern Approach

Next.js App Router uses a **"static by default"** philosophy.

### Default: SSG (Static)
```javascript
// This is SSG by default
export default async function Page() {
  const data = await fetch('https://api.example.com/data')
  return <div>{data.title}</div>
}
```

### Triggers for SSR (Dynamic Rendering)

Next.js switches to SSR when it detects:

#### 1. Dynamic Functions
```javascript
import { cookies, headers } from 'next/headers'

export default async function Page() {
  // Using cookies() makes this SSR
  const cookieStore = cookies()
  const theme = cookieStore.get('theme')
  
  // Using headers() makes this SSR
  const headersList = headers()
  const userAgent = headersList.get('user-agent')
  
  return <div>Theme: {theme}</div>
}
```

#### 2. Dynamic Segments (useSearchParams, params)
```javascript
import { useSearchParams } from 'next/navigation'

export default function Page() {
  // Using searchParams makes this SSR
  const searchParams = useSearchParams()
  const query = searchParams.get('q')
  
  return <div>Search: {query}</div>
}
```

#### 3. Cache: 'no-store'
```javascript
export default async function Page() {
  // Explicitly telling Next.js: don't cache, always fresh
  const data = await fetch('https://api.example.com/data', {
    cache: 'no-store' // This forces SSR
  })
  
  return <div>{data.title}</div>
}
```

#### 4. Revalidate: 0
```javascript
export default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 0 } // Revalidate on every request = SSR
  })
  
  return <div>{data.title}</div>
}
```

#### 5. Dynamic Route Segment Config
```javascript
// This forces the entire route to be dynamic (SSR)
export const dynamic = 'force-dynamic'

export default async function Page() {
  return <div>Always SSR</div>
}
```

### Visual Decision Flow

```
Next.js analyzes your component
        ↓
Does it use cookies(), headers(), or searchParams()?
├─ YES → SSR
└─ NO → Does fetch use cache: 'no-store'?
    ├─ YES → SSR
    └─ NO → Does it have dynamic = 'force-dynamic'?
        ├─ YES → SSR
        └─ NO → SSG (Static Generation)
```

---

## Pages Router (Next.js 12 and earlier) - Explicit Approach

In the Pages Router, you explicitly tell Next.js what to do by exporting special functions.

### SSG - Export `getStaticProps`
```javascript
// pages/products.js

export default function Products({ products }) {
  return (
    <div>
      {products.map(p => <div key={p.id}>{p.name}</div>)}
    </div>
  )
}

// This function tells Next.js: "Generate this page at build time"
export async function getStaticProps() {
  const res = await fetch('https://api.example.com/products')
  const products = await res.json()
  
  return {
    props: { products } // Pass data to component
  }
}
```

**Next.js sees `getStaticProps` → SSG**

### SSR - Export `getServerSideProps`
```javascript
// pages/dashboard.js

export default function Dashboard({ user }) {
  return <div>Welcome {user.name}</div>
}

// This function tells Next.js: "Generate this page on every request"
export async function getServerSideProps(context) {
  // Access request-specific data
  const { req, res, query } = context
  
  const user = await fetch('https://api.example.com/user', {
    headers: { cookie: req.headers.cookie }
  }).then(r => r.json())
  
  return {
    props: { user }
  }
}
```

**Next.js sees `getServerSideProps` → SSR**

### CSR - No special function
```javascript
// pages/profile.js
import { useState, useEffect } from 'react'

export default function Profile() {
  const [user, setUser] = useState(null)
  
  useEffect(() => {
    fetch('/api/user')
      .then(r => r.json())
      .then(setUser)
  }, [])
  
  return <div>{user?.name}</div>
}

// No getStaticProps or getServerSideProps → CSR
```

**Next.js sees no special export → CSR (Client-Side Rendering)**

---

## How to Check What Next.js Chose

### 1. Build Output
When you run `npm run build`, Next.js tells you:

```bash
Route (app)                              Size     First Load JS
┌ ○ /                                    5 kB           87 kB
├ ○ /about                               3 kB           85 kB
└ ƒ /dashboard                           2 kB           84 kB

○  (Static)  automatically rendered as static HTML
ƒ  (Dynamic) server-rendered on demand
```

**Legend:**
- `○` = SSG (Static)
- `ƒ` = SSR (Dynamic)
- `●` = SSG with data fetching

### 2. In Development
Next.js shows warnings in the console:

```javascript
export const dynamic = 'force-dynamic'

export default function Page() {
  return <div>Content</div>
}
```

**Console output:**
```
⚠ Page /dashboard is using dynamic rendering
```

### 3. Manual Override

You can force a specific behavior:

```javascript
// Force SSG (even if it would normally be SSR)
export const dynamic = 'force-static'

// Force SSR (even if it could be SSG)
export const dynamic = 'force-dynamic'

// Error if page can't be static
export const dynamic = 'error'
```

---

## Complete Examples

### Example 1: Automatic SSG
```javascript
// app/blog/[slug]/page.js

export default async function BlogPost({ params }) {
  const post = await fetch(`https://api.example.com/posts/${params.slug}`)
    .then(r => r.json())
  
  return <article>{post.content}</article>
}

// Tell Next.js which slugs to generate at build time
export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts')
    .then(r => r.json())
  
  return posts.map(post => ({
    slug: post.slug
  }))
}
```

**Next.js decision:** SSG (has `generateStaticParams`)

### Example 2: Automatic SSR
```javascript
// app/search/page.js
import { headers } from 'next/headers'

export default async function SearchResults() {
  // Using headers() triggers SSR
  const headersList = headers()
  const referer = headersList.get('referer')
  
  const results = await fetch('https://api.example.com/search')
    .then(r => r.json())
  
  return <div>{results.map(r => <div key={r.id}>{r.title}</div>)}</div>
}
```

**Next.js decision:** SSR (uses `headers()`)

### Example 3: Mixed Strategy
```javascript
// app/products/page.js

export default async function Products() {
  // This is cached (SSG)
  const categories = await fetch('https://api.example.com/categories')
  
  // This is not cached (SSR)
  const featured = await fetch('https://api.example.com/featured', {
    cache: 'no-store'
  })
  
  return (
    <div>
      <Categories data={categories} />
      <Featured data={featured} />
    </div>
  )
}
```

**Next.js decision:** SSR (because one fetch is dynamic)

---

## Quick Reference Tables

### App Router Signals

| Signal | Result |
|--------|--------|
| Default (nothing special) | SSG |
| `cookies()` | SSR |
| `headers()` | SSR |
| `useSearchParams()` | SSR |
| `cache: 'no-store'` | SSR |
| `revalidate: 0` | SSR |
| `dynamic = 'force-dynamic'` | SSR |
| `dynamic = 'force-static'` | SSG |
| `generateStaticParams()` | SSG |

### Pages Router Signals

| Signal | Result |
|--------|--------|
| `getStaticProps` | SSG |
| `getServerSideProps` | SSR |
| No special function | CSR |
| `getStaticProps` + `revalidate` | ISR |

---

## Summary

### Key Takeaways

1. **SSG renders once at build time** - fastest, but data can be stale
2. **SSR renders on every request** - always fresh, but slower
3. **ISR combines both** - mostly fast, mostly fresh
4. **CSR renders in the browser** - great for interactivity, poor for SEO

### Decision Points

**App Router:** Next.js analyzes your code. If you use dynamic APIs or opt out of caching, it chooses SSR. Otherwise, it defaults to SSG.

**Pages Router:** You explicitly tell Next.js by exporting specific functions.

### The Bottom Line

The beauty of Next.js is that **you don't always need to think about it** - it makes intelligent decisions based on what your code is doing. Choose the strategy that best fits your data freshness needs and performance requirements.

---

## Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [App Router Documentation](https://nextjs.org/docs/app)
- [Data Fetching Guide](https://nextjs.org/docs/app/building-your-application/data-fetching)
- [Rendering Strategies](https://nextjs.org/docs/app/building-your-application/rendering)

---

*Last Updated: January 2026*