# Directories
BUILD_DIR  := build
OTHER_DIRS := data
EXT_DIRS   := ext
IMG_DIRS   := img
SRC_DIRS   := src

# Files in the build directory which should not be deleted on a 'clean'
BUILD_PERSIST := 

# The location of the LaTeX sources files
source_extensions := .bib .bst .cls .sty .tex
.bib_directories := $(SRC_DIRS)
.bst_directories := $(EXT_DIRS)
.cls_directories := $(EXT_DIRS)
.sty_directories := $(EXT_DIRS) $(SRC_DIRS)
.tex_directories := $(SRC_DIRS)
