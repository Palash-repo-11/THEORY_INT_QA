# Next.js Routing & Special Files Guide

## Table of Contents
1. [Directory Structure: `pages/` vs `app/`](#directory-structure)
2. [Special Files Overview](#special-files-overview)
3. [page.tsx - Page Components](#pagetsx)
4. [loading.tsx - Loading States](#loadingtsx)
5. [error.tsx - Error Handling](#errortsx)
6. [layout.tsx - Shared Layouts](#layouttsx)
7. [not-found.tsx - 404 Pages](#not-foundtsx)
8. [public/ - Static Assets](#public)

---

## Directory Structure: `pages/` vs `app/`

### `pages/` Directory (Pages Router - Legacy)
The original Next.js routing system, still widely used and supported.

**Characteristics:**
- File-based routing where each file is automatically a route
- Uses `getServerSideProps`, `getStaticProps` for data fetching
- Client-side rendering by default
- `_app.tsx` for global layout
- `_document.tsx` for HTML document structure

**Example Structure:**
```
pages/
├── index.tsx           # Route: /
├── about.tsx           # Route: /about
├── blog/
│   ├── index.tsx      # Route: /blog
│   └── [slug].tsx     # Route: /blog/:slug
└── api/
    └── hello.ts       # API Route: /api/hello
```

### `app/` Directory (App Router - Modern)
The new routing system introduced in Next.js 13+, built on React Server Components.

**Characteristics:**
- Folder-based routing with special files
- Server Components by default
- Streaming and Suspense support built-in
- Colocation of components, tests, and styles
- Better loading and error handling

**Example Structure:**
```
app/
├── layout.tsx         # Root layout
├── page.tsx           # Route: /
├── loading.tsx        # Loading UI for /
├── error.tsx          # Error UI for /
├── about/
│   └── page.tsx       # Route: /about
└── blog/
    ├── page.tsx       # Route: /blog
    ├── loading.tsx    # Loading UI for /blog
    └── [slug]/
        ├── page.tsx   # Route: /blog/:slug
        └── error.tsx  # Error UI for /blog/:slug
```

**Key Differences:**

| Feature | Pages Router | App Router |
|---------|-------------|------------|
| Default Rendering | Client-side | Server-side |
| Data Fetching | `getServerSideProps`, `getStaticProps` | `async/await` in components |
| Loading States | Manual implementation | Built-in `loading.tsx` |
| Error Handling | `_error.tsx` page | Built-in `error.tsx` boundaries |
| Layouts | Manual HOC pattern | Built-in `layout.tsx` |
| Streaming | Complex setup | Native support |

---

## Special Files Overview

In the App Router, special files define UI for specific parts of your application:

| File | Purpose | Required |
|------|---------|----------|
| `layout.tsx` | Shared UI wrapper for segments | Yes (root) |
| `page.tsx` | Route's unique content | Yes |
| `loading.tsx` | Loading UI with Suspense | No |
| `error.tsx` | Error boundary UI | No |
| `not-found.tsx` | 404 UI | No |
| `template.tsx` | Re-rendered layout | No |
| `route.ts` | API endpoint | No |

---

## page.tsx - Page Components

### Purpose
`page.tsx` makes a route segment publicly accessible and defines the unique UI for that route.

### Basic Structure

```tsx
// app/page.tsx
export default function HomePage() {
  return (
    <div>
      <h1>Welcome to Next.js</h1>
      <p>This is the home page</p>
    </div>
  );
}
```

### Server Component (Default)

```tsx
// app/blog/[slug]/page.tsx
interface PageProps {
  params: { slug: string };
  searchParams: { [key: string]: string | string[] | undefined };
}

export default async function BlogPost({ params, searchParams }: PageProps) {
  // Fetch data directly in the component
  const post = await fetch(`https://api.example.com/posts/${params.slug}`, {
    cache: 'no-store' // Dynamic data
  }).then(res => res.json());

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </article>
  );
}
```

### Client Component

```tsx
// app/counter/page.tsx
'use client'; // Mark as client component

import { useState } from 'react';

export default function CounterPage() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <h1>Count: {count}</h1>
      <button onClick={() => setCount(count + 1)}>
        Increment
      </button>
    </div>
  );
}
```

### Static & Dynamic Metadata

```tsx
// app/products/[id]/page.tsx
import { Metadata } from 'next';

// Static metadata
export const metadata: Metadata = {
  title: 'Product Page',
  description: 'View product details',
};

// Dynamic metadata
export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const product = await fetchProduct(params.id);
  
  return {
    title: product.name,
    description: product.description,
    openGraph: {
      images: [product.image],
    },
  };
}

export default async function ProductPage({ params }: PageProps) {
  const product = await fetchProduct(params.id);
  
  return <div>{/* Product UI */}</div>;
}
```

### Static Generation

```tsx
// app/blog/[slug]/page.tsx

// Generate static pages at build time
export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts')
    .then(res => res.json());
  
  return posts.map((post: any) => ({
    slug: post.slug,
  }));
}

export default async function BlogPost({ params }: PageProps) {
  const post = await fetchPost(params.slug);
  return <article>{/* Post content */}</article>;
}
```

### Use Cases for page.tsx
1. **Marketing pages**: Landing pages, about, contact
2. **Blog posts**: Dynamic content with slugs
3. **Dashboard pages**: User-specific content
4. **E-commerce**: Product listings, product details
5. **Documentation**: Multi-level nested documentation

---

## loading.tsx - Loading States

### Purpose
`loading.tsx` creates automatic loading UI with React Suspense. It shows while `page.tsx` or `layout.tsx` loads.

### Basic Loading UI

```tsx
// app/loading.tsx
export default function Loading() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-gray-900" />
    </div>
  );
}
```

### Skeleton Loading

```tsx
// app/blog/loading.tsx
export default function BlogLoading() {
  return (
    <div className="max-w-4xl mx-auto p-6">
      {/* Header skeleton */}
      <div className="h-12 bg-gray-200 rounded mb-4 animate-pulse" />
      
      {/* Content skeleton */}
      <div className="space-y-3">
        <div className="h-4 bg-gray-200 rounded animate-pulse" />
        <div className="h-4 bg-gray-200 rounded animate-pulse w-5/6" />
        <div className="h-4 bg-gray-200 rounded animate-pulse w-4/6" />
      </div>

      {/* Image skeleton */}
      <div className="h-64 bg-gray-200 rounded mt-6 animate-pulse" />
    </div>
  );
}
```

### Advanced Loading with Streaming

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react';

async function Analytics() {
  const data = await fetchAnalytics(); // Slow
  return <div>{/* Analytics UI */}</div>;
}

async function RecentActivity() {
  const activity = await fetchActivity(); // Fast
  return <div>{/* Activity list */}</div>;
}

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      
      {/* Recent activity loads immediately */}
      <Suspense fallback={<ActivitySkeleton />}>
        <RecentActivity />
      </Suspense>

      {/* Analytics streams in when ready */}
      <Suspense fallback={<AnalyticsSkeleton />}>
        <Analytics />
      </Suspense>
    </div>
  );
}
```

### Loading Scope

```
app/
├── loading.tsx              # Applies to page.tsx
└── dashboard/
    ├── loading.tsx          # Applies to dashboard/page.tsx and children
    ├── page.tsx
    └── settings/
        ├── loading.tsx      # Overrides parent, applies to settings/page.tsx
        └── page.tsx
```

### Custom Loading Component

```tsx
// app/products/loading.tsx
export default function ProductsLoading() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 p-6">
      {[...Array(6)].map((_, i) => (
        <div key={i} className="border rounded-lg p-4">
          <div className="h-48 bg-gray-200 rounded mb-4 animate-pulse" />
          <div className="h-4 bg-gray-200 rounded mb-2 animate-pulse" />
          <div className="h-4 bg-gray-200 rounded w-2/3 animate-pulse" />
        </div>
      ))}
    </div>
  );
}
```

### Use Cases for loading.tsx
1. **Data fetching delays**: Show skeletons while fetching from API
2. **Image loading**: Display placeholders before images load
3. **Route transitions**: Smooth navigation between pages
4. **Progressive enhancement**: Stream fast content first, slow content later
5. **Complex dashboards**: Show different loading states for different sections

---

## error.tsx - Error Handling

### Purpose
`error.tsx` creates an error boundary that catches errors in child segments and displays fallback UI.

### Basic Error Boundary

```tsx
// app/error.tsx
'use client'; // Error boundaries must be Client Components

import { useEffect } from 'react';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log error to error reporting service
    console.error('Error:', error);
  }, [error]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h2 className="text-2xl font-bold mb-4">Something went wrong!</h2>
      <p className="text-gray-600 mb-4">{error.message}</p>
      <button
        onClick={reset}
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-advanced-600"
      >
        Try again
      </button>
    </div>
  );
}
```

### Development vs Production

```tsx
// app/error.tsx
'use client';

export default function Error({ error, reset }: ErrorProps) {
  const isDevelopment = process.env.NODE_ENV === 'development';

  return (
    <div className="p-6">
      <h2>Error Occurred</h2>
      
      {isDevelopment ? (
        // Show detailed error in development
        <div>
          <p className="text-red-600">{error.message}</p>
          <pre className="mt-4 p-4 bg-gray-100 rounded overflow-auto">
            {error.stack}
          </pre>
        </div>
      ) : (
        // Show user-friendly message in production
        <p>We're sorry, something unexpected happened.</p>
      )}
      
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

### Nested Error Boundaries

```tsx
// app/error.tsx (Root level)
'use client';

export default function GlobalError({ error, reset }: ErrorProps) {
  return (
    <html>
      <body>
        <h1>Application Error</h1>
        <p>The entire application encountered an error.</p>
        <button onClick={reset}>Reload application</button>
      </body>
    </html>
  );
}
```

```tsx
// app/dashboard/error.tsx (Nested level)
'use client';

export default function DashboardError({ error, reset }: ErrorProps) {
  return (
    <div className="dashboard-error">
      <h2>Dashboard Error</h2>
      <p>Failed to load dashboard: {error.message}</p>
      <button onClick={reset}>Retry dashboard</button>
    </div>
  );
}
```

### Error Scope Hierarchy

```
app/
├── layout.tsx
├── error.tsx                    # Catches errors in page.tsx
├── page.tsx
└── dashboard/
    ├── layout.tsx
    ├── error.tsx                # Catches errors in dashboard/page.tsx and children
    ├── page.tsx
    └── analytics/
        ├── error.tsx            # Catches errors only in analytics/page.tsx
        └── page.tsx
```

**Important**: `error.tsx` does NOT catch errors in `layout.tsx` of the same segment. Use parent `error.tsx` or `global-error.tsx`.

### Handling Specific Errors

```tsx
// app/api/products/error.tsx
'use client';

export default function ProductError({ error, reset }: ErrorProps) {
  if (error.message.includes('404')) {
    return (
      <div>
        <h2>Product Not Found</h2>
        <p>The product you're looking for doesn't exist.</p>
        <a href="/products">Browse all products</a>
      </div>
    );
  }

  if (error.message.includes('Network')) {
    return (
      <div>
        <h2>Connection Error</h2>
        <p>Please check your internet connection.</p>
        <button onClick={reset}>Retry</button>
      </div>
    );
  }

  // Generic error
  return (
    <div>
      <h2>Error</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

### Error Logging Integration

```tsx
// app/error.tsx
'use client';

import { useEffect } from 'react';
import * as Sentry from '@sentry/nextjs';

export default function Error({ error, reset }: ErrorProps) {
  useEffect(() => {
    // Log to error monitoring service
    Sentry.captureException(error);
    
    // Or custom logging
    fetch('/api/log-error', {
      method: 'POST',
      body: JSON.stringify({
        message: error.message,
        stack: error.stack,
        digest: error.digest,
        timestamp: new Date().toISOString(),
      }),
    });
  }, [error]);

  return (
    <div>
      <h2>Something went wrong</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

### Use Cases for error.tsx
1. **API failures**: Handle failed data fetches gracefully
2. **Network errors**: Show retry options for connectivity issues
3. **Authorization errors**: Redirect to login or show access denied
4. **Component crashes**: Prevent entire app from breaking
5. **User-friendly errors**: Convert technical errors to readable messages

---

## layout.tsx - Shared Layouts

### Purpose
`layout.tsx` wraps segments and their children, preserving state across navigation and avoiding re-renders.

### Root Layout (Required)

```tsx
// app/layout.tsx
import './globals.css';

export const metadata = {
  title: 'My App',
  description: 'A Next.js application',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <header>
          <nav>{/* Global navigation */}</nav>
        </header>
        <main>{children}</main>
        <footer>{/* Global footer */}</footer>
      </body>
    </html>
  );
}
```

### Nested Layout

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex">
      <aside className="w-64 bg-gray-100">
        <nav>
          <a href="/dashboard">Overview</a>
          <a href="/dashboard/analytics">Analytics</a>
          <a href="/dashboard/settings">Settings</a>
        </nav>
      </aside>
      <div className="flex-1 p-6">
        {children}
      </div>
    </div>
  );
}
```

---

## not-found.tsx - 404 Pages

### Purpose
Displays UI when `notFound()` function is called or no route matches.

```tsx
// app/not-found.tsx
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-6xl font-bold mb-4">404</h1>
      <h2 className="text-2xl mb-4">Page Not Found</h2>
      <p className="text-gray-600 mb-8">
        The page you're looking for doesn't exist.
      </p>
      <Link href="/" className="px-6 py-3 bg-blue-500 text-white rounded">
        Go Home
      </Link>
    </div>
  );
}
```

### Programmatic 404

```tsx
// app/products/[id]/page.tsx
import { notFound } from 'next/navigation';

export default async function ProductPage({ params }: PageProps) {
  const product = await fetchProduct(params.id);
  
  if (!product) {
    notFound(); // Triggers not-found.tsx
  }
  
  return <div>{product.name}</div>;
}
```

---

## public/ - Static Assets

### Purpose
Serves static files like images, fonts, and documents from the root URL.

### Structure

```
public/
├── images/
│   ├── logo.png
│   └── hero.jpg
├── fonts/
│   └── custom-font.woff2
├── favicon.ico
└── robots.txt
```

### Usage

```tsx
// app/page.tsx
import Image from 'next/image';

export default function HomePage() {
  return (
    <div>
      {/* Served from /images/logo.png */}
      <Image src="/images/logo.png" alt="Logo" width={200} height={50} />
      
      {/* Direct link to PDF */}
      <a href="/documents/whitepaper.pdf">Download PDF</a>
    </div>
  );
}
```

---

## Complete Example: E-commerce Product Page

```tsx
// app/products/[id]/page.tsx
export async function generateMetadata({ params }: PageProps) {
  const product = await fetchProduct(params.id);
  return { title: product.name };
}

export default async function ProductPage({ params }: PageProps) {
  const product = await fetchProduct(params.id);
  return <ProductDetails product={product} />;
}
```

```tsx
// app/products/[id]/loading.tsx
export default function ProductLoading() {
  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="grid md:grid-cols-2 gap-8">
        <div className="h-96 bg-gray-200 rounded animate-pulse" />
        <div className="space-y-4">
          <div className="h-8 bg-gray-200 rounded animate-pulse" />
          <div className="h-4 bg-gray-200 rounded animate-pulse w-2/3" />
        </div>
      </div>
    </div>
  );
}
```

```tsx
// app/products/[id]/error.tsx
'use client';

export default function ProductError({ error, reset }: ErrorProps) {
  return (
    <div className="max-w-2xl mx-auto p-6 text-center">
      <h2 className="text-2xl font-bold mb-4">Failed to Load Product</h2>
      <p className="text-gray-600 mb-6">{error.message}</p>
      <button onClick={reset} className="px-6 py-2 bg-blue-500 text-white rounded">
        Try Again
      </button>
    </div>
  );
}
```

---

## Best Practices

1. **Use Server Components by default**: Only add `'use client'` when needed
2. **Implement loading states**: Always provide feedback during data fetching
3. **Handle errors gracefully**: Create user-friendly error messages
4. **Leverage streaming**: Use Suspense for progressive loading
5. **Optimize layouts**: Put shared UI in layouts to avoid re-renders
6. **Static generation**: Use `generateStaticParams` for known routes
7. **Error boundaries hierarchy**: Place error.tsx at appropriate levels
8. **Loading skeletons**: Match your actual UI structure for better UX

---

## Migration from Pages to App Router

### Before (Pages Router)
```tsx
// pages/blog/[slug].tsx
export async function getServerSideProps({ params }) {
  const post = await fetchPost(params.slug);
  return { props: { post } };
}

export default function BlogPost({ post }) {
  return <article>{post.title}</article>;
}
```

### After (App Router)
```tsx
// app/blog/[slug]/page.tsx
export default async function BlogPost({ params }) {
  const post = await fetchPost(params.slug);
  return <article>{post.title}</article>;
}
```

The App Router simplifies data fetching and provides better built-in support for loading and error states!