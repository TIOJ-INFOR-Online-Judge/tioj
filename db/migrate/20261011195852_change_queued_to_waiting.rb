class ChangeQueuedToWaiting < ActiveRecord::Migration[7.2]
  def change
    change_column_default :submissions, :result, 'waiting'
    reversible do |direction|
      direction.up do
        Submission.where(result: 'queued').update_all(result: 'waiting')
      end
      direction.down do
        Submission.where(result: 'queued').update_all(result: 'received')
        Submission.where(result: 'waiting').update_all(result: 'queued')
      end
    end
  end
end
