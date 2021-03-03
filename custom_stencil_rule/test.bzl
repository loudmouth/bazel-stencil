"""
Test rules for Stencil.
"""

script_template = """
#!/bin/bash
echo Bazel is running Stencil test

export CONTEXT=$(dirname $(readlink {config}))

./{path} test --config="$CONTEXT/{config_basename}" --spec
"""

def _stencil_test_impl(ctx):
    project_dir = "/".join(ctx.file.stencilconfig.path.split("/")[0:-1])

    action_inputs = []
    action_inputs += ctx.files.srcs
    action_inputs += ctx.files.node_modules
    action_inputs += [ctx.file.stencilconfig, ctx.file.tsconfig]

    script = ctx.actions.declare_file("%s-test" % ctx.label.name)
    script_content = script_template.format(
        path = ctx.executable.compiler.short_path,
        config = ctx.file.stencilconfig.path,
        config_basename = ctx.file.stencilconfig.basename,
    )
    ctx.actions.write(script, script_content, is_executable = True)

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(files = action_inputs + [ctx.executable.compiler], transitive_files = ctx.attr.compiler[DefaultInfo].default_runfiles.files),
            executable = script,
        ),
    ]

stencil_test = rule(
    implementation = _stencil_test_impl,
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
    test = True,
)
