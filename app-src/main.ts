import { handleRequest } from "./routes.ts";
import db from "./db.ts";

const controller = new AbortController();
const { signal } = controller;

Deno.serve({ port: 8000, hostname: "127.0.0.1", signal }, handleRequest);

for (const signalName of ["SIGINT", "SIGTERM"] as const) {
	Deno.addSignalListener(signalName, () => {
		console.log(`Received ${signalName}, shutting down...`);
		controller.abort();
		db.close();
		Deno.exit();
	});
}
