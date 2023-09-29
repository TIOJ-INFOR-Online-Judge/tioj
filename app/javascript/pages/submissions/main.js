import consumer from "../../channels/consumer"
import { updateSubmissionDetail, updateMultipleSubmissions } from '../../helpers/submission_update'

export function initSubmissionCable() {
  // id can be integer or array of integers
  function subscribeSubmission(id, onReceive) {
    return consumer.subscriptions.create({
      channel: "SubmissionChannel",
      id: id
    }, {
      received: (data) => onReceive(data, consumer)
    });
  };

  window.subscribeSubmission = subscribeSubmission;
  window.updateSubmissionDetail = updateSubmissionDetail;
  window.updateMultipleSubmissions = updateMultipleSubmissions;
}