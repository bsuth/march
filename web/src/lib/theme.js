let current_theme = localStorage.getItem('theme') ?? "light";

export function get() {
  return current_theme;
}

export function apply(theme) {
  current_theme = theme;
  document.body.setAttribute("data-theme", theme);
}

export function save(theme) {
  localStorage.setItem("theme", theme);
}
