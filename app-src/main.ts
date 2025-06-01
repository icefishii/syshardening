import { handleRequest } from "./routes.ts";
import db from "./db.ts";

const controller = new AbortController();
const { signal } = controller;

Deno.serve({ port: 8000, signal }, handleRequest);

for (const signalName of ["SIGINT", "SIGTERM"] as const) {
	Deno.addSignalListener(signalName, () => {
		console.log(`Received ${signalName}, shutting down...`);
		controller.abort();
		db.close();
		Deno.exit();
	});
}
