# HTTP Methods in Next.js (App Router)

A complete, interview‑ready guide to **GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS** with:

* Code examples
* Differences
* Next.js compatibility
* Real‑world use cases

---

## 1️⃣ GET – Read Data

### 📌 What it does

Fetches data from the server **without modifying** anything.

### ✅ Characteristics

* No request body
* Safe & idempotent
* Cacheable

### 🧩 Next.js Code Example

```ts
export async function GET() {
  return Response.json({ message: "Fetched users" })
}
```

### 🌍 Real‑World Use Cases

* Fetch users
* Load dashboard data
* Get product details

---

## 2️⃣ POST – Create Data

### 📌 What it does

Sends data to the server to **create a new resource**.

### ✅ Characteristics

* Has request body
* Not idempotent
* Modifies server state

### 🧩 Next.js Code Example

```ts
export async function POST(req: Request) {
  const body = await req.json()
  return Response.json({ created: body })
}
```
```ts
export async function POST(req: Request) {
  const body = await req.json();
  const { name, email } = body;

  const { rows } = await pool.query(
    "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *",
    [name, email]
  );

  return NextResponse.json(rows[0], { status: 201 });
}
```

### 🌍 Real‑World Use Cases

* Create user
* Signup / Login
* Create order

---

## 3️⃣ PUT – Replace Data

### 📌 What it does

Replaces the **entire resource** with new data.

### ✅ Characteristics

* Full update
* Idempotent
* Requires full object

### 🧩 Next.js Code Example

```ts
export async function PUT(req: Request) {
  const body = await req.json()
  return Response.json({ updated: body })
}
```
```ts
export async function PUT(
  req: Request,
  { params }: { params: { id: string } }
) {
  const id = Number(params.id);
  const { name, email } = await req.json();

  await pool.query(
    "UPDATE users SET name = $1, email = $2 WHERE id = $3",
    [name, email, id]
  );

  return NextResponse.json({ message: "User replaced" });
}
```

### 🌍 Real‑World Use Cases

* Replace user profile
* Update full settings object

---

## 4️⃣ PATCH – Partial Update

### 📌 What it does

Updates **only specific fields** of a resource.

### ✅ Characteristics

* Partial update
* Not always idempotent
* Preferred over PUT

### 🧩 Next.js Code Example

```ts
export async function PATCH(req: Request) {
  const body = await req.json()
  return Response.json({ patched: body })
}
```
```ts
export async function PATCH(
  req: Request,
  { params }: { params: { id: string } }
) {
  const id = Number(params.id);
  const { name } = await req.json();

  await pool.query(
    "UPDATE users SET name = $1 WHERE id = $2",
    [name, id]
  );

  return NextResponse.json({ message: "User updated" });
}
```

### 🌍 Real‑World Use Cases

* Update username
* Change password
* Update user status

---

## 5️⃣ DELETE – Remove Data

### 📌 What it does

Deletes a resource from the server.

### ✅ Characteristics

* No body required
* Idempotent
* Permanent action

### 🧩 Next.js Code Example

```ts
export async function DELETE() {
  return Response.json({ deleted: true })
}
```
```ts
export async function DELETE(
  req: Request,
  { params }: { params: { id: string } }
) {
  const id = Number(params.id);

  await pool.query("DELETE FROM users WHERE id = $1", [id]);

  return NextResponse.json({ message: "User deleted" });
}
```

### 🌍 Real‑World Use Cases

* Delete user
* Remove post
* Cancel subscription

---

## 6️⃣ HEAD – Metadata Only

### 📌 What it does

Same as GET **but returns no response body**.

### ✅ Characteristics

* No body in response
* Fast
* Used by browsers & infra

### 🧩 Next.js Code Example

```ts
export async function HEAD() {
  return new Response(null, { status: 200 })
}
```
```ts
export async function HEAD(
  req: Request,
  { params }: { params: { id: string } }
) {
  const id = Number(params.id);

  const { rowCount } = await pool.query(
    "SELECT 1 FROM users WHERE id = $1",
    [id]
  );

  return new Response(null, {
    status: rowCount ? 200 : 404,
  });
}
```

### 🌍 Real‑World Use Cases

* Check if resource exists
* Health checks
* Cache validation

---

## 7️⃣ OPTIONS – Permission Check

### 📌 What it does

Tells the client **which HTTP methods are allowed**.

### ✅ Characteristics

* No body
* Used in CORS
* Browser‑initiated

### 🧩 Next.js Code Example

```ts
export async function OPTIONS() {
  return new Response(null, {
    status: 204,
    headers: {
      Allow: "GET, POST, PATCH, DELETE",
    },
  })
}
```
```ts
export async function OPTIONS() {
  return new Response(null, {
    status: 204,
    headers: {
      Allow: "GET,POST,PUT,PATCH,DELETE,HEAD,OPTIONS",
    },
  });
}
```

### 🌍 Real‑World Use Cases

* CORS preflight
* API permission checks

---

## 🔥 Differences at a Glance

| Method  | Body | Modifies Data | Idempotent | Common Use      |
| ------- | ---- | ------------- | ---------- | --------------- |
| GET     | ❌    | ❌             | ✅          | Fetch data      |
| POST    | ✅    | ✅             | ❌          | Create          |
| PUT     | ✅    | ✅             | ✅          | Full update     |
| PATCH   | ✅    | ✅             | ❌          | Partial update  |
| DELETE  | ❌    | ✅             | ✅          | Remove          |
| HEAD    | ❌    | ❌             | ✅          | Existence check |
| OPTIONS | ❌    | ❌             | ✅          | Permissions     |

---

## ⚙️ Compatibility with Next.js (App Router)

✅ Supported in `route.ts`:

```ts
GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
```

❌ Not supported:

```ts
UPDATE, CREATE, FETCH
```

---

## 🎯 Interview Summary (One‑Liners)

* **GET** → Read
* **POST** → Create
* **PUT** → Replace
* **PATCH** → Partial update
* **DELETE** → Remove
* **HEAD** → Check without body
* **OPTIONS** → Check permissions

---

## 🏁 Final Tip

> In real projects, **GET, POST, PATCH, DELETE** are used daily.
> **HEAD & OPTIONS** are mostly handled by browsers and infrastructure.

---

✅ This file is ready to be saved as `http-methods-nextjs.md`
