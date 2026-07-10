class ChangeErToJce < ActiveRecord::Migration[7.2]
  def change
    reversible do |direction|
      direction.up do
        Submission.where(result: 'ER').update_all(result: 'JCE')
        SubmissionTestdataResult.where(result: 'ER').update_all(result: 'JCE')
      end
      direction.down do
        Submission.where(result: 'JCE').update_all(result: 'ER')
        SubmissionTestdataResult.where(result: 'JCE').update_all(result: 'ER')
      end
    end
  end
end
