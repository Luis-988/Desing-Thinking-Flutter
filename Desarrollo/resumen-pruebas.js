// Uso: node resumen-pruebas.js
const fs = require('fs');
const { execSync } = require('child_process');

console.log('Corriendo pruebas, espera un momento...\n');

// 1) Resultados de las pruebas (formato JSON de flutter test --machine)
let raw = '';
try {
  raw = execSync('flutter test --machine --coverage', {
    encoding: 'utf8',
    maxBuffer: 1024 * 1024 * 50,
    shell: true,
  });
} catch (e) {
  raw = e.stdout || ''; // si alguna prueba falla, igual leemos los resultados
}

const tests = {};
const results = [];
for (const line of raw.split('\n')) {
  let ev;
  try { ev = JSON.parse(line); } catch { continue; }
  if (ev.type === 'testStart' && ev.test && ev.test.url !== null) {
    tests[ev.test.id] = { name: ev.test.name, file: (ev.test.url || '').split('/test/').pop() };
  }
  if (ev.type === 'testDone' && tests[ev.testID] && !ev.hidden) {
    results.push({ ...tests[ev.testID], ok: ev.result === 'success', skipped: ev.skipped });
  }
}

const byType = (r) =>
  r.file.startsWith('unit/') ? 'Unitarias'
  : r.file.startsWith('widget/') ? 'Widget'
  : 'Existentes (widget_test / project_activities)';

const groups = {};
for (const r of results) {
  const g = byType(r);
  groups[g] ??= { ok: 0, fail: 0, failed: [] };
  if (r.ok) groups[g].ok++; else { groups[g].fail++; groups[g].failed.push(r.name); }
}

let out = '=== RESUMEN DE PRUEBAS ===\n\n';
for (const [g, v] of Object.entries(groups)) {
  out += `${g}: ${v.ok} pasaron, ${v.fail} fallaron\n`;
  for (const f of v.failed) out += `   FALLÓ: ${f}\n`;
}
const total = results.length;
const passed = results.filter((r) => r.ok).length;
out += `\nTOTAL: ${passed}/${total} pruebas pasaron\n`;

// 2) Cobertura (coverage/lcov.info)
if (fs.existsSync('coverage/lcov.info')) {
  const lcov = fs.readFileSync('coverage/lcov.info', 'utf8');
  let file = '', found = 0, hit = 0;
  const perFile = [];
  for (const line of lcov.split('\n')) {
    if (line.startsWith('SF:')) file = line.slice(3).replace(/\\/g, '/').split('/lib/').pop();
    if (line.startsWith('LF:')) found = +line.slice(3);
    if (line.startsWith('LH:')) hit = +line.slice(3);
    if (line === 'end_of_record') perFile.push({ file, found, hit });
  }
  const F = perFile.reduce((a, b) => a + b.found, 0);
  const H = perFile.reduce((a, b) => a + b.hit, 0);
  out += `\n=== COBERTURA ===\nTotal: ${((H / F) * 100).toFixed(1)}% (${H} de ${F} líneas)\n\nArchivos con más cobertura:\n`;
  perFile
    .filter((f) => f.found > 0)
    .sort((a, b) => b.hit / b.found - a.hit / a.found)
    .slice(0, 10)
    .forEach((f) => (out += `  ${((f.hit / f.found) * 100).toFixed(0).padStart(3)}%  ${f.file}\n`));
}

console.log(out);
fs.writeFileSync('resumen-pruebas.txt', out);
console.log('Guardado en resumen-pruebas.txt');