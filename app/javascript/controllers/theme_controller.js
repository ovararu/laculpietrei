import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.update()
  }

  toggle() {
    const isDark = document.documentElement.classList.toggle("dark")
    localStorage.setItem("theme", isDark ? "dark" : "light")
    this.update()
  }

  update() {
    const isDark = document.documentElement.classList.contains("dark")
    this.element.setAttribute("aria-label", isDark ? "Switch to light mode" : "Switch to dark mode")
    this.element.textContent = isDark ? "☀" : "🌙"
  }
}
