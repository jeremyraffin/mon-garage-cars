// Runs the pgTAP tests, starting the local stack when needed and stopping it
// afterwards only if this script started it. The local database is reset first
// so the tests always run against the current migrations and seed: a stack
// restored from an earlier backup or left running would otherwise be stale.
import { spawnSync } from 'node:child_process';

function run(args, quiet = false) {
  return spawnSync('npx', ['supabase', ...args], {
    stdio: quiet ? ['ignore', 'ignore', 'inherit'] : 'inherit',
  }).status;
}

const docker = spawnSync('node', ['scripts/require-docker.mjs'], {
  stdio: 'inherit',
});
if (docker.status !== 0) process.exit(1);

const wasRunning =
  spawnSync('npx', ['supabase', 'status'], { stdio: 'ignore' }).status === 0;

if (!wasRunning && run(['start'], true) !== 0) process.exit(1);
const resetStatus = run(['db', 'reset', '--local'], true);
const testStatus = resetStatus === 0 ? run(['test', 'db']) : resetStatus;
if (!wasRunning) run(['stop'], true);
process.exit(testStatus ?? 1);
