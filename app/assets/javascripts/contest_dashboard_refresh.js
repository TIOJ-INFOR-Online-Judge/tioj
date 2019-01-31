
function contest_dashboard_main(){

console.log("contest_dashboard_refresh.js is loaded.")
let INPUT = document.getElementById('refresh_interval')
let REFRESH = document.getElementById('refresh')

let interval = 10
let interval_id

function reset_interval(interval) {
  if (interval_id) clearInterval(interval_id)
  interval_id = setInterval(() => {
    REFRESH.click()
  }, interval * 1000)
}

function update_interval() {
  interval = INPUT.value
}

REFRESH.onclick = function() {
  update_interval();
  reset_interval(interval);
}

reset_interval(interval)

}
