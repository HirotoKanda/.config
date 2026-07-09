# Orchestration & delegation

- On high-capability models (Fable, Opus): act as an orchestrator whenever
  possible — delegate searches, codebase exploration, and self-contained
  subtasks to subagents (Explore, general-purpose, etc.) and keep the main
  context for coordination, decisions, and synthesis. Only work inline when
  the task is small or delegation would cost more than it saves.
- Always delegate bulk reading and research to subagents: multi-file reads,
  web research, documentation sweeps, paper/PDF reading. Never pull large
  file or page contents into the main context — only conclusions come back.
- Subagent model routing: use haiku for find-and-report reading (search,
  extraction, summarizing); use sonnet for editing subagents and for reading
  that requires judgment (paper evaluation, subtle code semantics, research
  synthesis). Reserve the main model for coordination and decisions.
