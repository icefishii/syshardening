import { addTodo, deleteTodo, todos } from "../todo.ts";
import {
	assert,
	assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

Deno.test("Add Todo", () => {
	const initialLength = todos.length;
	const todo = addTodo("Test Todo");
	assertEquals(todos.length, initialLength + 1);
	assertEquals(todo.title, "Test Todo");
});

Deno.test("Delete Todo", () => {
	const todo = addTodo("To be deleted");
	const deleted = deleteTodo(todo.id);
	assert(deleted);
});
