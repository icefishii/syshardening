import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";

const db = new DB("todos.db");
db.execute(`
  CREATE TABLE IF NOT EXISTS todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL
  );
`);

export default db;
