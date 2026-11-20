.. _subcmd-alias:

Sub-command aliases
===================

This design document describes the :mconfig:`subcmd_alias` configuration
option that defines additional names for the sub-commands of the
:command:`module` command.

Configuration
-------------

- :mconfig:`subcmd_alias` configuration option

  - Colon-separated list of ``alias=target`` definitions
  - Empty by default, no installation option
  - Superseded by the :envvar:`MODULES_SUBCMD_ALIAS` environment variable
  - As a list option, elements may be appended or subtracted with the ``+``
    and ``-`` prefixes of the :subcmd:`config` sub-command. A user is this way
    able to adapt the definitions made site-wide in :file:`initrc`.

Definition validity
-------------------

A definition is taken into account if:

- it is made of exactly one alias name and one target separated by an equal
  sign
- alias name is composed of letters, digits, underscore and hyphen-minus
  characters and does not start with an hyphen-minus
- alias name is not ``ml``, which is not a sub-command but a way to call the
  :command:`ml` command through :file:`modulecmd.tcl`
- target is a sub-command, designated by its name, one of its predefined
  aliases (e.g., ``add``) or abbreviations (e.g., ``av``)

Other definitions are silently ignored, like done for the other configuration
options holding a list of definitions. When an alias is defined several times,
last definition applies.

The character set allowed for alias names is restricted on purpose. Alias
names are consumed by the shell completion scripts, where candidate words go
through constructs that expand them. Restricting names to characters that have
no special meaning for the supported shells guarantees that the content of an
environment variable cannot be evaluated as shell code.

Value reported by :subcmd:`config` sub-command is the list of the valid
definitions, in definition order, with target expressed as the sub-command
name it resolves to.

Resolution
----------

Sub-command name resolution is a two-step process:

1. if the name matches an alias defined in :mconfig:`subcmd_alias`, it is
   replaced by the alias target
2. the result is resolved as before among the sub-command names, their
   predefined aliases and abbreviations

First step is applied once and its result is never passed through it again.
This leads to the following properties:

- An alias always designates a sub-command, never another alias. Definitions
  cannot be chained and cannot loop. With ``find=avail:avail=spider``,
  ``find`` designates :subcmd:`avail`.
- An alias may bear the name of a sub-command, of a predefined alias or of an
  abbreviation. This name is then shadowed: it designates the alias target.
  Two names may be swapped (``avail=list:list=avail``).
- Alias match is exact. An alias cannot be abbreviated, and the abbreviations
  of a shadowed sub-command still designate this sub-command.

No sub-command name is protected against shadowing. If a definition makes
:subcmd:`config` unreachable, unsetting :envvar:`MODULES_SUBCMD_ALIAS` gives
back access to it.

Scope
-----

Aliases apply to the sub-command name set on the command line of the
:command:`module` and :command:`ml` commands. Translation occurs when the
command line is parsed, before any other processing. As a result everything
that depends on the sub-command name behaves as if the target name was typed:
command-line switch parsing, pager activation, result of
:mfcmd:`module-info command<module-info>`, logged event, configuration options
whose value is a list of sub-command names, etc.

With :command:`ml`, the word that may be an alias is the first argument that
is not a command-line switch. An alias name takes precedence over a module of
the same name, like sub-command names do.

Aliases do not apply to the :mfcmd:`module` command evaluated in modulefiles,
run-command files, initialization rc files or sourced script files. What a
modulefile does must not depend on the aliases defined by the user who loads
it, especially as an alias may shadow a sub-command.

Reporting
---------

Defined aliases are listed, sorted by name, in a dedicated section at the end
of the usage message returned by :subcmd:`help` sub-command without argument
and :option:`--help` option. This section is omitted when no alias is defined.

Shell completion
----------------

Completion scripts read :envvar:`MODULES_SUBCMD_ALIAS` to:

- propose alias names among the sub-command candidates
- translate the sub-command word into its target prior selecting the kind of
  candidates to return

Definitions are filtered with the same character set rule than the
:command:`module` command. Target is not checked against the list of
sub-commands: an unknown target just leads to no specific completion.

bash, zsh and fish scripts read the environment variable each time completion
is triggered. tcsh completion relies on static rules: alias rules are
generated from the rule of their target when the completion script is sourced.
Aliases defined afterward in a tcsh session are not completed until this
script is sourced again.

Completion scripts call :command:`module` to fetch candidates (available
modules, loaded modules, collections). :envvar:`MODULES_SUBCMD_ALIAS` is
cleared for these calls to get the expected result even if the name of the
called sub-command is shadowed.

The value set in :file:`initrc` during initialization is exported in
:envvar:`MODULES_SUBCMD_ALIAS`, which makes site-wide definitions visible to
completion scripts.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
