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
    "text": "The greedy BetweenFlags functions are similar to regex pattern matching.   The greedy BetweenFlags functions are useful for processing strings to, e.g., remove comments,   where after opening a comment (e.g. triple \"), the first instance of closing the comment must be recognized.BetweenFlags.get_between_flags_flat(args...)Whereargs = [s::String, flags_start::Vector{String}, flags_stop::Vector{String}]"
},

{
    "location": "Functions/Greedy/#Examples-1",
    "page": "Greedy functions",
    "title": "Examples",
    "category": "section",
    "text": "  using BetweenFlags\n  s = \"Here is some text, and {THIS SHOULD BE GRABBED}, BetweenFlags offers a simple interface...\"\n  s = BetweenFlags.get_between_flags_flat(s, [\"{\"], [\"}\"])\n  print(s)\n{THIS SHOULD BE GRABBED}\n\n  s = \"Here is some text, and {THIS SHOULD BE GRABBED), BetweenFlags} offers a simple interface...\"\n  s = BetweenFlags.get_between_flags_flat(s, [\"{\"], [\"}\", \")\"])\n  print(s)\n{THIS SHOULD BE GRABBED)"
},

{
    "location": "Functions/Greedy/#Note-1",
    "page": "Greedy functions",
    "title": "Note",
    "category": "section",
    "text": "These functions are effectively replace-able by regex. They do, however, provide a nice interface. The level-based functions are not, in general, replace-able by regex (as far as I know)."
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
    "text": "The level-based version of BetweenFlags is needed for things   like finding functions, where then \"end\" of a function should   not be confused with the end of an \"if\" statement inside the   function. Therefore, the \"level\" corresponding to that function   should be zero both on the opening and closing of the function."
},

{
    "location": "Functions/LevelBased/#Examples:-1",
    "page": "Level-based functions",
    "title": "Examples:",
    "category": "section",
    "text": "Consider trying to grab all functions defined in a file.  s_i = \"\"\r\n  s_i = string(s_i, \"\\n\", \"Some text\")\r\n  s_i = string(s_i, \"\\n\", \"if something\")\r\n  s_i = string(s_i, \"\\n\", \"  function myfunc()\")\r\n  s_i = string(s_i, \"\\n\", \"    more stuff\")\r\n  s_i = string(s_i, \"\\n\", \"    if something\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    else\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'not something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    end\")\r\n  s_i = string(s_i, \"\\n\", \"    for something\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    else\")\r\n  s_i = string(s_i, \"\\n\", \"      print(\'not something\')\")\r\n  s_i = string(s_i, \"\\n\", \"    end\")\r\n  s_i = string(s_i, \"\\n\", \"    more stuff\")\r\n  s_i = string(s_i, \"\\n\", \"  end\")\r\n  s_i = string(s_i, \"\\n\", \"end\")\r\n  s_i = string(s_i, \"\\n\", \"more text\")\r\n\r\n  word_boundaries_left = [\"\\n\", \" \", \";\"]\r\n  word_boundaries_right = [\"\\n\", \" \", \";\"]\r\n  word_boundaries_right_if = [\" \", \";\"]\r\n\r\n  FS_outer = FlagSet(\r\n    Flag(\"function\", word_boundaries_left, word_boundaries_right),\r\n    Flag(\"end\",      word_boundaries_left, word_boundaries_right)\r\n  )\r\n\r\n  FS_inner = [\r\n  FlagSet(\r\n    Flag(\"if\",       word_boundaries_left, word_boundaries_right_if),\r\n    Flag(\"end\",      word_boundaries_left, word_boundaries_right)\r\n  ),\r\n  FlagSet(\r\n    Flag(\"for\",      word_boundaries_left, word_boundaries_right),\r\n    Flag(\"end\",      word_boundaries_left, word_boundaries_right)\r\n  )]\r\n\r\n  L_o = get_between_flags_level(s_i, FS_outer, FS_inner)\r\n  print(\"\\n -------------- results from complex example: \\n\")\r\n  print(L_o[1])\r\n  print(\"\\n --------------\\n\")\r\n\r\n -------------- results from complex example:\r\n function myfunc()\r\n    more stuff\r\n    if something\r\n      print(\'something\')\r\n    else\r\n      print(\'not something\')\r\n    end\r\n    for something\r\n      print(\'something\')\r\n    else\r\n      print(\'not something\')\r\n    end\r\n    more stuff\r\n  end\r\n\r\n --------------\r\n"
},

{
    "location": "Functions/api/#",
    "page": "BetweenFlags API Documentation",
    "title": "BetweenFlags API Documentation",
    "category": "page",
    "text": ""
},

{
    "location": "Functions/api/#BetweenFlags-API-Documentation-1",
    "page": "BetweenFlags API Documentation",
    "title": "BetweenFlags API Documentation",
    "category": "section",
    "text": "CurrentModule = BetweenFlagsBetweenFlags.Flag\nBetweenFlags.FlagSetBetweenFlags.get_flat\nBetweenFlags.get_level_flat\nBetweenFlags.get_level"
},

]}
