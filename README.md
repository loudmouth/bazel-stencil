# Stencil + Bazel 

This repo illustrates issues with the way Stencil uses rollup to resolve CSS file (paths).

If you haven't used Bazel before, the easiest way to use it is via [Bazelisk](https://github.com/bazelbuild/bazelisk) which will automatically download the correct bazel version for you.

```sh
go get github.com/bazelbuild/bazelisk
```

# Illustrating the issue at hand

There are two example packages showing the difference between building with Stencil (v1.14.0) via Bazel and Stencil (>= 1.15.0) via Bazel.

Each example package has 2 example rules each, one using [`npm_package_bin` from `bazelbuild/rules_nodejs`](https://bazelbuild.github.io/rules_nodejs/Built-ins.html#npm_package_bin) which essentially directly access the binary in `node_modules` and executes it. The other is a custom rule. In both cases, once the version of Stencil is bumped to `v1.15.0` or higher the build failes to resolve the css files during compilation in the Bazel sandbox.


To build and run each:

```sh

# Stencil 1.14.0 (with custom rule located in ./custom_stencil_rule)
# succeeds
bazelisk build //stencil_1_14:stencil_1_14_bazel_lib
# fails
bazelisk build //stencil_1_15:stencil_1_15_bazel_lib

# Using `npm_package_bin` rule
# succeeds
bazelisk build //stencil_1_14:dist_rule
# fails
bazelisk build //stencil_1_15:dist_rule
```

## Understanding the output

Outputs for bazel are built at bazel-out/path/to/architecture/path/to/package/target, but can easily be accessed by opening `bazel-bin` which symlinks to the relevant architecture.

Bazel builds in sandbox environment, then copies the output from the sandbox to the `bazel-bin` with the path segments after `bazel-bin` matching the original directory structure of the project.

The sandbox is deleted after each build, but if you want to keep the folder around to debug, then just add `--sandbox_debug` to any build:

```sh
bazelisk build --sandbox_debug //stencil_1_15:dist_rule
```

To find the sandbox:

```
# bazel-out is also a symlink
cd bazel-out
cd ../../sandbox
```

# Current behavior

When running with Stencil 1.15.0, Rollup is unable to resolve css imports:

```
[ ERROR ]  Rollup: Unresolved Import
           Could not resolve './my-comp.css?tag=my-comp' from
           ./src/components/my-comp/my-comp.tsx
```

# Expected behavior

Import should be reolved
