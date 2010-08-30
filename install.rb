require 'cfpropertylist'
require 'json'

global_preferences_path = 
  File.expand_path("~/Library/Preferences/.GlobalPreferences.plist")

plist = CFPropertyList::List.new(file: global_preferences_path) 
replacement_items = plist.value.value["NSUserReplacementItems"].value

items = replacement_items.inject({}) do |memo, index| 
  entry = index.value
  key = entry["replace"].value
  enabled = entry["on"] && (entry["on"].value == 1)
  replacement = entry["with"].value
  memo[key] = {"enabled" => enabled, "replacement" => replacement}
  memo
end

import_items = JSON.parse File.read("text-substitutions.json")
import_items.delete_if do |key| items.has_key? (key) end

insertion_items = []
import_items.each do |key, data|
  item = { "replace" => key, "with" => data["replacement"]}
  item["on"] = 1 if data["enabled"]
  insertion_items << item
end

merging_array = CFPropertyList::guess(insertion_items).value
replacement_items.concat merging_array
plist.save(global_preferences_path, 1) # binary
