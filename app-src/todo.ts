import db from "./db.ts";

export function addTodo(title: string) {
  db.query("INSERT INTO todos (title) VALUES (?)", [title]);
  const id = db.lastInsertRowId;
  return { id, title };
}

export function deleteTodo(id: string | number) {
  db.query("DELETE FROM todos WHERE id = ?", [Number(id)]);
  return db.changes > 0;
}

export function todos() {
  return [...db.query("SELECT id, title FROM todos")].map(([id, title]) => ({
    id,
    title,
  }));
}
