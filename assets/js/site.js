document.addEventListener("DOMContentLoaded", () => {
  const root = document.documentElement;
  const storedTheme = localStorage.getItem("rubat-theme");
  const initialTheme = storedTheme || "dark";

  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    const label = document.querySelector("[data-theme-label]");
    if (label) {
      label.textContent = theme === "dark" ? "Switch to light theme" : "Switch to dark theme";
    }
  }

  applyTheme(initialTheme);

  const themeToggle = document.getElementById("themeToggle");
  if (themeToggle) {
    themeToggle.addEventListener("click", () => {
      const nextTheme = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
      localStorage.setItem("rubat-theme", nextTheme);
      applyTheme(nextTheme);
    });
  }

  const navToggle = document.getElementById("siteNavToggle");
  const nav = document.getElementById("siteNav");
  if (navToggle && nav) {
    navToggle.addEventListener("click", () => {
      const isOpen = nav.classList.toggle("is-open");
      navToggle.setAttribute("aria-expanded", String(isOpen));
    });

    window.addEventListener("resize", () => {
      if (window.innerWidth > 1080) {
        nav.classList.remove("is-open");
        navToggle.setAttribute("aria-expanded", "false");
      }
    });
  }
});
