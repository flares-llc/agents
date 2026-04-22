'use strict';

const fs = require('node:fs');
const path = require('node:path');

const ALLOWED_POLICIES = new Set(['skip', 'fail', 'overwrite', 'backup']);
const SNAPSHOT_ENTRIES = [
  '.github',
  '.githooks',
  '.vscode',
  'docs',
  'scripts',
  'AGENTS.md',
  'README.md'
];

const EXCLUDED_RELATIVE_PATHS = new Set([
  '.github/workflows/publish-npm.yml'
]);

function toPosixPath(filePath) {
  return filePath.split(path.sep).join('/');
}

function isExcludedPath(relativePath) {
  return EXCLUDED_RELATIVE_PATHS.has(toPosixPath(relativePath));
}

function ensurePolicy(policy) {
  if (!ALLOWED_POLICIES.has(policy)) {
    throw new Error(
      `Unsupported conflict policy: ${policy}. Expected one of ${Array.from(ALLOWED_POLICIES).join(', ')}`
    );
  }
}

function copyDirectory(sourceDir, targetDir, state) {
  fs.mkdirSync(targetDir, { recursive: true });

  for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
    const sourcePath = path.join(sourceDir, entry.name);
    const targetPath = path.join(targetDir, entry.name);
    const relativeTargetPath = path.relative(state.targetRoot, targetPath);

    if (isExcludedPath(relativeTargetPath)) {
      continue;
    }

    if (entry.isDirectory()) {
      copyDirectory(sourcePath, targetPath, state);
      continue;
    }

    copyFileWithPolicy(sourcePath, targetPath, state);
  }
}

function backupPath(targetPath) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  return `${targetPath}.bak.${timestamp}`;
}

function copyFileWithPolicy(sourcePath, targetPath, state) {
  const { conflictPolicy, events } = state;
  const exists = fs.existsSync(targetPath);

  if (!exists) {
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
    fs.copyFileSync(sourcePath, targetPath);
    events.copied.push(targetPath);
    return;
  }

  if (conflictPolicy === 'skip') {
    events.skipped.push(targetPath);
    return;
  }

  if (conflictPolicy === 'fail') {
    const error = new Error(`Conflict detected: ${targetPath}`);
    error.code = 'EFLARESCONFLICT';
    throw error;
  }

  if (conflictPolicy === 'backup') {
    const backupTarget = backupPath(targetPath);
    fs.renameSync(targetPath, backupTarget);
    fs.copyFileSync(sourcePath, targetPath);
    events.backedUp.push({ targetPath, backupTarget });
    return;
  }

  fs.copyFileSync(sourcePath, targetPath);
  events.overwritten.push(targetPath);
}

function installSnapshot(options) {
  const packageRoot = path.resolve(options.packageRoot);
  const targetRoot = path.resolve(options.targetRoot);
  const conflictPolicy = options.conflictPolicy || 'skip';

  ensurePolicy(conflictPolicy);

  if (packageRoot === targetRoot) {
    return {
      installed: false,
      skippedSelfInstall: true,
      events: { copied: [], skipped: [], overwritten: [], backedUp: [] }
    };
  }

  const state = {
    targetRoot,
    conflictPolicy,
    events: { copied: [], skipped: [], overwritten: [], backedUp: [] }
  };

  for (const entry of SNAPSHOT_ENTRIES) {
    const sourcePath = path.join(packageRoot, entry);

    if (!fs.existsSync(sourcePath)) {
      continue;
    }

    const targetPath = path.join(targetRoot, entry);
    const stat = fs.statSync(sourcePath);

    if (stat.isDirectory()) {
      copyDirectory(sourcePath, targetPath, state);
      continue;
    }

    copyFileWithPolicy(sourcePath, targetPath, state);
  }

  return {
    installed: true,
    skippedSelfInstall: false,
    events: state.events
  };
}

module.exports = {
  ALLOWED_POLICIES,
  SNAPSHOT_ENTRIES,
  installSnapshot
};
