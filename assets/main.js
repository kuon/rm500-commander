function save(evt) {
  evt.preventDefault()
  console.log(evt.target)
  const form_data = new FormData(evt.target)
  const json = Object.fromEntries(form_data)


  console.log(json)
  var flash = null
  // flash = document.getElementById("saveerr")
  flash = document.getElementById("saveok")

  flash.classList.remove("hidden")
  setTimeout(() => flash.classList.add("hidden"), 1500)
}

function sw(tab) {
  document.getElementById(`tab1-btn`).disabled = false
  document.getElementById(`tab2-btn`).disabled = false
  document.getElementById(`${tab}-btn`).disabled = true
  document.getElementById("tab1").classList.add("hidden")
  document.getElementById("tab2").classList.add("hidden")
  document.getElementById(`${tab}`).classList.remove("hidden")
}

function init() {
  document.getElementById("tab1-btn").addEventListener("click", () => sw("tab1"))
  document.getElementById("tab2-btn").addEventListener("click", () => sw("tab2"))
  sw("tab1")
  document.getElementById("tab2").addEventListener("submit", save)
}

window.addEventListener("load", init)
