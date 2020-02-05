# Verible

The Verible project's main mission is to parse SystemVerilog (IEEE 1800-2017)
for a wide variety of applications.

It was born out of a need to parse *un-preprocessed* source files, which is
suitable for single-file applications like style-linting and formatting. In
doing so, it can be adapted to parse *preprocessed* source files, which is what
real compilers and toolchains require.

The spirit of the project is that no-one should ever have to develop a
SystemVerilog parser for their own application, because developing a
standard-compliant parser is an enormous task due to the syntactic complexity of
the language.

A lesser (but notable) objective is that the language-agnostic components of
Verible be usable for rapidly developing language support tools for other
languages.


See the [README file for further information.](README.md)

## Tools

 * [verilog_lint Info](verilog_lint.md)
 * [verilog_format Info](verilog_format.md)
 * [verilog_syntax Info](verilog_syntax.md)

## Information

 * [Code - https://github.com/mithro/verible](https://github.com/mithro/verible)
 * [Binaries - https://github.com/mithro/verible/releases](https://github.com/mithro/verible/releases)
 * [Bug Reports - https://github.com/mithro/verible/issues/new](https://github.com/mithro/verible/issues/new)
 * [Lint Rules](lint.md)
 * [Further Information](README.md)

## Authors

 * [Contributing](CONTRIBUTING.md)
 * [Authors](AUTHORS.md)
 * [License Information](license.md)

## Version

Generated on Wed Feb  5 19:54:06 UTC 2020 from [v0.0-186-g82a737d](https://github.com/mithro/verible/commit/82a737d50efb23c8cd7d5c59524597d76eb82eb2)
