import { createConsumer } from "@rails/actioncable"

var protocol = location.protocol.match(/^https/) ? 'wss' : 'ws';
var cable = createConsumer(`${protocol}:${location.host}/cable`);

// id can be integer or array of integers
function subscribeSubmission(id, onReceive) {
  return cable.subscriptions.create({
    channel: "SubmissionChannel",
    id: id
  }, {
    received: (data) => onReceive(data, cable)
  });
};

window.subscribeSubmission = subscribeSubmission;

import { updateSubmissionDetail, updateMultipleSubmissions } from './helpers/submission_update'
window.updateSubmissionDetail = updateSubmissionDetail;
window.updateMultipleSubmissions = updateMultipleSubmissions;