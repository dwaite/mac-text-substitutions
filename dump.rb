require 'cfpropertylist'
require 'json'

plist = CFPropertyList::List.new(file: 
	File.expand_path("~/Library/Preferences/.GlobalPreferences.plist"))
replacement_items = plist.value.value["NSUserReplacementItems"].value

items = replacement_items.inject({}) do |memo, index| 
  entry = index.value
  key = entry["replace"].value
  enabled = entry["on"] && (entry["on"].value == 1)
  replacement = entry["with"].value
  memo[key] = {"enabled" => enabled, "replacement" => replacement}
  memo
end

File.open("text-substitutions.json", "w") do |f|
  f.write JSON.pretty_generate(items,:ascii_only => true)
end
