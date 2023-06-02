async function save(evt) {
  evt.preventDefault()
  console.log(evt.target)
  const fset = evt.target.querySelector("fieldset")
  fset.disabled = true

  var flash = null

  try {
    const form_data = new FormData(evt.target)
    const json = Object.fromEntries(form_data)
    try {
      document.activeElement.blur()
    } catch (e) {
      console.error(e)
    }

    const res = await fetch('/config', {
      method: 'POST',
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(json)
    })
    const json_res = await res.json()
    console.log(json_res)

    console.log(json)
    flash = document.getElementById("saveok")
    setTimeout(() => {
      flash.classList.add("hidden")
    }, 2500)
    fset.disabled = false
  } catch (e) {
    flash = document.getElementById("saveerr")
    flash.innerHTML = `<div>ERROR: ${e.message}</div><div class="mt-4 text-sm">Click to hide</div>`
    const rm = () => {
      flash.removeEventListener("click", rm)
      flash.classList.add("hidden")
      fset.disabled = false
    }
    flash.addEventListener("click", rm)
  }

  flash.classList.remove("hidden")

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
