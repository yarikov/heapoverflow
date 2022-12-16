import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets  = [ "form", "autofocus" ]

  showForm(event) {
    event.preventDefault()
    this.formTarget.classList.remove('d-none')
    this.autofocusTarget.focus()
  }

  closeForm(event) {
    event.preventDefault()
    this.formTarget.classList.add('d-none')
  }
}
