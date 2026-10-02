// Fails with an actionable message when Docker is not usable.
import { spawnSync } from 'node:child_process';

const result = spawnSync('docker', ['info'], { stdio: 'ignore' });
if (result.status !== 0) {
  console.error(
    'Docker is not available. The local Supabase stack needs Docker Desktop: ' +
      'install it, accept its license, start it, then retry.',
  );
  process.exit(1);
}
