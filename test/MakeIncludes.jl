module MakeIncludes

function make()
  path_separator = Sys.iswindows() ? "\\" : "/"

  up = ".."*path_separator
  code_dir = up*"src"*path_separator

  folders_to_exclude = []
  push!(folders_to_exclude, "output")

  all_folders = [joinpath(root,d) for (root, dirs, files) in Base.Filesystem.walkdir(code_dir) for d in dirs]
  all_folders = [string(x) for x in all_folders]
  all_folders = [x for x in all_folders if ! any([occursin(y, x) for y in folders_to_exclude])]
  all_folders = [replace(x, "/" => path_separator) for x in all_folders]
  all_folders = [replace(x, "\\" => path_separator) for x in all_folders]
  all_folders = [x=="." ? x*path_separator : x for x in all_folders]

  if Sys.iswindows()
    all_folders = [replace(x, path_separator => "/") for x in all_folders] # \ escapes characters in Julia
  end

  # print("\n******************** folders to include:\n")
  # for x in all_folders
  #   print(x, "\n")
  # end
  # print("********************\n")

  open("Includes.jl", "w") do file
    for f in all_folders
      write(file, "push!(LOAD_PATH, \"", f,"\")\n")
    end
  end

end

end