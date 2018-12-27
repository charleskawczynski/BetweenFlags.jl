module GetIncludes

function get_includes(code_dir::String, folders_to_exclude::Vector{String}, print_files::Bool)
  path_separator = Sys.iswindows() ? "\\" : "/"
  all_folders = [joinpath(root,d) for (root, dirs, files) in Base.Filesystem.walkdir(code_dir) for d in dirs]
  all_folders = [string(x) for x in all_folders]
  all_folders = [x for x in all_folders if ! any([occursin(y, x) for y in folders_to_exclude])]
  all_folders = [replace(x, "/" => path_separator) for x in all_folders]
  all_folders = [replace(x, "\\" => path_separator) for x in all_folders]
  all_folders = [x=="." ? x*path_separator : x for x in all_folders]
  if Sys.iswindows()
    all_folders = [replace(x, path_separator => "/") for x in all_folders] # \ escapes characters in Julia
  end
  if print_files
    print("\n******************** Folders :\n")
    for x in all_folders
      print(x, "\n")
    end
    print("********************\n")
  end
  return all_folders
end

end