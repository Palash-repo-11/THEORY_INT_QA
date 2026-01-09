#!/bin/bash

# create_extension.sh
# Script to generate Puppeteer + Chrome MV3 extension project

PROJECT_NAME="puppeteer-chrome-extension"

echo "Creating project folder: $PROJECT_NAME"
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME || exit

# Create extension folder
mkdir -p extension/background
mkdir -p extension/popup
mkdir -p tests

# ----------------------------
# manifest.json
# ----------------------------
cat << 'EOF' > extension/manifest.json
{
  "manifest_version": 3,
  "name": "Test Extension",
  "version": "1.0",
  "permissions": ["storage", "activeTab"],
  "host_permissions": ["https://example.com/*"],
  "background": {
    "service_worker": "background/service_worker.js"
  },
  "content_scripts": [
    {
      "matches": ["https://example.com/*"],
      "js": ["content.js"]
    }
  ],
  "action": {
    "default_popup": "popup/popup.html"
  }
}
EOF

# ----------------------------
# content.js
# ----------------------------
cat << 'EOF' > extension/content.js
const host = document.createElement('div');
host.id = 'my-extension-host';
document.body.appendChild(host);

const shadow = host.attachShadow({ mode: 'open' });
shadow.innerHTML = `
  <style>
    button { background: #4CAF50; color: white; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; }
  </style>
  <button id="my-btn">Click Me!</button>
`;

shadow.getElementById('my-btn').addEventListener('click', () => {
  alert('Button clicked!');
});
EOF

# ----------------------------
# service_worker.js
# ----------------------------
cat << 'EOF' > extension/background/service_worker.js
chrome.runtime.onInstalled.addListener(() => {
  console.log('Service worker installed');
});
EOF

# ----------------------------
# popup.html
# ----------------------------
cat << 'EOF' > extension/popup/popup.html
<!DOCTYPE html>
<html>
  <body>
    <h3>Test Popup</h3>
    <button id="popup-btn">Click Popup</button>
    <script src="popup.js"></script>
  </body>
</html>
EOF

# ----------------------------
# popup.js
# ----------------------------
cat << 'EOF' > extension/popup/popup.js
document.getElementById('popup-btn').addEventListener('click', () => {
  alert('Popup button clicked!');
});
EOF

# ----------------------------
# Puppeteer test
# ----------------------------
cat << 'EOF' > tests/extension.test.js
const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const extensionPath = path.resolve(__dirname, '../extension');

  const browser = await puppeteer.launch({
    headless: false,
    args: [
      `--disable-extensions-except=${extensionPath}`,
      `--load-extension=${extensionPath}`
    ]
  });

  const page = await browser.newPage();
  await page.goto('https://example.com');

  const result = await page.evaluate(() =>
    document.querySelector('#my-extension-host')?.textContent
  );
  console.log('Content Script Text:', result);

  await browser.close();
})();
EOF

# ----------------------------
# package.json
# ----------------------------
cat << 'EOF' > package.json
{
  "name": "puppeteer-chrome-extension",
  "version": "1.0.0",
  "scripts": {
    "test": "node tests/extension.test.js"
  },
  "dependencies": {
    "puppeteer": "^21.3.0"
  }
}
EOF

echo "Project structure created successfully!"
echo "Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. npm install"
echo "3. npm test"
