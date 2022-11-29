import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets  = [ "form", "file" ]

  connect() {
    this.fileTarget.onchange = () => this.formTarget.requestSubmit()
  }

  openFileDialog(event) {
    event.preventDefault()
    this.fileTarget.click()
  }
}
