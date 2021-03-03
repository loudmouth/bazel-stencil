workspace(
    name = "stencil-bazel",
    managed_directories = {
        "@stencil_1_14_deps": ["stencil_1_14/node_modules"],
        "@stencil_1_15_deps": ["stencil_1_15/node_modules"],
    },
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

##################################################################################################
# Node and TypeScript
##################################################################################################

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "fcc6dccb39ca88d481224536eb8f9fa754619676c6163f87aa6af94059b02b12",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/3.2.0/rules_nodejs-3.2.0.tar.gz"],
)

load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "yarn_install")

node_repositories(
    node_version = "14.12.0",
)

# strict_visibility must be switched off on these directories
# so that the graphql type generator can find deps
yarn_install(
    name = "stencil_1_14_deps",
    package_json = "//stencil_1_14:package.json",
    yarn_lock = "//stencil_1_14:yarn.lock",
)

yarn_install(
    name = "stencil_1_15_deps",
    package_json = "//stencil_1_15:package.json",
    yarn_lock = "//stencil_1_15:yarn.lock",
)

