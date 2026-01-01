import JSZip from 'jszip';
import { ajaxUploadFunc } from '../../helpers/ajax_upload';

let file_list = [];
let file_pairs = [];

function buildIOCorrespondence() {
  let file_pairs = [];
  const suffix_map = new Map(); // name -> idx
  const prefix_map = new Map(); // name -> idx
  const input_file_list = [];
  for (let idx = 0; idx < file_list.length; idx++) {
    const name = file_list[idx].name;
    if (name.endsWith('out') || name.endsWith('ans')) {
      suffix_map.set(name.slice(0, -3), idx);
    } else if (name.startsWith('out') || name.startsWith('ans')) {
      prefix_map.set(name.slice(3), idx);
    } else {
      input_file_list.push(idx);
    }
  }
  const used_set = new Set();
  for (let i = 0; i < input_file_list.length; i++) {
    let idx = input_file_list[i];
    const name = file_list[idx].name;
    if (name.endsWith('in')) {
      const out_name = name.slice(0, -2);
      if (suffix_map.has(out_name)) {
        const out_idx = suffix_map.get(out_name);
        used_set.add(idx);
        used_set.add(out_idx);
        file_pairs.push([idx, out_idx]);
        continue;
      }
    } else if (name.startsWith('in')) {
      const out_name = name.slice(2);
      if (prefix_map.has(out_name)) {
        const out_idx = prefix_map.get(out_name);
        used_set.add(idx);
        used_set.add(out_idx);
        file_pairs.push([idx, out_idx]);
        continue;
      }
    }
  }
  for (let idx = 0; idx < file_list.length; idx++) {
    if (!used_set.has(idx)) file_pairs.push([null, idx]);
  }
  file_pairs.sort((a, b) => {
    if (a[0] === null && b[0] === null) {
      return a[1] - b[1];
    }
    if (a[0] === null) {
      return 1;
    }
    if (b[0] === null) {
      return -1;
    }
    return a[0] - b[0];
  });
  return file_pairs;
}

function refreshFileListTable() {
  const tmpTable = document.getElementById('file-table');
  tmpTable.innerHTML = '';
  for (let idx = 0; idx < file_pairs.length; idx++){
    const tmpRow = tmpTable.insertRow();
    let tmpCell = tmpRow.insertCell();
    if (file_pairs[idx][0] === null) {
      tmpCell.innerHTML = '<span class="text-danger" style="font-style:italic;">unmatched</span>';
      tmpRow.classList.add('warning');
    } else {
      tmpCell.innerText = file_list[file_pairs[idx][0]].name;
    }
    tmpCell = tmpRow.insertCell();
    tmpCell.innerText = file_list[file_pairs[idx][1]].name;
  }
}

function getZipFileAndFormData(form) {
  const filtered_list = file_pairs.filter((pair) => pair[0] !== null);
  if (filtered_list.length == 0){
    alert('No input files.');
    return null;
  }
  if (filtered_list.length > 256){
    alert('Can only upload 256 testdata at once.');
    return null;
  }

  const origFormData = new FormData(form);
  const formData = new FormData();

  const zipFile = new JSZip();
  const td_pairs = [];
  for (let [key, value] of origFormData.entries()) {
    if (key == 'testdatum[testdata_file_list][]') continue;
    formData.append(key, value);
  }

  let totalSize = 0;
  const MAX_SIZE = 2 * 1024 * 1024 * 1024;
  filtered_list.forEach((pair) => {
    zipFile.file(file_list[pair[0]].name, file_list[pair[0]], {compression: "DEFLATE"});
    zipFile.file(file_list[pair[1]].name, file_list[pair[1]], {compression: "DEFLATE"});
    if (file_list[pair[0]].size + file_list[pair[1]].size > MAX_SIZE) {
      alert('Individual testdatum should not exceed 2 GiB.');
      return null;
    }
    totalSize += file_list[pair[0]].size + file_list[pair[1]].size;
    td_pairs.push([file_list[pair[0]].name, file_list[pair[1]].name]);
  });
  formData.append('testdatum[testdata_pairs]', JSON.stringify(td_pairs));
  return [zipFile, formData];
}

export function initTestdataBatchUpload() {
  function updateTestdataFile(event) {
    file_list = Array.from(event.target.files);
    file_pairs = buildIOCorrespondence();
    refreshFileListTable();
  }
  $('#testdatum_testdata_file_list').on('change', updateTestdataFile);

  $('#testdata-form').on('submit', function (event) {
    event.preventDefault();

    const [zipFile, formData] = getZipFileAndFormData(this);
    if (zipFile === null) {
      $('#submit-button').removeAttr('disabled');
      return;
    }

    let url = $(this).attr('action');
    zipFile.generateAsync({type: "blob"}, function updateCallback(progress) {
      $('#progress-fade-filezip').addClass('show');
      $('#progress-inner-bar-filezip').width(progress.percent + '%');
      $('#progress-text-filezip').text(`Compressing files: ${Math.round( progress.percent )}%`);
      if (progress.percent == 100) {
        $('#progress-text-filezip').text(`File compression complete`);
      }
    }).then(function(zippedFile) {
      formData.append('testdatum[testdata_file_list]', zippedFile, 'td.zip');

      ajaxUploadFunc()(url, formData, (finished, evt) => {
        $('#progress-fade-update').addClass('show');
        if (finished) {
          $('#progress-inner-bar-update').width('100%');
          $('#progress-text-update').text('Processing...');
        } else {
          $('#progress-text-update').text(renderUploadProgress(evt));
          $('#progress-inner-bar-update').width((evt.loaded / evt.total * 100) + '%');
        }
      }, () => {
        $('#progress-fade-filezip').removeClass('show');
        $('#progress-inner-bar-filezip').width('0%');
      });
    });
  });
}
