---
layout: default
title: Download
permalink: /download/
nav_order: 1
---

<style>
  .rubat-download-panel {
    max-width: 520px;
    margin: 2rem auto;
    padding: 1.5rem;
    border: 1px solid var(--line);
    border-radius: 1rem;
    background: color-mix(in srgb, var(--surface-soft) 92%, transparent);
    text-align: center;
    box-shadow: var(--shadow-soft);
  }

  .rubat-download-panel h3 {
    margin-top: 0;
  }

  .rubat-download-panel select {
    width: 100%;
    padding: 10px;
    font-size: 1rem;
    border-radius: 0.7rem;
    border: 1px solid var(--line);
    margin: 1rem 0;
    background: var(--surface-solid);
    color: var(--text);
  }

  .rubat-download-panel a {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 12px 22px;
    margin-top: 10px;
    font-size: 1rem;
    font-weight: 600;
    color: white;
    background: linear-gradient(135deg, var(--rubat-blue), var(--rubat-teal));
    border-radius: 999px;
    text-decoration: none;
    pointer-events: none;
    opacity: 0.5;
  }
</style>

# Download RUBAT Recorder

Select your operating system to download the latest packaged release.

The installers include everything required to run the application.  
**MATLAB Runtime will be installed automatically if it is not already present.**

---

<div class="rubat-download-panel">

  <h3>Choose your platform</h3>

  <select id="osSelect">
    <option value="">— Select operating system —</option>
    <option value="mac">macOS (Apple Silicon)</option>
    <option value="win">Windows (64-bit)</option>
  </select>

  <a id="downloadBtn" href="#">
    Download
  </a>

</div>

---

## Notes

- The packaged installers are generated using **MATLAB Application Compiler**
- All platforms run the **same optimiser core**
- Appearance may differ slightly due to system fonts and screen resolution. (Recommended: [install the Lato font](https://fonts.google.com/specimen/Lato))
- The application window size is fixed to ensure layout consistency

---

## License

The software is released under **GPLv3**.  
Academic and non-commercial research use is fully supported.

---

<script>
(function () {
  const select = document.getElementById('osSelect');
  const btn = document.getElementById('downloadBtn');

  const links = {
    mac: "https://github.com/raviumadi/RUBAT-Recorder/releases/download/R1.0/rubat_web_macos.zip",
    win: "https://github.com/raviumadi/RUBAT-Recorder/releases/download/R1.0/rubat_web_win64.exe.zip"
  };

  select.addEventListener('change', function () {
    const os = select.value;

    if (links[os]) {
      btn.href = links[os];
      btn.style.pointerEvents = 'auto';
      btn.style.opacity = '1';
    } else {
      btn.href = '#';
      btn.style.pointerEvents = 'none';
      btn.style.opacity = '0.5';
    }
  });
})();
</script>