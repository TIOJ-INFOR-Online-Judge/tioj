// Entry point for the build script in your package.json
import './helpers/jquery-global';
import 'jquery-ujs';
import {createPopper} from '@popperjs/core';

// Bootstrap & related components
import 'bootstrap';
import 'bootstrap-select';
import './vendor/bootstrap-switch'

// Flat UI
import './vendor/flatui-checkbox';

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
import './globals/posts';
import './globals/problems';
import './globals/submissions';
import './globals/users';

// helpers
import './helpers/init_code_copy_script'
import { buttonCheckboxSetup } from './helpers/button_checkbox_setup';
window.buttonCheckboxSetup = buttonCheckboxSetup

// pages
import { initContestRanklist } from './pages/contests/main';
import { initSubmissionCable } from './pages/submissions/init_cable';
window.initContestRanklist = initContestRanklist
window.initSubmissionCable = initSubmissionCable