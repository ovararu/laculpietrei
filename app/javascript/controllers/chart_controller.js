import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeCanvas", "statusCanvas"]
  static values  = { type: Object, status: Object }

  async connect() {
    await this.waitFor(() => window.Chart)
    this.buildTypeChart()
    this.buildStatusChart()
  }

  waitFor(fn, timeout = 5000, interval = 50) {
    return new Promise((resolve, reject) => {
      const start = Date.now()
      const check = () => {
        if (fn()) return resolve()
        if (Date.now() - start > timeout) return reject(new Error("Timeout waiting for dependency"))
        setTimeout(check, interval)
      }
      check()
    })
  }

  disconnect() {
    this.typeChart?.destroy()
    this.statusChart?.destroy()
  }

  buildTypeChart() {
    const labels = Object.keys(this.typeValue).map(t => t === "Pc" ? "PC" : t)
    const data   = Object.values(this.typeValue)

    this.typeChart = new window.Chart(this.typeCanvasTarget, {
      type: "doughnut",
      data: {
        labels,
        datasets: [{
          data,
          backgroundColor: ["#3B82F6", "#8B5CF6", "#10B981", "#F59E0B", "#EF4444"],
          borderWidth: 2,
          borderColor: this.isDark() ? "#1F2937" : "#FFFFFF"
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: "bottom",
            labels: { color: this.isDark() ? "#D1D5DB" : "#374151", padding: 12, font: { size: 12 } }
          }
        }
      }
    })
  }

  buildStatusChart() {
    const colorMap = { active: "#10B981", inactive: "#EF4444", maintenance: "#F59E0B" }
    const labels   = Object.keys(this.statusValue).map(s => s.charAt(0).toUpperCase() + s.slice(1))
    const data     = Object.values(this.statusValue)
    const colors   = Object.keys(this.statusValue).map(s => colorMap[s] || "#9CA3AF")

    this.statusChart = new window.Chart(this.statusCanvasTarget, {
      type: "bar",
      data: {
        labels,
        datasets: [{
          label: "Devices",
          data,
          backgroundColor: colors,
          borderRadius: 6,
          borderSkipped: false
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            ticks: { stepSize: 1, color: this.isDark() ? "#9CA3AF" : "#6B7280" },
            grid:  { color: this.isDark() ? "#374151" : "#F3F4F6" }
          },
          x: {
            ticks: { color: this.isDark() ? "#9CA3AF" : "#6B7280" },
            grid:  { display: false }
          }
        },
        plugins: { legend: { display: false } }
      }
    })
  }

  isDark() {
    return document.documentElement.classList.contains("dark")
  }
}
