
function contest_dashboard_main(){

console.log("contest_dashboard_refresh.js is loaded.")
let INPUT = document.getElementById('refresh_interval')
let REFRESH = document.getElementById('refresh')

let interval = 10
let pid

function reset_timing(interval) {
  if (pid) clearTimeout(pid)
  pid = setTimeout(() => {
    REFRESH.click()
  }, interval * 1000)
}

function update_interval() {
  let t = parseInt(INPUT.value)
  if (!(t >= 2)) return
  interval = t
}

REFRESH.onclick = function() {
  update_interval()
  reset_timing(interval)
}

reset_timing(interval)

}
