// Summarise the Lighthouse JSON reports in qa/lh.
// Usage: node qa/lh-report.mjs
import fs from 'node:fs';
import path from 'node:path';

const dir = 'qa/lh';
const files = fs.existsSync(dir)
  ? fs.readdirSync(dir).filter((f) => f.endsWith('.json')).sort()
  : [];

const metrics = {
  'first-contentful-paint': 'FCP',
  'largest-contentful-paint': 'LCP',
  'total-blocking-time': 'TBT',
  'cumulative-layout-shift': 'CLS',
  'speed-index': 'SI',
  interactive: 'TTI',
};

for (const file of files) {
  const report = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
  const cats = report.categories;
  const score = (id) => Math.round((cats[id]?.score ?? 0) * 100);

  console.log(`\n### ${file.replace('.json', '')}`);
  console.log(
    `perf ${score('performance')} | a11y ${score('accessibility')} | ` +
      `best-practices ${score('best-practices')} | seo ${score('seo')}`,
  );
  const values = Object.entries(metrics)
    .map(([id, label]) => {
      const a = report.audits[id];
      return a?.displayValue ? `${label} ${a.displayValue}` : null;
    })
    .filter(Boolean);
  console.log(values.join(' | '));

  for (const catId of ['performance', 'accessibility', 'best-practices', 'seo']) {
    const failing = (cats[catId]?.auditRefs ?? [])
      .map((ref) => report.audits[ref.id])
      .filter((a) => a && a.score !== null && a.score < 1)
      .filter((a) => !['notApplicable', 'manual', 'informative'].includes(a.scoreDisplayMode))
      .map((a) => `  - ${a.title}${a.displayValue ? ` (${a.displayValue})` : ''}`);
    if (failing.length) {
      console.log(`  ${catId}:`);
      console.log(failing.join('\n'));
    }
  }
}