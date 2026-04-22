'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const { installSnapshot } = require('../lib/install-snapshot');

function writeFile(filePath, content) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content);
}

function createFixture() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'flares-agents-'));
  const packageRoot = path.join(root, 'package');
  const targetRoot = path.join(root, 'target');

  writeFile(path.join(packageRoot, 'README.md'), 'package readme\n');
  writeFile(path.join(packageRoot, 'AGENTS.md'), 'agents\n');
  writeFile(path.join(packageRoot, 'docs', 'guide.md'), 'docs\n');
  writeFile(path.join(packageRoot, '.github', 'workflows', 'publish-npm.yml'), 'publish workflow\n');
  writeFile(path.join(packageRoot, '.github', 'workflows', 'quality-gates.yml'), 'quality workflow\n');

  fs.mkdirSync(targetRoot, { recursive: true });

  return { root, packageRoot, targetRoot };
}

test('skip policy preserves existing files and copies missing files', () => {
  const fixture = createFixture();
  writeFile(path.join(fixture.targetRoot, 'README.md'), 'existing\n');

  const result = installSnapshot({
    packageRoot: fixture.packageRoot,
    targetRoot: fixture.targetRoot,
    conflictPolicy: 'skip'
  });

  assert.equal(fs.readFileSync(path.join(fixture.targetRoot, 'README.md'), 'utf8'), 'existing\n');
  assert.equal(fs.readFileSync(path.join(fixture.targetRoot, 'AGENTS.md'), 'utf8'), 'agents\n');
  assert.equal(
    fs.readFileSync(path.join(fixture.targetRoot, '.github', 'workflows', 'quality-gates.yml'), 'utf8'),
    'quality workflow\n'
  );
  assert.equal(fs.existsSync(path.join(fixture.targetRoot, '.github', 'workflows', 'publish-npm.yml')), false);
  assert.ok(result.events.skipped.some((filePath) => filePath.endsWith('README.md')));
  assert.ok(result.events.copied.some((filePath) => filePath.endsWith('AGENTS.md')));
});

test('fail policy throws on conflict', () => {
  const fixture = createFixture();
  writeFile(path.join(fixture.targetRoot, 'README.md'), 'existing\n');

  assert.throws(
    () =>
      installSnapshot({
        packageRoot: fixture.packageRoot,
        targetRoot: fixture.targetRoot,
        conflictPolicy: 'fail'
      }),
    /Conflict detected/
  );
});

test('overwrite policy replaces existing files', () => {
  const fixture = createFixture();
  writeFile(path.join(fixture.targetRoot, 'README.md'), 'existing\n');

  const result = installSnapshot({
    packageRoot: fixture.packageRoot,
    targetRoot: fixture.targetRoot,
    conflictPolicy: 'overwrite'
  });

  assert.equal(fs.readFileSync(path.join(fixture.targetRoot, 'README.md'), 'utf8'), 'package readme\n');
  assert.ok(result.events.overwritten.some((filePath) => filePath.endsWith('README.md')));
});

test('backup policy saves previous file before replacing it', () => {
  const fixture = createFixture();
  writeFile(path.join(fixture.targetRoot, 'README.md'), 'existing\n');

  const result = installSnapshot({
    packageRoot: fixture.packageRoot,
    targetRoot: fixture.targetRoot,
    conflictPolicy: 'backup'
  });

  assert.equal(fs.readFileSync(path.join(fixture.targetRoot, 'README.md'), 'utf8'), 'package readme\n');
  assert.equal(result.events.backedUp.length, 1);
  assert.equal(fs.readFileSync(result.events.backedUp[0].backupTarget, 'utf8'), 'existing\n');
});

test('self install is skipped when packageRoot and targetRoot are identical', () => {
  const fixture = createFixture();

  const result = installSnapshot({
    packageRoot: fixture.packageRoot,
    targetRoot: fixture.packageRoot,
    conflictPolicy: 'skip'
  });

  assert.equal(result.skippedSelfInstall, true);
  assert.equal(result.installed, false);
});
