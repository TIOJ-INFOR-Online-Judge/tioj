
function contest_dashboard_main(){

let _debug = false

function debug(...args) {
  if (_debug === false) return
  console.log(...args)
}

debug("contest_dashboard_refresh.js is loaded.")
let INPUT = document.getElementById('refresh_interval')
let REFRESH = document.getElementById('refresh')
let ENABLE = document.getElementById('enable_autorefresh')

let interval = 10
let pid
let enable = false

function clear_timing() {
  if (pid) clearTimeout(pid)
}

function reset_timing(interval) {
  debug(`reset_timing, enable = ${enable}`)
  clear_timing()
  if (enable === false) return
  pid = setTimeout(() => {
    REFRESH.click()
  }, interval * 1000)
}


function update_interval() {
  let t = parseInt(INPUT.value)
  debug(`update_interval with t = ${t}`)
  if (!(t >= 5)) return
  interval = t
}

REFRESH.onclick = function() {
  debug(`REFRESH.onclick()`)
  update_interval()
  reset_timing(interval)
}

ENABLE.onchange = function() {
  enable = ENABLE.parentNode.getAttribute('class').includes('switch-on')
  debug(`ENABLE.onchange(), get enable = ${enable}`)
  if (enable) REFRESH.onclick()
  else clear_timing()
}

INPUT.onkeydown = function(e) {
  if (e.keyCode == 13) REFRESH.click()
}

// reset_timing(interval) // Start auto refresh when page load

}
