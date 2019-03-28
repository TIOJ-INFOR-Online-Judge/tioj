class BanCompiler < ActiveRecord::Base
  belongs_to :contest
  belongs_to :compiler
end
