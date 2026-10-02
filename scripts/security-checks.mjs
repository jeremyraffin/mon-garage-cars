// Local security checks that need no third-party dependency.
// 1. no environment file or backup is tracked by Git;
// 2. the static build contains no secret-looking value.
import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];

const tracked = execFileSync('git', ['ls-files'], { encoding: 'utf8' })
  .split('\n')
  .filter(Boolean);
const forbiddenTracked =
  /(^|\/)\.env(\.(?!example$).+)?$|\.sql\.gz$|(^|\/)backups\//;
for (const file of tracked.filter((f) => forbiddenTracked.test(f))) {
  failures.push(`forbidden file tracked by Git: ${file}`);
}

const secretPatterns = [
  [/sb_secret_[A-Za-z0-9_-]{10,}/, 'Supabase secret key'],
  [/service_role/i, 'service_role reference'],
  [/SUPABASE_SERVICE/i, 'Supabase service variable'],
  [/-----BEGIN [A-Z ]*PRIVATE KEY-----/, 'private key'],
];

function* walk(dir) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) yield* walk(path);
    else yield path;
  }
}

if (!existsSync('dist')) {
  failures.push('dist/ is missing: run the build before this check');
} else {
  for (const file of walk('dist')) {
    if (!/\.(html|js|css|json|txt|map|webmanifest)$/.test(file)) continue;
    const content = readFileSync(file, 'utf8');
    for (const [pattern, label] of secretPatterns) {
      if (pattern.test(content)) failures.push(`${label} found in ${file}`);
    }
  }
}

if (failures.length > 0) {
  console.error(failures.map((f) => `- ${f}`).join('\n'));
  process.exit(1);
}
console.log('Security checks passed.');
