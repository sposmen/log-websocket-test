
ARGV.each{ |a|
  count = 0
  sum = 0
  File.open(a).each do |line|
    count += 1 
    sum += line.to_f
  end
  p a
  p "Count: " + count.to_s
  p "Sum: " + sum.to_s
  p "Avg: " + (sum/count).to_s
  p "------------------"
}