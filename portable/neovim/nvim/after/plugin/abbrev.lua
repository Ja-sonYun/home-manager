if require("modules.plugin").mark_as_loaded("abbrev") then
	return
end

local function abolish(lhs, rhs, opts)
	opts = opts or {}
	local flags = {}
	if opts.buffer then
		table.insert(flags, "-buffer")
	end
	if opts.cmdline then
		table.insert(flags, "-cmdline")
	end
	local prefix = (#flags > 0) and (table.concat(flags, " ") .. " ") or ""
	vim.cmd(("Abolish %s%s %s"):format(prefix, lhs, rhs))
end

-- General English typos
abolish("teh", "the")
abolish("adn", "and")
abolish("untill", "until")
abolish("wich", "which")
abolish("becuase", "because")
abolish("hense", "hence")
abolish("alot", "a lot")
abolish("lastest", "latest")
abolish("betwen", "between")
abolish("buisness", "business")
abolish("calender", "calendar")
abolish("cemetary", "cemetery")
abolish("libary", "library")
abolish("neccessary", "necessary")
abolish("resouce{,s}", "resource{}")
abolish("afterword{,s}", "afterward{}")
abolish("delimeter{,s}", "delimiter{}")

-- Desperate / separate variants
abolish("{despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}", "{despe,sepa}rat{}")

-- Receive family
abolish("reciev{e,es,ed,ing,er,ers}", "receiv{}")
abolish("recieve{,s,d,ing,r,rs}", "receive{,s,d,ing,r,rs}")

-- Separate family
abolish("seperat{e,es,ed,ing,ely,ion,ions}", "separat{}")

-- Accommodate / accommodation
abolish("accomodat{e,es,ed,ing,ion,ions}", "accommodat{}")

-- Achieve family
abolish("acheiv{e,es,ed,ing,er,ers,ement,ements}", "achiev{}")

-- Definite / definitely (combined)
abolish("defin{ate,et,it}ly", "definitely")

-- Occur family (combined)
abolish("occur{ed,ing,ence,ences}", "occur{red,ring,rence,rences}")

-- Address family
abolish("adress{,es,ed,ing}", "address{,es,ed,ing}")

-- Environment / argument
abolish("enviroment{,s}", "environment{,s}")
abolish("arguement{,s}", "argument{,s}")

-- Interrupt / embarrass
abolish("interupt{,ed,ing,ion,ions}", "interrupt{,ed,ing,ion,ions}")
abolish("embarass{,ed,ing,ment,ments}", "embarrass{,ed,ing,ment,ments}")

-- Occasion family
abolish("occassion", "occasion")
abolish("ocassion", "occasion")
abolish("occassional{,ly}", "occasional{}")
abolish("occassionally", "occasionally")

-- Common programming typos
abolish("pritn", "print")
abolish("funciton", "function")
abolish("retunr", "return")
abolish("lenght", "length")
abolish("param{a,t,at}er", "parameter")

-- Additional common typos
abolish("independan{t,ce}", "independen{t,ce}")
abolish("wierd", "weird")
abolish("priviledg{e,es,ed,ing}", "privileg{e,es,ed,ing}")
abolish("maintainance", "maintenance")
abolish("threshhold", "threshold")
abolish("truely", "truly")
abolish("accross", "across")
abolish("usefull", "useful")
abolish("seige", "siege")
abolish("definate", "definite")

-- Recommend/Refer/Depend/Compat/Extend families
abolish("recomend{,s,ed,ing,ation,ations}", "recommend{}")
abolish("reccomend{,s,ed,ing,ation,ations}", "recommend{}")
abolish("refer{ed,ing}", "referr{ed,ing}")
abolish("dependanc{y,ies}", "dependenc{y,ies}")
abolish("compatabilit{y,ies}", "compatibilit{y,ies}")
abolish("extention{,s}", "extension{}")
abolish("comming", "coming")
abolish("gaurd", "guard")

-- Occur misspelling variant not covered by combined rule
abolish("occurances", "occurrences")

-- Developer/documentation typos
abolish("defualt", "default")
abolish("udpate", "update")
abolish("verison", "version")
abolish("statment{,s}", "statement{}")
abolish("contruct{,or,ors,ed,ing,ion,ions}", "construct{}")
abolish("initaliz{e,ed,ing,ation}", "initializ{}")
abolish("initiliz{e,ed,ing,ation}", "initializ{}")

-- Brand/technology capitalization
abolish("Github", "GitHub")
abolish("Javascript", "JavaScript")
abolish("Typescript", "TypeScript")
abolish("Postgresql", "PostgreSQL")

-- Check
abolish("cehck", "check")
abolish("healtch", "health")

-- Command-line abbreviations
vim.cmd("cabbrev qq q!")
