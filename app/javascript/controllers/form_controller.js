import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets  = [ "form" ]

  showForm(event) {
    event.preventDefault()
    this.formTarget.style.display = 'block'
  }

  closeForm(event) {
    event.preventDefault()
    this.formTarget.style.display = 'none'
  }
}
