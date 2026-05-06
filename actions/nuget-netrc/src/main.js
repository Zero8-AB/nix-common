const fs = require("node:fs");
const path = require("node:path");

function getInput(name, required = false) {
  const key = `INPUT_${name.replace(/ /g, "_").toUpperCase()}`;
  const value = process.env[key] || "";

  if (required && value.length === 0) {
    throw new Error(`Input required and not supplied: ${name}`);
  }

  return value;
}

function setOutput(name, value) {
  fs.appendFileSync(process.env.GITHUB_OUTPUT, `${name}=${value}\n`);
}

function saveState(name, value) {
  fs.appendFileSync(process.env.GITHUB_STATE, `${name}=${value}\n`);
}

function addMask(value) {
  if (value) {
    process.stdout.write(`::add-mask::${value}\n`);
  }
}

function parseMode(value) {
  if (!/^[0-7]{3,4}$/.test(value)) {
    throw new Error(`Invalid file mode: ${value}`);
  }

  return Number.parseInt(value, 8);
}

try {
  const token = getInput("token", true);
  const netrcPath = getInput("path") || "/tmp/nuget.netrc";
  const machine = getInput("machine") || "nuget.pkg.github.com";
  const login = getInput("login") || "github-actions";
  const mode = parseMode(getInput("mode") || "0644");

  addMask(token);

  fs.mkdirSync(path.dirname(netrcPath), { recursive: true });

  const content = [
    `machine ${machine}`,
    `  login ${login}`,
    `  password ${token}`,
    "",
  ].join("\n");

  fs.writeFileSync(netrcPath, content, { mode });
  fs.chmodSync(netrcPath, mode);

  setOutput("path", netrcPath);
  saveState("path", netrcPath);

  console.log(`Wrote NuGet netrc to ${netrcPath}`);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
