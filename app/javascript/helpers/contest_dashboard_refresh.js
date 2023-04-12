
export function contestDashboardRefresh() {
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
    clear_timing()
    if (enable === false) return
    pid = setTimeout(() => {
      REFRESH.click()
    }, interval * 1000)
  }

  function update_interval() {
    let t = parseInt(INPUT.value)
    if (!(t >= 5)) return
    interval = t
  }

  REFRESH.onclick = function() {
    update_interval()
    reset_timing(interval)
  }

  ENABLE.onchange = function() {
    enable = ENABLE.parentNode.getAttribute('class').includes('switch-on')
    if (enable) REFRESH.onclick()
    else clear_timing()
  }

  INPUT.onkeydown = function(e) {
    if (e.key === 'Enter') REFRESH.click()
  }
}
