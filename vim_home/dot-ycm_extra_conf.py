# Copyright (C) 2014 Google Inc.
#
# This file is part of ycmd.
#
# ycmd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ycmd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ycmd.  If not, see <http://www.gnu.org/licenses/>.

# NOTE:  CMake uses '-isystem <DIR>' sometimes instead of '-I' and that seems
# not be interpreted when the compile_commands.json file is read: for example,
# in python-cxx-extension, Vim highlights a million errors because the Python.h
# include is not found.  When I open the compile_commands.json file and manually
# replace -isystem with -I and reopen Vim, I have no errors.


import os
import sys
import subprocess
import ycm_core

import json

# These are the compilation flags that will be used in case there's no
# compilation database set (by default, one is not set).
# CHANGE THIS LIST OF FLAGS. YES, THIS IS THE DROID YOU HAVE BEEN LOOKING FOR.
flags = [
'-Wall',
'-Wextra',
'-Werror',
'-Werror=implicit-function-declaration',
'-fexceptions',
# '-DNDEBUG',
# THIS IS IMPORTANT! Without a "-std=<something>" flag, clang won't know which
# language to use when compiling headers. So it will guess. Badly. So C++
# headers will be compiled as C headers. You don't want that so ALWAYS specify
# a "-std=<something>".
# For a C project, you would set this to something like 'c99' instead of
# 'c++11'.
'-std=c11',
# '-std=c++11',
# ...and the same thing goes for the magic -x option which specifies the
# language that the files to be compiled are written in. This is mostly
# relevant for c++ headers.
# For a C project, you would set this to 'c' instead of 'c++'.
'-I.',
'-I./include',
'-x',
'c',
'-isystem', '/usr/include',
'-isystem', '/usr/local/include',
'-isystem', '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/c++/v1',
'-isystem', '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include',
]


# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags.
def phil_get_compilation_database_folder():
    f = get_cdbf_2()
    if f is not None:
        log(f"compilation database folder is {f}")
        return f

    return get_cdbf_1()

def get_cdbf_2():
    if os.path.isfile(os.path.join(os.getcwd(), 'compilie_commands.json')):
        return os.getcwd()
    cmake_lists = find_cmake_lists()
    log(f"cmake_lists = {cmake_lists}")
    if cmake_lists is None:
        return None
    start = os.path.dirname(cmake_lists)
    log(f"start = {start}")
    cp = subprocess.run(["find", start, "-name", "compile_commands.json"], timeout=5, stdout=subprocess.PIPE, universal_newlines=True)
    log(f"cp.stdout = {cp.stdout}")
    results = cp.stdout.splitlines()
    log(f"results = {results}")
    for r in results:
        return os.path.dirname(r)


def get_cdbf_1():
    result = subprocess.run(
            "git rev-parse --show-toplevel",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            universal_newlines=True
    )
    if result.returncode != 0:
        log("Returning os.getcwd()={os.getcwd()} for compilation database location")
        return os.getcwd()


    log(f"Repodir is {result.stdout}")
    return result.stdout
def find_cmake_lists():
    current = os.environ['PWD']
    last_cmake_lists = None
    while True:
        cmake_lists = os.path.join(current, 'CMakeLists.txt')
        log(f"cmake_lists={cmake_lists}")
        if os.path.isfile(cmake_lists):
            last_cmake_lists = cmake_lists
        elif current == '/':
            return last_cmake_lists
        current = os.path.dirname(current)


def log(message):
    print(message, file=open(os.path.expanduser('~/.log.txt'), 'a+'))

def add_cmake_stuff():
    log("Start add cmake stuff")
    result = subprocess.run(
            "git rev-parse --show-toplevel",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            universal_newlines=True
    )
    if result.returncode != 0:
        return

    repo_dir = result.stdout.strip()
    if not os.path.isfile(f'{repo_dir}/CMakeLists.txt'):
        log("No CMakeLists.txt file in repo")
        return

    if os.path.exists(f'{repo_dir}/compile_commands.json'):
        build_dir = os.path.dirname(os.path.realpath(f'{repo_dir}/compile_commands.json'))
        log(f'compile_commands.json found')
        log(f'ADDING -I{build_dir}')
        flags.append(f'-I{build_dir}')
        flags.append("/usr/include/python3.8")
    else:
        sorted_builds = list(sorted(
            filter(lambda s: s.startswith('build'), os.listdir(repo_dir)),
            key=(lambda f: os.stat(f"{repo_dir}/{f}").st_ctime)
        ))

        if len(sorted_builds) == 0:
            return

        log(f"Adding '-I{repo_dir}/{sorted_builds[0]}'")
        flags.append(f'-I{repo_dir}/{sorted_builds[0]}')

add_cmake_stuff()

compilation_database_folder = phil_get_compilation_database_folder()

def add_includes_from_compilation_commands_json():
    global flags
    if not compilation_database_folder:
        return
    compilation_commands_filename = os.path.join(compilation_database_folder, "compile_commands.json")
    if not os.path.exists(compilation_commands_filename):
        return

    with open(compilation_commands_filename) as f:
        d = json.load(f)

    for elem in d:
        add_includes_from_command(elem['command'])

def add_includes_from_command(command):
    global flags
    words = iter(command.split())
    for w in words:
        if w == "-isystem" or w == "-I":
            inc = next(words)
            log(f"ADDING dir from ['{w}', '{inc}'] to flags")
            flags += [w, inc]
            continue
        if w.startswith("-isystem") or w.startswith("-I"):
            log(f"ADDING dir from ['{w}'] to flags")
            flags += [w]

add_includes_from_compilation_commands_json()

def add_final_flags():
    global flags
    flags += [
        "-I/usr/include/python3.8/",
        "-I./Include",
        "-I./include",
        "-I./inc",
        "-I./Include/internal",
    ]

add_final_flags()
log(f"flags = {flags}")



# PHIL: If the variable 'database' is not None and no compile_commands.json
# exists in compilation_database_folder, then I get no compiler help at all
# so I added the requirement that ${compilation_database_folder}/compile_commands.json
# must exist.
if os.path.exists( compilation_database_folder ):
        #os.path.exists(os.path.join(compilation_database_folder, "compile_commands.json")):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]


def GetCompilationInfoForFile( filename ):
  # The compilation_commands.json file generated by CMake does not have entries
  # for header files. So we do our best by asking the db for flags for a
  # corresponding source file, if any. If one exists, the flags for that file
  # should be good enough.
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


# This is the entry point; this function is called by ycmd to produce flags for
# a file.
def Settings( **kwargs ):
  if not database:
    return {
      'flags': flags,
      'include_paths_relative_to_dir': DirectoryOfThisScript()
    }
  filename = kwargs[ 'filename' ]
  compilation_info = GetCompilationInfoForFile( filename )
  if not compilation_info:
    return None

  # Bear in mind that compilation_info.compiler_flags_ does NOT return a
  # python list, but a "list-like" StringVec object.
  return {
    'flags': list( compilation_info.compiler_flags_ ),
    'include_paths_relative_to_dir': compilation_info.compiler_working_dir_
  }
