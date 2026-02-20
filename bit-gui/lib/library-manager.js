const { app } = require("electron");
const fs = require("fs");
const path = require("path");
const https = require("https");

const profiles = require("./profiles.json");

function getLibCacheDir(profileId) {
  return path.join(app.getPath("userData"), "lib-cache", profileId);
}

function getCachedFilePath(profileId, filename) {
  return path.join(getLibCacheDir(profileId), filename);
}

function fetchRaw(repo, branch, filePath) {
  const url = `https://raw.githubusercontent.com/${repo}/${branch}/${filePath}`;
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        https.get(res.headers.location, (res2) => {
          let data = "";
          res2.on("data", (chunk) => (data += chunk));
          res2.on("end", () => resolve(data));
          res2.on("error", reject);
        }).on("error", reject);
        return;
      }
      if (res.statusCode !== 200) {
        reject(new Error(`HTTP ${res.statusCode} fetching ${url}`));
        return;
      }
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => resolve(data));
      res.on("error", reject);
    }).on("error", reject);
  });
}

/**
 * Ensure all library files for a profile are cached locally.
 * Fetches from GitHub if missing.
 * Returns the cache directory path.
 */
async function ensureLibrary(profileId) {
  const profile = profiles[profileId];
  if (!profile) throw new Error(`Unknown library profile: ${profileId}`);

  const cacheDir = getLibCacheDir(profileId);
  fs.mkdirSync(cacheDir, { recursive: true });

  for (const file of profile.files) {
    const cached = getCachedFilePath(profileId, file);
    if (!fs.existsSync(cached)) {
      console.log(`Fetching ${file} from ${profile.repo}...`);
      const content = await fetchRaw(profile.repo, profile.branch, file);
      fs.writeFileSync(cached, content, "utf-8");
      console.log(`Cached: ${cached}`);
    }
  }

  return cacheDir;
}

/**
 * Copy cached library files to a target directory (next to the user's .scad file).
 * Only copies if the file doesn't already exist in the target.
 */
async function copyLibToDir(profileId, targetDir) {
  const profile = profiles[profileId];
  if (!profile) return;

  const cacheDir = await ensureLibrary(profileId);

  for (const file of profile.files) {
    const src = path.join(cacheDir, file);
    const dst = path.join(targetDir, file);
    if (fs.existsSync(src) && !fs.existsSync(dst)) {
      fs.copyFileSync(src, dst);
      console.log(`Copied library file: ${dst}`);
    }
  }
}

/**
 * Detect which profile matches an include filename.
 * Returns the profile ID or null.
 */
function detectProfile(includeFilename) {
  for (const [id, profile] of Object.entries(profiles)) {
    const re = new RegExp(profile.includePattern, "i");
    if (re.test(includeFilename)) return id;
  }
  return null;
}

/**
 * Get the profile object by ID.
 */
function getProfile(profileId) {
  return profiles[profileId] || null;
}

module.exports = { ensureLibrary, copyLibToDir, detectProfile, getProfile, profiles };
