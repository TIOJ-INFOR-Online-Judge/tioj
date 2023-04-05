# == Schema Information
#
# Table name: code_contents
#
#  id   :bigint           not null, primary key
#  code :binary(429496729
#

class CodeContent < ApplicationRecord
  def code_utf8
    code.force_encoding('utf-8')
  end
end
