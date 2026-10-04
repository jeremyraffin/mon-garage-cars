import { describe, expect, it } from 'vitest';

// Placeholder proving that TypeScript tests for Edge Functions run in the
// harness. Replace with real command tests when the first function lands.
describe('edge functions test harness', () => {
  it('runs in a node environment', () => {
    expect(typeof window).toBe('undefined');
  });
});
