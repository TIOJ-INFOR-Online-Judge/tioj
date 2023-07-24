namespace :user do
  desc "Check if there are accounts with invalid usernames"
  task :check_invalid_username => :environment do
    lst = User.where.not('username REGEXP ?', '^[A-Za-z][a-zA-Z0-9._\-]*$')
    unless lst
      puts 'There are no accounts with invalid usernames.'
      return
    end
    breaking, lst = lst.partition{|x| /[\/]/.match(x.username) }
    pure_numeric, lst = lst.partition{|x| /^[0-9]+$/.match(x.username) }
    overriden, lst = lst.partition{|x| ['sign_in', 'sign_up'].include? x.username }
    unless breaking.empty?
      puts "Accounts that can cause crash when rendering (username containing /):"
      breaking.each {|x| puts "User ID #{x.id}: #{x.username}" }
    end
    unless overriden.empty?
      puts "Accounts whose user page will be unreachable (username colliding with existing endpoints):"
      overriden.each {|x| puts "User ID #{x.id}: #{x.username}" }
    end
    unless pure_numeric.empty?
      puts "Accounts that normally don't cause issues, but may override other's user page when visiting by /users/[user-id] (purely numeric usernames):"
      pure_numeric.each {|x| puts "User ID #{x.id}: #{x.username}" }
    end
    unless lst.empty?
      puts "Accounts that don't cause issues, but violates the default username policy:"
      lst.each {|x| puts "User ID #{x.id}: #{x.username}" }
    end
  end
end
