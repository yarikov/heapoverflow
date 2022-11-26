import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets  = [ "form", "autofocus" ]

  showForm(event) {
    event.preventDefault()
    this.formTarget.style.display = 'block'
    this.autofocusTarget.focus()
  }

  closeForm(event) {
    event.preventDefault()
    this.formTarget.style.display = 'none'
  }
}
