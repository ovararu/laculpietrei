import { Controller } from "@hotwired/stimulus"

const POSITIONS_KEY = "topology_positions"
const PHYSICS_KEY   = "topology_physics"

export default class extends Controller {
  static targets = ["canvas"]
  static values  = { url: String }

  async connect() {
    await this.waitFor(() => window.vis?.Network)
    const Network = window.vis.Network

    const response = await fetch(this.urlValue, { headers: { "Accept": "application/json" } })
    const { nodes, edges } = await response.json()

    this.physicsEnabled = localStorage.getItem(PHYSICS_KEY) !== "false"
    const isDark = document.documentElement.classList.contains("dark")

    const savedPositions = this.loadPositions()
    nodes.forEach(node => {
      node.font = { size: 13, color: isDark ? "#F9FAFB" : "#111827" }
      const pos = savedPositions?.[node.id]
      if (pos) { node.x = pos.x; node.y = pos.y }
    })

    const options = {
      physics: {
        enabled: this.physicsEnabled,
        solver: "barnesHut",
        barnesHut: { gravitationalConstant: -8000, springLength: 140, springConstant: 0.04 }
      },
      interaction: { hover: true, tooltipDelay: 100 },
      nodes: { size: 22 },
      edges: { width: 1.5, smooth: { type: "cubicBezier", forceDirection: "vertical", roundness: 0.4 } }
    }

    this.network = new Network(this.canvasTarget, { nodes, edges }, options)

    // Save only when user explicitly drags — never on auto-stabilize
    this.network.on("dragEnd", () => this.savePositions())

    document.getElementById("topology-fit")?.addEventListener("click", () => {
      this.network.fit({ animation: { duration: 500, easingFunction: "easeInOutQuad" } })
    })

    document.getElementById("topology-physics")?.addEventListener("click", () => {
      this.physicsEnabled = !this.physicsEnabled
      this.network.setOptions({ physics: { enabled: this.physicsEnabled } })
      // When turning physics off, capture and save the current positions immediately
      if (!this.physicsEnabled) {
        this.savePositions()
      }
      localStorage.setItem(PHYSICS_KEY, this.physicsEnabled)
    })
  }

  savePositions() {
    const positions = this.network.getPositions()
    localStorage.setItem(POSITIONS_KEY, JSON.stringify(positions))
  }

  loadPositions() {
    try {
      const raw = localStorage.getItem(POSITIONS_KEY)
      return raw ? JSON.parse(raw) : null
    } catch { return null }
  }

  disconnect() {
    this.network?.destroy()
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
}
