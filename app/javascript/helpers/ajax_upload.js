function formatFileSize(bytes) {
  if (typeof bytes !== 'number') {
    return '';
  }
  if (bytes >= (1024*1024*1024)) {
    return (bytes / (1024*1024*1024)).toFixed(2) + ' GiB';
  }
  if (bytes >= (1024*1024)) {
    return (bytes / (1024*1024)).toFixed(2) + ' MiB';
  }
  if (bytes >= 1024) {
    return (bytes / 1024).toFixed(2) + ' KiB';
  }
  return (bytes * 1.0).toFixed(2) + ' byte';
}

function formatTime(seconds) {
  let date = new Date(seconds * 1000), days = Math.floor(seconds / 86400);
  days = days ? days + 'd ' : '';
  if (date.getUTCHours() > 1) {
    days = days + ('0' + date.getUTCHours()).slice(-2) + ':';
  }
  return (
    days +
    ('0' + date.getUTCMinutes()).slice(-2) +
    ':' +
    ('0' + date.getUTCSeconds()).slice(-2)
  );
}

function formatPercentage(floatValue) {
  return (floatValue * 100).toFixed(2) + ' %';
}

export function renderUploadProgress(data) {
  return (
    formatPercentage(data.loaded / data.total) +
    ' | ' +
    formatFileSize(data.loaded) +
    ' / ' +
    formatFileSize(data.total) +
    ' | ETA ' +
    formatTime((data.total - data.loaded) / (data.byterate)) +
    ' | ' +
    formatFileSize(data.byterate) +
    '/s'
  );
}

export function ajaxUploadFunc() {
  let lastUpdate = (new Date().getTime()) - 500;
  let byterate = 0.0;
  let prevLoaded = 0;
  let oldUrl = window.location.href;
  let xhr = null;
  return function(url, formData, onprogress, onabort) {
    $.ajax({
      type: 'POST',
      url: url,
      data: formData,
      processData: false,
      contentType: false,
      xhr: function() {
        xhr = new window.XMLHttpRequest();
        xhr.upload.onprogress = function(evt) {
          if (evt.lengthComputable) {
            var now = new Date().getTime();
            if (evt.loaded == evt.total) {
              onprogress(true, evt);
            } else if (now - lastUpdate >= 500) {
              var curByterate = ((evt.loaded - prevLoaded) / (now - lastUpdate)) * 1000;
              byterate = byterate * 0.7 + curByterate * 0.3;
              evt.byterate = curByterate;
              lastUpdate = now;
              prevLoaded = evt.loaded;
              onprogress(false, evt);
            }
          }
        };
        return xhr;
      },
      success: function (data, status, nxhr) {
        if (xhr.responseURL != oldUrl) {
          window.history.pushState({}, null, xhr.responseURL);
        }
        document.querySelector('html').innerHTML = nxhr.responseText;
      },
      error: function (nxhr, status, error) {
        document.querySelector('html').innerHTML = nxhr.responseText;
      },
      abort: onabort,
    });
  };
}
