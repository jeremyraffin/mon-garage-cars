// Local security checks.
// 1. no environment file, backup or dump is tracked by Git;
// 2. the static build contains no secret-looking value, whatever the file type;
// 3. secretlint also scans the build output, which .secretlintignore skips.
import { spawnSync, execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];

const tracked = execFileSync('git', ['ls-files'], { encoding: 'utf8' })
  .split('\n')
  .filter(Boolean);
const forbiddenTracked = [
  /(^|\/)\.env(\.(?!example$).+)?$/,
  /\.(sql\.gz|dump|backup|bak|sqlite3?|db|zip|tar|tgz)$/i,
  /(^|\/)(backups?|dumps?)\//i,
];
for (const file of tracked) {
  if (forbiddenTracked.some((pattern) => pattern.test(file))) {
    failures.push(`forbidden file tracked by Git: ${file}`);
  }
}

const secretPatterns = [
  [/sb_secret_[A-Za-z0-9_-]{10,}/, 'Supabase secret key'],
  [/service_role/i, 'service_role reference'],
  [/SUPABASE_(SERVICE|SECRET)/i, 'Supabase server variable'],
  [/-----BEGIN [A-Z ]*PRIVATE KEY-----/, 'private key'],
];
const jwtPattern =
  /eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}/g;
const binaryFile =
  /\.(png|jpe?g|gif|webp|avif|ico|woff2?|ttf|otf|eot|mp3|mp4|webm|pdf)$/i;

function jwtRole(token) {
  try {
    const payload = token.split('.')[1] ?? '';
    return JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')).role;
  } catch {
    return undefined;
  }
}

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
    if (binaryFile.test(file)) continue;
    const content = readFileSync(file, 'utf8');
    for (const [pattern, label] of secretPatterns) {
      if (pattern.test(content)) failures.push(`${label} found in ${file}`);
    }
    for (const token of content.match(jwtPattern) ?? []) {
      if (jwtRole(token) === 'service_role') {
        failures.push(`service_role JWT found in ${file}`);
      }
    }
  }

  const scan = spawnSync(
    'npx',
    [
      'secretlint',
      '--no-gitignore',
      '--secretlintignore',
      '.secretlintignore.dist',
      'dist/**/*',
    ],
    { encoding: 'utf8' },
  );
  if (scan.status !== 0) {
    failures.push(`secretlint reported a secret in dist/\n${scan.stdout}`);
  }
}

if (failures.length > 0) {
  console.error(failures.map((f) => `- ${f}`).join('\n'));
  process.exit(1);
}
console.log('Security checks passed.');
