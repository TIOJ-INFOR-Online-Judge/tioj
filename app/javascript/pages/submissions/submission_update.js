function hsv_to_rgb(h, s, v) {
  h /= 360; s /= 100; v /= 100;
  let h_i = Math.floor(h*6);
  let f = h*6 - h_i;
  let p = v * (1 - s);
  let q = v * (1 - f*s);
  let t = v * (1 - (1 - f) * s);
  let r = 0, b = 0, g = 0;
  if (h_i == 0) r=v, g=t, b=p;
  if (h_i == 1) r=q, g=v, b=p;
  if (h_i == 2) r=p, g=v, b=t;
  if (h_i == 3) r=p, g=q, b=v;
  if (h_i == 4) r=t, g=p, b=v;
  if (h_i == 5) r=v, g=p, b=q;
  r = Math.floor(r*255).toString(16).padStart(2, '0');
  g = Math.floor(g*255).toString(16).padStart(2, '0');
  b = Math.floor(b*255).toString(16).padStart(2, '0');
  return '#' + r + g + b;
}

function color_map(scale) {
  scale = scale < 0 ? 0 : scale > 1 ? 1 : scale;
  scale = scale < 0.5 ? 0.5 - 2 * (0.5 - scale) ** 2 : 0.5 + 2 * (scale - 0.5) ** 2;
  return hsv_to_rgb(scale * 120, 100, 85 - 40 * scale);
}

function score_str(str) {
  return String(str).replace(/\.0$/, '');
}

function time_str(str) {
  str = parseFloat(str).toFixed(1)
  pad = 6 - str.length;
  if (pad > 0) str = '<span style="visibility: hidden;">' + '0'.repeat(pad) + '</span>' + str;
  return str;
}

function updateSubtask(data) {
  for (let subtask of data['subtask_scores']) {
    let pos = subtask['position'];
    if (subtask['finished']) {
      $('#subtask-score-bg-' + pos).css('background-color', color_map(subtask['ratio']));
      $('#subtask-score-' + pos).text(score_str(subtask['score']));
    }
  }
}

function updateTestdata(data) {
  for (let td of data['testdata']) {
    let pos = td['position'];
    $('#td-time-' + pos).html(time_str(td['time']));
    $('#td-vss-' + pos).text(td['vss']);
    $('#td-rss-' + pos).text(td['rss']);
    $('#td-score-' + pos).text(score_str(td['score']));
    $('#td-verdict-' + pos).text(verdict[td['result']]);
    if (row_class_map[td['result']]) $('#td-row-' + pos).addClass(row_class_map[td['result']]);
    if (td['message_type'] && td['message']) {
      $('#td-message-row-' + pos).removeClass('d-none');
      $('#td-row-' + pos + ' .indicator').removeClass('d-none');
      if (td['message_type'] == 'html') {
        $('#td-message-' + pos).html(td['message']);
      } else {
        $('#td-message-' + pos).html('<pre class="overflow-auto" style="margin: 0;"><code class=""></code></pre>');
        $('#td-message-' + pos + ' code').text(td['message']);
      }
    }
  }
}

function updateResult(data, cable) {
  let to_wait = waiting_verdicts.includes(data['result']);
  $('#verdict').text(verdict[data['result']]);
  $('#waiting-icon').toggleClass('d-none', !to_wait);
  $('#overall-result').attr('class', panel_class_prefix + (panel_class_map[data['result']] || panel_class_map_default));
  if (['CE', 'CLE', 'ER'].includes(data['result']) || data['message']) {
    $('#ce-message').removeClass('d-none');
  }
  if (no_task_verdicts.includes(data['result'])) {
    $('#subtask-results').addClass('d-none');
    $('#testdata-results').addClass('d-none');
  }
  if (data['message']) {
    $('#ce-message-content').removeClass('d-none');
    $('#ce-message-none').addClass('d-none');
    $('#ce-message-content code').text(data['message']);
  }
  if (data['total_time']) $('#total-time').text(data['total_time'])
  if (data['total_memory']) $('#total-memory').text(data['total_memory'])
  if ('score' in data) $('#total-score').text(score_str(data['score']));
  // cable message may not always be in order, so delay disconnect to avoid race
  if (!to_wait) setTimeout(() => cable.disconnect(), 1000);
}

export function updateSubmissionDetail(data, cable) {
  if ('result' in data) {
    updateResult(data, cable);
  } else if ('subtask_scores' in data) {
    updateSubtask(data);
  } else {
    updateTestdata(data);
  }
}

export function updateMultipleSubmissions(data, cable) {
  let id = data['id'];
  $('#verdict-' + id).attr('class', verdict_class_map[data['result']] || '').text(data['result']);
  if (data['total_time']) $('#time-' + id).text(data['total_time']);
  if (data['total_memory']) $('#memory-' + id).text(data['total_memory']);
  if ('score' in data) $('#score-' + id).text(score_str(data['score']));
}
