using Test

function is_test_folder(f, path_separator)
  a = split(f, path_separator)
  dir = joinpath(a[1:end-1]...)
  d = split(dir, path_separator)[end]
  return d=="test"
end

function main()
  path_separator = Sys.iswindows() ? "\\" : "/"

  up = ".."*path_separator
  root_dir = @__DIR__
  root_dir = root_dir*path_separator*up
  code_dir = root_dir*"src"*path_separator

  this_file = @__FILE__
  this_file = replace(this_file, "/" => path_separator)
  this_file = replace(this_file, "\\" => path_separator)
  this_file = split(this_file, path_separator)[end-1:end]
  this_file = code_dir*joinpath(this_file...)

  folders_to_exclude = []
  all_files = [joinpath([root,f]...) for (root, dirs, files) in Base.Filesystem.walkdir(code_dir) for f in files]
  all_files = [x for x in all_files if ! any([occursin(y, x) for y in folders_to_exclude])]
  all_files = [replace(x, "/" => path_separator) for x in all_files]
  all_files = [replace(x, "\\" => path_separator) for x in all_files]
  all_files = [x for x in all_files if is_test_folder(x, path_separator)]
  all_files = [x for x in all_files if !(x==this_file)]
  all_files = [x for x in all_files if split(x, ".")[end]=="jl"] # only .jl files

  # Generate include file for tests:
  run(`julia make.jl`)
  include("includes.jl")

  # Code coverage command line options; must correspond to src/julia.h
  # and src/ui/repl.c
  JL_LOG_NONE = 0
  JL_LOG_USER = 1
  JL_LOG_ALL = 2
  coverage_opts = Dict{Int, String}(JL_LOG_NONE => "none",
                                    JL_LOG_USER => "user",
                                    JL_LOG_ALL => "all")
  coverage_opt = coverage_opts[Base.JLOptions().code_coverage]

  for f in all_files
    cmd = `$(Base.julia_cmd()) --code-coverage=$coverage_opt --inline=no --project=$(Base.current_project()) $f`
    @test (run(cmd); true)
  end

end

main()
