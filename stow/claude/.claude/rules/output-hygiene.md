# Output hygiene & evidence

- Filter verbose command output before it enters context: pipe test/build
  logs through grep/head instead of dumping them (e.g. `| grep -E
  'FAIL|ERROR' | head -100`); read full logs only when the filter is empty
  but the exit code says failure.
- Claim success only with evidence: show the passing test output or command
  result, never a bare "done".
