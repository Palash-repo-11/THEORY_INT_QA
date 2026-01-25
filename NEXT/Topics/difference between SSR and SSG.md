SSR vs SSG: Key Differences
Let me break down the fundamental differences between Server-Side Rendering and Static Site Generation.
The Core Difference
SSG (Static Site Generation):

HTML is generated once at build time
The same pre-built HTML file is served to every user
Like baking bread in advance and serving it from the shelf

SSR (Server-Side Rendering):

HTML is generated on every request
Fresh HTML is created for each user when they visit
Like baking fresh bread for each customer who walks in


Timing: When Does Rendering Happen?
SSG
Developer runs: npm run build
      ↓
Next.js generates HTML for all pages
      ↓
HTML files stored on server/CDN
      ↓
User requests page → Instant HTML delivery (already exists)
SSR
User requests page
      ↓
Server receives request
      ↓
Server fetches data & renders HTML
      ↓
HTML sent to user

Code Comparison
SSG Example
javascript// This runs ONCE during build
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
What happens:

You run npm run build
Next.js fetches the product data
Generates an HTML file: product-123.html
Every user gets this exact same HTML file

SSR Example
javascript// This runs on EVERY request
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
What happens:

User visits the page
Server fetches current product data
Server generates HTML with latest data
Sends HTML to user
Next user triggers the same process again


Data Freshness
SSG
javascript// Build happens at 9 AM
npm run build
// Product price in DB: $100 → HTML shows $100

// Price changes in DB at 10 AM to $150
// HTML still shows $100 (stale data)

// Until you rebuild...
npm run build  // Now HTML shows $150
Data is frozen at build time
SSR
javascript// User A visits at 9 AM
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

The Hybrid Approach: ISR
Many real applications use ISR (Incremental Static Regeneration) which combines both:
javascriptasync function getProduct() {
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
The main takeaway: SSG renders once and reuses, SSR renders fresh every time. Choose based on how dynamic your content needs to be and how much you value performance vs freshness.how next js understand which is SSR and which is SSG12:54 AMHow Next.js Determines SSR vs SSG
Great question! Next.js uses specific signals in your code to automatically decide the rendering strategy. Let me break this down for both the Pages Router (older) and App Router (newer).

App Router (Next.js 13+) - Modern Approach
Next.js App Router uses a "static by default" philosophy. Here's how it decides:
Default: SSG (Static)
javascript// This is SSG by default
export default async function Page() {
  const data = await fetch('https://api.example.com/data')
  return <div>{data.title}</div>
}
Triggers for SSR (Dynamic Rendering)
Next.js switches to SSR when it detects:
1. Dynamic Functions
javascriptimport { cookies, headers } from 'next/headers'

export default async function Page() {
  // Using cookies() makes this SSR
  const cookieStore = cookies()
  const theme = cookieStore.get('theme')
  
  // Using headers() makes this SSR
  const headersList = headers()
  const userAgent = headersList.get('user-agent')
  
  return <div>Theme: {theme}</div>
}
2. Dynamic Segments (useSearchParams, params)
javascriptimport { useSearchParams } from 'next/navigation'

export default function Page() {
  // Using searchParams makes this SSR
  const searchParams = useSearchParams()
  const query = searchParams.get('q')
  
  return <div>Search: {query}</div>
}
3. Cache: 'no-store'
javascriptexport default async function Page() {
  // Explicitly telling Next.js: don't cache, always fresh
  const data = await fetch('https://api.example.com/data', {
    cache: 'no-store' // This forces SSR
  })
  
  return <div>{data.title}</div>
}
4. Revalidate: 0
javascriptexport default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 0 } // Revalidate on every request = SSR
  })
  
  return <div>{data.title}</div>
}
5. Dynamic Route Segment Config
javascript// This forces the entire route to be dynamic (SSR)
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

Pages Router (Next.js 12 and earlier) - Explicit Approach
In the Pages Router, you explicitly tell Next.js what to do by exporting special functions:
SSG - Export getStaticProps
javascript// pages/products.js

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
Next.js sees getStaticProps → SSG
SSR - Export getServerSideProps
javascript// pages/dashboard.js

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
Next.js sees getServerSideProps → SSR
CSR - No special function
javascript// pages/profile.js
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
Next.js sees no special export → CSR (Client-Side Rendering)

How to Check What Next.js Chose
1. Build Output
When you run npm run build, Next.js tells you:
bashRoute (app)                              Size     First Load JS
┌ ○ /                                    5 kB           87 kB
├ ○ /about                               3 kB           85 kB
└ ƒ /dashboard                           2 kB           84 kB

○  (Static)  automatically rendered as static HTML
ƒ  (Dynamic) server-rendered on demand
Legend:

○ = SSG (Static)
ƒ = SSR (Dynamic)
● = SSG with data fetching

2. In Development
Next.js shows warnings in the console:
javascriptexport const dynamic = 'force-dynamic'

export default function Page() {
  return <div>Content</div>
}
```

**Console output:**
```
⚠ Page /dashboard is using dynamic rendering
3. Manual Override
You can force a specific behavior:
javascript// Force SSG (even if it would normally be SSR)
export const dynamic = 'force-static'

// Force SSR (even if it could be SSG)
export const dynamic = 'force-dynamic'

// Error if page can't be static
export const dynamic = 'error'

Complete Examples
Example 1: Automatic SSG
javascript// app/blog/[slug]/page.js

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
Next.js decision: SSG (has generateStaticParams)
Example 2: Automatic SSR
javascript// app/search/page.js
import { headers } from 'next/headers'

export default async function SearchResults() {
  // Using headers() triggers SSR
  const headersList = headers()
  const referer = headersList.get('referer')
  
  const results = await fetch('https://api.example.com/search')
    .then(r => r.json())
  
  return <div>{results.map(r => <div key={r.id}>{r.title}</div>)}</div>
}
Next.js decision: SSR (uses headers())
Example 3: Mixed Strategy
javascript// app/products/page.js

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
Next.js decision: SSR (because one fetch is dynamic)

Quick Reference Table
App Router SignalResultDefault (nothing special)SSGcookies()SSRheaders()SSRuseSearchParams()SSRcache: 'no-store'SSRrevalidate: 0SSRdynamic = 'force-dynamic'SSRdynamic = 'force-static'SSGgenerateStaticParams()SSG
Pages Router SignalResultgetStaticPropsSSGgetServerSidePropsSSRNo special functionCSRgetStaticProps + revalidateISR