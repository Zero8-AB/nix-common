const fs = require("node:fs");

try {
  const netrcPath = process.env.STATE_path;

  if (!netrcPath) {
    console.log("No netrc path found, skipping cleanup.");
    process.exit(0);
  }

  if (fs.existsSync(netrcPath)) {
    fs.rmSync(netrcPath, { force: true });
    console.log(`Removed NuGet netrc at ${netrcPath}`);
  } else {
    console.log(`NuGet netrc already removed: ${netrcPath}`);
  }
} catch (error) {
  console.error(
    `Failed to remove NuGet netrc: ${error instanceof Error ? error.message : String(error)}`,
  );
  process.exit(1);
}
