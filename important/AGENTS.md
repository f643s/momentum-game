# Rules for the AI agent

- Engine: Godot 4.x, GDScript only (no C#). Use static typing (`var x: float`).
- The human is a **beginner in Godot**. Explain what each new node/script is for in 1-2 lines, and give exact editor click-steps for anything that is not code (adding nodes, Input Map, collision layers).
- Work on **one phase at a time** from `docs/04-roadmap.md`. Never start the next phase until the human confirms the current one works.
- Every phase ends with: (a) what files changed, (b) how to run/test it, (c) a checklist of what the human should see.
- Never reference nodes, autoloads, or input actions that do not exist yet. If a script needs a scene setup, list it explicitly.
- Keep scripts small (<200 lines). One responsibility per script.
- All tunable numbers go in `@export` vars or a constants block at the top, with a comment on what changing it does.
- Prefer editing existing files to rewriting them. Show diffs or full files, never "..." placeholders.
- If something is ambiguous in the design, ask ONE question, then proceed with a sensible default.
- Do not add multiplayer unless Phase 9 is explicitly started.
- Scope of the first demo: single-player vs bots. Multiplayer is out of scope.
- Be **data-driven**: tuning values, weapons, and bots are Resources registered by string id (see `docs/07-modding.md`). Do not hard-code them in gameplay scripts.
- Dev tools (console, overlays) must only be active in debug/`--dev` builds.
- Whenever you add a gameplay event (damage, slam, chain fire, etc.), emit it through the `ModAPI` events so mods and tests can hook it.
