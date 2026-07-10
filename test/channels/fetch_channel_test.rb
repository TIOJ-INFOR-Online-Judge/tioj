require "test_helper"

class FetchChannelTest < ActionCable::Channel::TestCase
  class CallbackFailingFetchChannel < FetchChannel
    def subscribed
      raise "simulated subscription callback failure"
    end
  end

  test "accepts a valid judge server and processes its result" do
    judge_server = JudgeServer.create!(name: "Fetch channel test judge", key: "fetch-channel-test-key", online: false)
    connection = judge_connection(judge_server)
    identifier = subscribe_frame(connection, FetchChannel.name)
    submission = submissions(:ac)

    assert_equal judge_server, connection.judge_server
    assert_predicate judge_server.reload, :online?
    assert_includes connection.subscriptions.identifiers, identifier
    assert_changes -> { submission.reload.result }, from: "AC", to: "Validating" do
      perform_action(connection, identifier, action: "submission_result", submission_id: submission.id, verdict: "Validating")
    end
  end

  test "rejects a no-key subscription before retaining it" do
    connection = no_key_connection
    identifier = subscribe_frame(connection, FetchChannel.name)

    assert_nil connection.judge_server
    assert_empty connection.subscriptions.identifiers

    submission = submissions(:ac)
    assert_no_changes -> { submission.reload.result } do
      perform_action(connection, identifier, action: "submission_result", submission_id: submission.id, verdict: "Validating")
    end
  end

  test "a no-key subscription retained after a callback failure cannot change a verdict" do
    connection, identifier = callback_failed_connection
    submission = submissions(:ac)

    assert_no_changes -> { submission.reload.result } do
      perform_action(connection, identifier, action: "submission_result", submission_id: submission.id, verdict: "Validating")
    end
  end

  test "a no-key subscription retained after a callback failure cannot change testcase results" do
    connection, identifier = callback_failed_connection
    testcase_result = submission_testdata_results(:ac_1)

    assert_no_changes -> { testcase_result.reload.message } do
      perform_action(connection, identifier,
        action: "td_result",
        submission_id: testcase_result.submission_id,
        results: [{
          position: testcase_result.position,
          verdict: "AC",
          time: "0",
          rss: 0,
          vss: 0,
          score: 1_000_000,
          message_type: "text",
          message: "forged result"
        }]
      )
    end
  end

  test "a no-key subscription retained after a callback failure cannot update the queue" do
    connection, identifier = callback_failed_connection
    submission = submissions(:ac)

    assert_no_changes -> { submission.reload.updated_at } do
      perform_action(connection, identifier, action: "report_queued", submission_ids: [submission.id])
    end
  end

  test "a no-key subscription retained after a callback failure cannot fetch work" do
    connection, identifier = callback_failed_connection
    submission = submissions(:ac)
    submission.update!(result: "queued", priority: 1_000_000)

    assert_no_changes -> { submission.reload.result } do
      perform_action(connection, identifier, action: "fetch_submission")
    end
  end

  private

  def no_key_connection
    env = Rack::MockRequest.env_for("/cable")
    env["rack.session"] = {}
    ApplicationCable::Connection.new(ActionCable.server, env).tap(&:connect)
  end

  def judge_connection(judge_server)
    env = Rack::MockRequest.env_for("/cable?key=#{judge_server.key}&version=2.3.0")
    ApplicationCable::Connection.new(ActionCable.server, env).tap(&:connect)
  end

  def callback_failed_connection
    connection = no_key_connection
    identifier = subscribe_frame(connection, CallbackFailingFetchChannel.name)

    assert_includes connection.subscriptions.identifiers, identifier
    [connection, identifier]
  end

  def subscribe_frame(connection, channel)
    identifier = {channel: channel}.to_json
    connection.handle_channel_command(raw_command(command: "subscribe", identifier: identifier))
    identifier
  end

  def perform_action(connection, identifier, data)
    connection.handle_channel_command(raw_command(command: "message", identifier: identifier, data: data))
  end

  def raw_command(command:, identifier:, data: nil)
    payload = {command: command, identifier: identifier}
    payload[:data] = data.to_json if data
    JSON.parse(payload.to_json)
  end
end
