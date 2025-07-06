local M = {}

--- Validate that input is a table
--- @param t any
--- @param func_name string
--- @return boolean
local function validate_table(t, func_name)
	if type(t) ~= "table" then
		vim.notify(func_name .. " expects a table, got " .. type(t), vim.log.levels.ERROR)
		return false
	end
	return true
end

--- Concatenate tables (modifies first table)
--- @param t1 table Target table to modify
--- @param t2 table Source table to copy from
--- @return table Modified t1
M.concat = function(t1, t2)
	if not validate_table(t1, "concat") or not validate_table(t2, "concat") then
		return t1
	end

	for k, v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

--- Get all keys from a table
--- @param t table
--- @return table Array of keys
M.keys = function(t)
	if not validate_table(t, "keys") then
		return {}
	end

	local keys = {}
	for k, _ in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

--- Get all values from a table
--- @param t table
--- @return table Array of values
M.values = function(t)
	if not validate_table(t, "values") then
		return {}
	end

	local values = {}
	for _, v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

--- Merge tables (creates new table)
--- @param t1 table First table
--- @param t2 table Second table
--- @return table New merged table
M.merge = function(t1, t2)
	if not validate_table(t1, "merge") or not validate_table(t2, "merge") then
		return {}
	end

	local result = {}
	for k, v in pairs(t1) do
		result[k] = v
	end
	for k, v in pairs(t2) do
		result[k] = v
	end
	return result
end

--- Deep merge tables recursively
--- @param t1 table First table
--- @param t2 table Second table
--- @return table New deeply merged table
M.deep_merge = function(t1, t2)
	if not validate_table(t1, "deep_merge") or not validate_table(t2, "deep_merge") then
		return {}
	end

	local result = vim.deepcopy(t1)

	for k, v in pairs(t2) do
		if type(v) == "table" and type(result[k]) == "table" then
			result[k] = M.deep_merge(result[k], v)
		else
			result[k] = v
		end
	end

	return result
end

--- Check if table is empty
--- @param t table
--- @return boolean
M.is_empty = function(t)
	if not validate_table(t, "is_empty") then
		return true
	end

	return next(t) == nil
end

--- Get table length (works for both arrays and hash tables)
--- @param t table
--- @return number
M.length = function(t)
	if not validate_table(t, "length") then
		return 0
	end

	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

--- Check if table contains a value
--- @param t table
--- @param value any
--- @return boolean
M.contains = function(t, value)
	if not validate_table(t, "contains") then
		return false
	end

	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

--- Check if table contains a key
--- @param t table
--- @param key any
--- @return boolean
M.has_key = function(t, key)
	if not validate_table(t, "has_key") then
		return false
	end

	return t[key] ~= nil
end

--- Filter table values using a predicate function
--- @param t table
--- @param predicate function Function that returns true to keep the value
--- @return table New filtered table
M.filter = function(t, predicate)
	if not validate_table(t, "filter") then
		return {}
	end

	if type(predicate) ~= "function" then
		vim.notify("filter expects a function predicate", vim.log.levels.ERROR)
		return {}
	end

	local result = {}
	for k, v in pairs(t) do
		if predicate(v, k) then
			result[k] = v
		end
	end
	return result
end

--- Map table values using a transform function
--- @param t table
--- @param transform function Function to transform each value
--- @return table New table with transformed values
M.map = function(t, transform)
	if not validate_table(t, "map") then
		return {}
	end

	if type(transform) ~= "function" then
		vim.notify("map expects a function transform", vim.log.levels.ERROR)
		return {}
	end

	local result = {}
	for k, v in pairs(t) do
		result[k] = transform(v, k)
	end
	return result
end

--- Reduce table to a single value
--- @param t table
--- @param reducer function Function to reduce values
--- @param initial any Initial value for the accumulator
--- @return any Reduced value
M.reduce = function(t, reducer, initial)
	if not validate_table(t, "reduce") then
		return initial
	end

	if type(reducer) ~= "function" then
		vim.notify("reduce expects a function reducer", vim.log.levels.ERROR)
		return initial
	end

	local accumulator = initial
	for k, v in pairs(t) do
		accumulator = reducer(accumulator, v, k)
	end
	return accumulator
end

--- Find first value that matches predicate
--- @param t table
--- @param predicate function
--- @return any|nil, any|nil value, key
M.find = function(t, predicate)
	if not validate_table(t, "find") then
		return nil, nil
	end

	if type(predicate) ~= "function" then
		vim.notify("find expects a function predicate", vim.log.levels.ERROR)
		return nil, nil
	end

	for k, v in pairs(t) do
		if predicate(v, k) then
			return v, k
		end
	end
	return nil, nil
end

--- Reverse an array table
--- @param t table Array table to reverse
--- @return table New reversed array
M.reverse = function(t)
	if not validate_table(t, "reverse") then
		return {}
	end

	local result = {}
	local len = #t
	for i = 1, len do
		result[i] = t[len - i + 1]
	end
	return result
end

--- Create a slice of an array table
--- @param t table Array table
--- @param start_idx number Starting index (1-based)
--- @param end_idx number|nil Ending index (1-based, inclusive)
--- @return table New sliced array
M.slice = function(t, start_idx, end_idx)
	if not validate_table(t, "slice") then
		return {}
	end

	start_idx = start_idx or 1
	end_idx = end_idx or #t

	local result = {}
	for i = start_idx, end_idx do
		if t[i] ~= nil then
			table.insert(result, t[i])
		end
	end
	return result
end

--- Get unique values from an array table
--- @param t table Array table
--- @return table New array with unique values
M.unique = function(t)
	if not validate_table(t, "unique") then
		return {}
	end

	local seen = {}
	local result = {}

	for _, v in ipairs(t) do
		if not seen[v] then
			seen[v] = true
			table.insert(result, v)
		end
	end

	return result
end

--- Flatten a nested array table
--- @param t table Nested array table
--- @param depth number|nil Maximum depth to flatten (default: 1)
--- @return table Flattened array
M.flatten = function(t, depth)
	if not validate_table(t, "flatten") then
		return {}
	end

	depth = depth or 1
	local result = {}

	local function flatten_recursive(arr, current_depth)
		for _, v in ipairs(arr) do
			if type(v) == "table" and current_depth > 0 then
				flatten_recursive(v, current_depth - 1)
			else
				table.insert(result, v)
			end
		end
	end

	flatten_recursive(t, depth)
	return result
end

return M
