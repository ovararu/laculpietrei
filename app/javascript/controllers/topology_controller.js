import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]
  static values  = { url: String }

  async connect() {
    await this.waitFor(() => window.vis?.Network)
    const Network = window.vis.Network

    const response = await fetch(this.urlValue, { headers: { "Accept": "application/json" } })
    const { nodes, edges } = await response.json()

    const options = {
      physics: {
        enabled: true,
        solver: "barnesHut",
        barnesHut: { gravitationalConstant: -8000, springLength: 140, springConstant: 0.04 }
      },
      interaction: { hover: true, tooltipDelay: 100 },
      nodes: { size: 22, font: { size: 12 } },
      edges: { width: 1.5, smooth: { type: "cubicBezier", forceDirection: "vertical", roundness: 0.4 } }
    }

    this.network = new Network(this.canvasTarget, { nodes, edges }, options)

    document.getElementById("topology-fit")?.addEventListener("click", () => {
      this.network.fit({ animation: { duration: 500, easingFunction: "easeInOutQuad" } })
    })

    document.getElementById("topology-physics")?.addEventListener("click", () => {
      this.physicsEnabled = !this.physicsEnabled
      this.network.setOptions({ physics: { enabled: this.physicsEnabled } })
    })

    this.physicsEnabled = true
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
