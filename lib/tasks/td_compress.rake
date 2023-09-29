COMPRESS_THRESHOLD = 128 * 1024

def compress_problem(prob)
  Testdatum.where(problem_id: prob).each do |x|
    filename = x.test_input.to_s
    if File.size(filename) >= COMPRESS_THRESHOLD
      system("zstd", "-12", filename, exception: true)
      File.rename(filename + ".zst", filename)
      x.input_compressed = true
      x.save!
    end
    filename = x.test_output.to_s
    if File.size(filename) >= COMPRESS_THRESHOLD
      system("zstd", "-12", filename, exception: true)
      File.rename(filename + ".zst", filename)
      x.output_compressed = true
      x.save!
    end
  end
end

namespace :td do
  desc "Compress existing testdata"
  task :compress_problem, [:problem_id] => :environment do |task, args|
    compress_problem args[:problem_id]
  end
  task compress_all: :environment do |task, args|
    Problem.all.each do |x|
      compress_problem x.id
    end
  end
end
