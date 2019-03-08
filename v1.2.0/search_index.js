var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#BetweenFlags.jl-1",
    "page": "Home",
    "title": "BetweenFlags.jl",
    "category": "section",
    "text": "For featured functions, visit the Greedy or LevelBased functions."
},

{
    "location": "Functions/Greedy/#",
    "page": "Greedy functions",
    "title": "Greedy functions",
    "category": "page",
    "text": ""
},

{
    "location": "Functions/Greedy/#Greedy-functions-1",
    "page": "Greedy functions",
    "title": "Greedy functions",
    "category": "section",
    "text": "The greedy BetweenFlags functions are similar to regex pattern matching.   The greedy BetweenFlags functions are useful for processing strings to, e.g., remove comments,   where after opening a comment (e.g. triple \"), the first instance of closing the comment must be recognized."
},

{
    "location": "Functions/Greedy/#Examples-1",
    "page": "Greedy functions",
    "title": "Examples",
    "category": "section",
    "text": "  using BetweenFlags\r\n  s = \"Here is some text, and {THIS SHOULD BE GRABBED}, BetweenFlags offers a simple interface...\"\r\n  s = get_flat(s, [\"{\"], [\"}\"])\r\n  print(s)\r\n{THIS SHOULD BE GRABBED}\r\n\r\n  s = \"Here is some text, and {THIS SHOULD BE GRABBED), BetweenFlags} offers a simple interface...\"\r\n  s = get_flat(s, [\"{\"], [\"}\", \")\"])\r\n  print(s)\r\n{THIS SHOULD BE GRABBED)"
},

{
    "location": "Functions/Greedy/#Note-1",
    "page": "Greedy functions",
    "title": "Note",
    "category": "section",
    "text": "These functions are effectively replaceable by regex. They do, however, provide a nice interface. The level-based functions are not, in general, replaceable by regex."
},

{
    "location": "Functions/LevelBased/#",
    "page": "Level-based functions",
    "title": "Level-based functions",
    "category": "page",
    "text": ""
},

{
    "location": "Functions/LevelBased/#Level-based-functions-1",
    "page": "Level-based functions",
    "title": "Level-based functions",
    "category": "section",
    "text": "The level-based version of BetweenFlags is needed for things   like finding functions, where then \"end\" of a function cannot   be confused with the \"end\" of an if statement inside the   function. Therefore, the \"level\" corresponding to that function   should be zero both on the opening and closing of the function."
},

{
    "location": "Functions/LevelBased/#Examples:-1",
    "page": "Level-based functions",
    "title": "Examples:",
    "category": "section",
    "text": "Consider trying to grab all functions defined in a file.  s_i = \"\"\r\n  s_i = string(s_i, \"\\n\", \"Some text\")\r\n  s_i = string(s_i, \"\\n\", \"if something\")\r\n  s_i = string(s_i, \"\\n\", \"  function myfunc()\")\r\n  s_i = string(s_i, \"\\n\", \"    more stuff\")\r\n  s_i = string(s_i, \"\\n\", \"    if something\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    else\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'not something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    end\")\r\n  s_i = string(s_i, \"\\n\", \"    for something\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    else\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'not something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    end\")\r\n  s_i = string(s_i, \"\\n\", \"    more stuff\")\r\n  s_i = string(s_i, \"\\n\", \"  end\")\r\n  s_i = string(s_i, \"\\n\", \"end\")\r\n  s_i = string(s_i, \"\\n\", \"more text\")\r\n\r\n  word_boundaries_left = [\"\\n\", \" \", \";\"]\r\n  word_boundaries_right = [\"\\n\", \" \", \";\"]\r\n  word_boundaries_right_if = [\" \", \";\"]\r\n\r\n  FS_outer = FlagSet(\r\n    Flag(\"function\", word_boundaries_left, word_boundaries_right),\r\n    Flag(\"end\",      word_boundaries_left, word_boundaries_right)\r\n  )\r\n\r\n  FS_inner = [\r\n  FlagSet(\r\n    Flag(\"if\",       word_boundaries_left, word_boundaries_right_if),\r\n    Flag(\"end\",      word_boundaries_left, word_boundaries_right)\r\n  ),\r\n  FlagSet(\r\n    Flag(\"for\",      word_boundaries_left, word_boundaries_right),\r\n    Flag(\"end\",      word_boundaries_left, word_boundaries_right)\r\n  )]\r\n\r\n  L_o = get_level(s_i, FS_outer, FS_inner)\r\n  print(\"\\n -------------- results from complex example: \\n\")\r\n  print(L_o[1])\r\n  print(\"\\n --------------\\n\")\r\n\r\n -------------- results from complex example:\r\n function myfunc()\r\n    more stuff\r\n    if something\r\n      print(\'something\')\r\n    else\r\n      print(\'not something\')\r\n    end\r\n    for something\r\n      print(\'something\')\r\n    else\r\n      print(\'not something\')\r\n    end\r\n    more stuff\r\n  end\r\n\r\n --------------\r\n"
},

{
    "location": "api/#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api/#UtilityFuncs.Flag",
    "page": "API",
    "title": "UtilityFuncs.Flag",
    "category": "type",
    "text": "Flag(word::String,\n     word_boundaries_left::Vector{String},\n     word_boundaries_right::Vector{String})\n\nA flag that BetweenFlags looks for to denote the start/stop position of a given \"level\" or scope. The word boundaries need only be unique since every permutation of left and right word boundaries are taken to determine levels.\n\njulia>\nusing BetweenFlags\n# find: [\"\\nfunction\", \" function\", \";function\"]\nstart_flag = BetweenFlags.Flag(\"function\",\n                               [\"\\n\", \"\\s\", \";\"],\n                               [\"\\n\", \"\\s\"])\n# find: [\"\\nend\", \" end\", \";end\"]\nstop_flag = BetweenFlags.Flag(\"end\",\n                              [\"\\n\", \"\\s\", \";\"],\n                              [\"\\n\", \"\\s\", \";\"])\n\n\n\n\n\n"
},

{
    "location": "api/#UtilityFuncs.FlagSet",
    "page": "API",
    "title": "UtilityFuncs.FlagSet",
    "category": "type",
    "text": "FlagSet(start::Flag, stop::Flag)\n\nA flag set that defines the start and stop of the substring of interest.\n\njulia>\nusing BetweenFlags\n# find: [\"\\nfunction\", \" function\", \";function\"]\nstart_flag = BetweenFlags.Flag(\"function\",\n                               [\"\\n\", \"\\s\", \";\"],\n                               [\"\\n\", \"\\s\"])\n# find: [\"\\nend\", \" end\", \";end\"]\nstop_flag = BetweenFlags.Flag(\"end\",\n                              [\"\\n\", \"\\s\", \";\"],\n                              [\"\\n\", \"\\s\", \";\"])\nflag_set = FlagSet(start_flag, stop_flag)\n\n\n\n\n\n"
},

{
    "location": "api/#FeaturedFuncs.get_flat",
    "page": "API",
    "title": "FeaturedFuncs.get_flat",
    "category": "function",
    "text": "get_flat(s::String,\n                  flags_start::Vector{String},\n                  flags_stop::Vector{String},\n                  inclusive::Bool = true)\n\nGets the substring based on the start and stop flag vectors, and a Bool which determines whether the flags themselves should be returned or not.\n\nThis function will grab the inner-most string, assuming that you do not have multiple start flags before reaching a corresponding stop flag.\n\njulia> s = \"Some text... {GRAB THIS}, some more text {GRAB THIS TOO}...\"\n\"Some text... {GRAB THIS}, some more text {GRAB THIS TOO}...\"\n\njulia> L = BetweenFlags.get_flat(s, [\"{\"], [\"}\"])\n2-element Array{String,1}:\n \"{GRAB THIS}\"\n \"{GRAB THIS TOO}\"\n\n\n\n\n\n"
},

{
    "location": "api/#FeaturedFuncs.get_level_flat",
    "page": "API",
    "title": "FeaturedFuncs.get_level_flat",
    "category": "function",
    "text": "get_level_flat(s::String,\n               flags_start::Vector{String},\n               flags_stop::Vector{String},\n               inclusive::Bool = true)\n\ngetlevelflat gets the substring based on the flags_start and flags_stop vectors, and a Bool which determines whether the flags themselves should be returned or not.\n\nThis function will grab the outer-most string by ignoring stop flags when multiple start flags occur before stop flags.\n\njulia> using BetweenFlags\n\njulia> s = \"Some text... {GRAB {THIS}}, some more text {GRAB THIS TOO}...\"\n\"Some text... {GRAB {THIS}}, some more text {GRAB THIS TOO}...\"\n\njulia> L = BetweenFlags.get_level_flat(s, [\"{\"], [\"}\"])\n2-element Array{String,1}:\n \"{GRAB {THIS}}\"\n \"{GRAB THIS TOO}\"\n\n\n\n\n\n"
},

{
    "location": "api/#FeaturedFuncs.get_level",
    "page": "API",
    "title": "FeaturedFuncs.get_level",
    "category": "function",
    "text": "get_level(s::String,\n          outer_flags::FlagSet,\n          inner_flags::Vector{FlagSet},\n          inclusive::Bool = true)\n\nThis is the featured function of BetweenFlags.\n\nGets the substring based on the outer and inner flag sets, and a Bool which determines whether the flags themselves should be returned or not.\n\nTo see an example of this function in action, go to BetweenFlags/test/runtests.jl.\n\n\n\n\n\n"
},

{
    "location": "api/#BetweenFlags-API-Documentation-1",
    "page": "API",
    "title": "BetweenFlags API Documentation",
    "category": "section",
    "text": "CurrentModule = BetweenFlagsBetweenFlags.Flag\r\nBetweenFlags.FlagSetBetweenFlags.get_flat\r\nBetweenFlags.get_level_flat\r\nBetweenFlags.get_level"
},

]}
