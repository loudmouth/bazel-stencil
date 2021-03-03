"""
Build rules for Stencil.
"""

load("@build_bazel_rules_nodejs//:providers.bzl", "DeclarationInfo", "JSEcmaScriptModuleInfo", "JSModuleInfo", "JSNamedModuleInfo")


def _stencil_library_impl(ctx):
    action_outputs = []
    dist = ctx.actions.declare_directory("dist", sibling = ctx.file.stencilconfig)
    action_outputs.append(dist)

    # TS declarations
    declaration = ctx.actions.declare_file("dist/loader/components.d.ts")
    types = ctx.actions.declare_directory("dist/types")

    es5_outputs = [
        ctx.actions.declare_directory("dist/esm"),
        ctx.actions.declare_directory("dist/esm-es5"),
        ctx.actions.declare_directory("dist/just-elements"),
        # es5 loads custom elements
        ctx.actions.declare_directory("dist/loader"),
        ctx.actions.declare_directory("dist/csj"),
    ]
    # not needed
    # collection_transpiled_components = ctx.actions.declare_directory("dist/collection")

    package_json = ctx.actions.declare_file("package.json")

    # project_dir = "/".join(ctx.file.stencilconfig.path.split("/")[0:-1])

    action_inputs = []
    action_inputs += ctx.files.srcs
    action_inputs += ctx.files.node_modules
    action_inputs += [ctx.file.stencilconfig, ctx.file.tsconfig]

    build_script = ctx.actions.declare_file("%s-stencil-build" % ctx.label.name)
    build_script_template = """
#!/bin/bash
echo Bazel is running Stencil build

export RUNFILES_DIR="$(readlink {path}).runfiles"

./{path} build --config={config}

cp -r libraries/just-elements-v2/dist/. {distpath}
cp -r libraries/just-elements-v2/src/components.d.ts {distpath}/loader/components.d.ts
"""
    build_script_content = build_script_template.format(
        path = ctx.executable.compiler.path,
        config = ctx.file.stencilconfig.path,
        distpath = dist.path,
    )
    ctx.actions.write(build_script, build_script_content, is_executable = True)

    ctx.actions.run(
        progress_message = "Compiling Stencil %s" % (ctx.label),
        inputs = action_inputs,
        outputs = action_outputs + [declaration] + [types] + es5_outputs,
        executable = build_script,
        tools = [ctx.executable.compiler],
    )

    ctx.actions.run_shell(
        inputs = [ctx.file.package_json],
        outputs = [package_json],
        command = "cp %s %s" % (ctx.file.package_json.path, package_json.path),
    )

    script = ctx.actions.declare_file("%s-stencil" % ctx.label.name)
    script_template = """
#!/bin/bash
echo Bazel is running Stencil server ...

export RUNFILES_DIR="$(readlink {shortpath}).runfiles"

./{shortpath} build --dev --watch --serve --config={config}
"""
    script_content = script_template.format(
        shortpath = ctx.executable.compiler.short_path,
        config = ctx.file.stencilconfig.path,
    )
    ctx.actions.write(script, script_content, is_executable = True)

    files = depset(transitive = [depset(action_outputs), depset([package_json])])
    runfiles = ctx.runfiles(files = action_inputs + [ctx.executable.compiler])

    # buildifier: disable=rule-impl-return
    return struct(
        providers = [
            DefaultInfo(
                files = files,
                runfiles = runfiles,
                executable = script,
            ),
            DeclarationInfo(
                declarations = depset([declaration] + [types]),
                transitive_declarations = depset([]), 
                type_blacklisted_declarations = depset([]),
            ),
            JSModuleInfo(
                direct_sources = depset(es5_outputs),
                sources = depset(es5_outputs),
            ),
            JSNamedModuleInfo(
                direct_sources = depset(es5_outputs),
                sources = depset(es5_outputs),
            ),
            JSEcmaScriptModuleInfo(
                direct_sources = depset([]),
                sources = depset([]),
            ),
        ],
    )


stencil_library = rule(
    implementation = _stencil_library_impl,
    attrs = {
        "compiler": attr.label(
            mandatory = True,
            cfg = "host",
            executable = True,
        ),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "package_json": attr.label(allow_single_file = True),
        "tsconfig": attr.label(allow_single_file = True),
        "stencilconfig": attr.label(allow_single_file = True),
        "node_modules": attr.label(allow_files = True),
    },
    executable = True,
)
