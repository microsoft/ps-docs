# PSDocs

Generate documentation from Infrastructure as Code (IaC) using PSDocs.
PSDocs allows you to dynamically generate markdown from infrastructure code artifacts.
Use pre-build modules or build your own.

To learn about PSDocs and how you can build documentation dynamically see [Getting started](https://github.com/microsoft/PSDocs#getting-started).

## Usage

<!-- To get the latest stable release use:

```yaml
- name: Generate docs
  uses: Microsoft/ps-docs@v0.1.0
``` -->

To get the latest bits use:

```yaml
- name: Generate docs
  uses: Microsoft/ps-docs@main
```

For a list of changes please see the [change log].

## Inputs

```yaml
- name: Generate docs
  uses: Microsoft/ps-docs@main
  with:
    inputPath: string       # Optional. The path PSDocs will look for files to input files.
    modules: string         # Optional. A comma separated list of modules to use containing document definitions.
    source: string          # Optional. An path containing definitions to use for generating documentation.
    conventions: string     # Optional. A comma separated list of conventions to use for generating documentation.
    outputPath: string      # Optional. The path to write documentation to.
    path: string            # Optional. The working directory PSDocs is run from.
    prerelease: boolean     # Optional. Determine if a pre-release module version is installed.
```

### `inputPath`

The path PSDocs will look for files to input files.
Defaults to repository root.

### `modules`

A comma separated list of modules to use containing document definitions.

Modules are additional packages that can be installed from the PowerShell Gallery.
PSDocs will install the latest **stable** version from the PowerShell Gallery automatically by default.
[Available modules](https://www.powershellgallery.com/packages?q=Tags%3A%22PSDocs-documents%22).

To install pre-release module versions, use `prerelease: true`.

### `source`

An path containing definitions to use for generating documentation.
Defaults to `.ps-docs/`.

Use this option to include document definitions that have not been packaged as a module.

### `conventions`

A comma separated list of conventions to use for generating documentation.

Conventions are code blocks that provide extensibility and integration.
They can be included in `.Doc.ps1` files from `.ps-docs/` or modules.

See [about_PSDocs_Conventions][2] for more information.

  [2]: https://github.com/microsoft/PSDocs/blob/main/docs/concepts/PSDocs/en-US/about_PSDocs_Conventions.md

### `outputPath`

The path to write documentation to.

### `path`

The working directory PSDocs is run from.
Defaults to repository root.

Options specified in `ps-docs.yaml` from this directory will be used unless overridden by inputs.

### `prerelease`

Determine if a pre-release rules module version is installed.
When set to `true` the latest pre-release or stable module version is installed.

If this input is not configured, invalid, or set to `false` only stable module versions will be installed.

## Using the action

To use PSDocs:

1. See [Creating a workflow file](https://help.github.com/en/articles/configuring-a-workflow#creating-a-workflow-file).
2. Reference `Microsoft/ps-docs@main`.
For example:

```yaml
name: CI
on: [push]
jobs:
  docs:
    runs-on: ubuntu-latest
    steps:

    - name: Checkout
      uses: actions/checkout@main

    - name: Generate docs
      uses: Microsoft/ps-docs@main
```

3. Run the workflow.

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to
agree to a Contributor License Agreement (CLA) declaring that you have the right to,
and actually do, grant us the rights to use your contribution. For details, visit
https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need
to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the
instructions provided by the bot. You will only need to do this once across all repositories using our CLA.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Maintainers

- [Bernie White](https://github.com/BernieWhite)
- [Vic Perdana](https://github.com/vicperdana)

## License

This project is [licensed under the MIT License](LICENSE).

[change log]: CHANGELOG.md
