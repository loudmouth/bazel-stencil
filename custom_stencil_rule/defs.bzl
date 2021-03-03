"""
Rules for building and testing Stencil libraries.
"""

load(":build.bzl", _stencil_library = "stencil_library")
load(":test.bzl", _stencil_test = "stencil_test")

stencil_library = _stencil_library
stencil_test = _stencil_test
