// Entry point for the build script in your package.json
import './helpers/jquery-global';
import 'jquery-ujs';
import {createPopper} from '@popperjs/core';

// Bootstrap & related components
import 'bootstrap';
import 'bootstrap-notify';

// multi-select component
import TomSelect from "tom-select"
window.TomSelect = TomSelect;

// JQuery components
import './helpers/jquery-ui-slider-import';
import 'jquery-placeholder';
import './vendor/jquery.tagsinput';
import './vendor/jquery_nested_form';

// tablesorter
import 'tablesorter/dist/js/jquery.tablesorter';
import 'tablesorter/dist/js/extras/jquery.tablesorter.pager.min';
import './vendor/pager-custom-controls';

// file upload
import 'blueimp-file-upload';
import 'blueimp-tmpl';

// globals
import './globals/problems';
import './globals/submissions';
import './globals/users';

// helpers
import './helpers/ajax_upload';
import './helpers/init_code_copy_script';
import { buttonCheckboxSetup } from './helpers/button_checkbox_setup';
import { renderUploadProgress, ajaxUploadFunc } from './helpers/ajax_upload';
window.buttonCheckboxSetup = buttonCheckboxSetup;
window.renderUploadProgress = renderUploadProgress;
window.ajaxUploadFunc = ajaxUploadFunc;

// pages
import { initContestRanklist, initContestCable } from './pages/contests/main';
import { initSubmissionCable } from './pages/submissions/main';
import { initProblemForm } from './pages/problems/main';
window.initContestRanklist = initContestRanklist;
window.initContestCable = initContestCable;
window.initSubmissionCable = initSubmissionCable;
window.initProblemForm = initProblemForm;
