export function apply(theme) {
  document.body.setAttribute("data-theme", theme);
}

export function load() {
  return localStorage.getItem('theme') ?? "light";
}

export function save(theme) {
  localStorage.setItem("theme", theme);
}
