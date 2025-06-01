import { addTodo, deleteTodo, todos } from "./todo.ts";

export async function handleRequest(req: Request): Promise<Response> {
  const url = new URL(req.url);

  if (req.method === "GET" && url.pathname === "/api/todos") {
    return new Response(JSON.stringify(todos()), {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (req.method === "POST" && url.pathname === "/api/todos") {
    const { title } = await req.json();
    const todo = addTodo(title);
    return new Response(JSON.stringify(todo), {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (req.method === "DELETE" && url.pathname.startsWith("/api/todos/")) {
    const id = url.pathname.split("/").pop()!;
    const ok = deleteTodo(id);
    return new Response(JSON.stringify({ success: ok }));
  }

  // Serve inlined index.html
  if (req.method === "GET" && url.pathname === "/") {
    return new Response(INDEX_HTML, {
      headers: { "Content-Type": "text/html" },
    });
  }

  return new Response("Not Found", { status: 404 });
}

const INDEX_HTML = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Todo App</title>
  <style>
    body {
      font-family: sans-serif;
      max-width: 600px;
      margin: 2rem auto;
      padding: 1rem;
    }
    input[type="text"] {
      padding: 0.5rem;
      width: 80%;
    }
    button {
      padding: 0.5rem;
    }
    li {
      cursor: pointer;
    }
  </style>
</head>
<body>
  <h1>My Deno Todo App</h1>
  <input type="text" id="taskInput" placeholder="Enter a ToDo..." />
  <button id="addBtn">Add ToDo</button>
  <ul id="todoList"></ul>

  <script>
    async function fetchTodos() {
      const res = await fetch('/api/todos');
      const todos = await res.json();
      const ul = document.getElementById('todoList');
      ul.innerHTML = '';
      for (const todo of todos) {
        const li = document.createElement('li');
        li.textContent = todo.title;
        li.onclick = async () => {
          await fetch('/api/todos/' + todo.id, { method: 'DELETE' });
          fetchTodos();
        };
        ul.appendChild(li);
      }
    }

    async function addTodo() {
      const input = document.getElementById('taskInput');
      const title = input.value.trim();
      if (!title) return;
      await fetch('/api/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title })
      });
      input.value = '';
      fetchTodos();
    }

    document.getElementById('addBtn').onclick = addTodo;
    document.getElementById('taskInput').addEventListener('keypress', e => {
      if (e.key === 'Enter') addTodo();
    });

    fetchTodos();
  </script>
</body>
</html>
`;
