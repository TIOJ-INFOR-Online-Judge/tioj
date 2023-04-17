# == Schema Information
#
# Table name: submission_subtask_results
#
#  id            :bigint           not null, primary key
#  submission_id :bigint           not null
#  result        :binary(16777215)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_submission_subtask_results_on_submission_id  (submission_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (submission_id => submissions.id)
#

class Serializer
  MARK_UNCOMPRESSED = "\x00".b.freeze
  MARK_COMPRESSED = "\x01".b.freeze
  COMPRESS_THRESHOLD = 1.kilobyte

  def self.dump(value)
    payload = Marshal.dump(value)
    if payload.bytesize >= COMPRESS_THRESHOLD
      compressed_payload = Zlib::Deflate.deflate(payload)
      if compressed_payload.bytesize < payload.bytesize
        return MARK_COMPRESSED + compressed_payload
      end
    end
    MARK_UNCOMPRESSED + payload
  end

  def self.load(payload)
    if payload.nil?
      nil
    elsif payload.start_with?(MARK_UNCOMPRESSED)
      Marshal.load(payload.byteslice(1..-1))
    else
      Marshal.load(Zlib::Inflate.inflate(payload.byteslice(1..-1)))
    end
  end
end

class SubmissionSubtaskResult < ApplicationRecord
  belongs_to :submission
  serialize :result, Serializer
end
