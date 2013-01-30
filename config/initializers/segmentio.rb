Analytics.init(
  secret: 'fi31zj6ejhs4amywwgsh', 
  on_error: Proc.new {|s,m| puts "[ANALYTICS] Error! Status: #{s}, Message: #{m}"}
)
