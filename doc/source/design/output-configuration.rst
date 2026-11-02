.. _output-configuration:

Output configuration
====================

Configuration
-------------

- Introduce options to define the content of the output:

  - :mconfig:`avail_output`: elements to report on :subcmd:`avail` sub-command regular mode
  - :mconfig:`avail_terse_output`: elements to report on ``avail`` sub-command terse mode
  - :mconfig:`avail_json_output`: elements to report on ``avail`` sub-command JSON mode
  - :mconfig:`list_output`: elements to report on :subcmd:`list` sub-command regular mode
  - :mconfig:`list_terse_output`: elements to report on ``list`` sub-command terse mode
  - :mconfig:`list_json_output`: elements to report on ``list`` sub-command JSON mode
  - :mconfig:`spider_output`: elements to report on :subcmd:`spider` sub-command regular mode
  - :mconfig:`spider_terse_output`: elements to report on ``spider`` sub-command terse mode
  - :mconfig:`spider_json_output`: elements to report on ``spider`` sub-command JSON mode

Specification
-------------

- Output configuration is available

  - For ``avail`` sub-command, on regular, :option:`--terse` and :option:`--json` modes
  - For ``list`` sub-command, on regular, :option:`--terse` and :option:`--json` modes
  - For ``spider`` sub-command, on regular, :option:`--terse` and :option:`--json` modes

- Output configuration is not available (but could be added later on)

  - For :option:`--long` mode
  - For :subcmd:`aliases`, :subcmd:`savelist`, :subcmd:`stashlist`,
    :subcmd:`whatis`/:subcmd:`search` and :subcmd:`display`/:subcmd:`help`
    sub-commands, including their ``--json`` mode

- Output configuration defines the content of the output not its format

  - Options :option:`--terse`, :option:`--long` and :option:`--json` defines output format

- These configurations are set by default with the elements reported by default

  - ``avail_output``: ``modulepath:alias:dirwsym:sym:tag:variantifspec:key``
  - ``avail_terse_output``: ``modulepath:alias:dirwsym:sym:tag:variantifspec``
  - ``avail_json_output``: ``modulepath:alias:dirwsym:sym:tag:via``
  - ``list_output``: ``header:idx:variant:sym:tag:key``
  - ``list_terse_output``: ``header``
  - ``list_json_output``: ``variant:sym:tag:via``
  - ``spider_output``: ``modulepath:alias:dirwsym:sym:tag:variantifspec:via:key``
  - ``spider_terse_output``: ``modulepath:alias:dirwsym:sym:tag:variantifspec``
  - ``spider_json_output``: ``modulepath:alias:dirwsym:sym:tag:via``

- The above default value could be superseded:

  - with an environment variable, that can be set through the use of the :subcmd:`config` sub-command

    - :envvar:`MODULES_AVAIL_OUTPUT` to supersede ``avail_output`` default value
    - :envvar:`MODULES_AVAIL_TERSE_OUTPUT` to supersede ``avail_terse_output`` default value
    - :envvar:`MODULES_AVAIL_JSON_OUTPUT` to supersede ``avail_json_output`` default value
    - :envvar:`MODULES_LIST_OUTPUT` to supersede ``list_output`` default value
    - :envvar:`MODULES_LIST_TERSE_OUTPUT` to supersede ``list_terse_output`` default value
    - :envvar:`MODULES_LIST_JSON_OUTPUT` to supersede ``list_json_output`` default value
    - :envvar:`MODULES_SPIDER_OUTPUT` to supersede ``spider_output`` default value
    - :envvar:`MODULES_SPIDER_TERSE_OUTPUT` to supersede ``spider_terse_output`` default value
    - :envvar:`MODULES_SPIDER_JSON_OUTPUT` to supersede ``spider_json_output`` default value

  - with the :option:`-o`/:option:`--output` command-line option

    - which applies to the current output mode defined (regular, terse or JSON)
    - ``-o``/``--output`` also supersedes environment variable definition

- Accepted elements in value lists are:

  - For ``avail`` regular and terse options: modulepath, alias,
    provided-alias, dirwsym, indesym, sym, tag, key, variant, variantifspec,
    hidden, via (only on regular output)
  - For ``avail`` JSON option: modulepath, alias, provided-alias, dirwsym,
    sym, tag, variant, variantifspec, hidden, via, mtime
  - For ``list`` regular and terse options: header, idx, variant, alias,
    indesym, sym, tag, key, hidden
  - For ``list`` JSON option: variant, alias, sym, tag, hidden, via, mtime
  - For ``spider`` regular and terse options: modulepath, alias,
    provided-alias, dirwsym, indesym, sym, tag, key, variant, variantifspec,
    hidden, via (only on regular output)
  - For ``spider`` JSON option: modulepath, alias, provided-alias, dirwsym,
    sym, tag, variant, variantifspec, hidden, via, mtime

- If the ``-o``/``--output`` options are wrongly specified

  - An error is raised and evaluation terminates
  - It may happen in the following situations

    - No value set after the option
    - Option set on unsupported module sub-command
    - Element set in option value unsupported by module sub-command
    - Elements set in option value not separated by colon character (``:``)
    - Option set on unsupported output format (``--long``)
    - The above situations apply whether command is called from the terminal or within a modulefile

- For all these new configuration options

  - accepted value is a list of strings separated by colon character (``:``)
  - order of elements in the list does not matter
  - an empty string is a valid value (means only the modulefile name has to be reported)

- If the ``MODULES_AVAIL_OUTPUT``/``MODULES_AVAIL_TERSE_OUTPUT``/
  ``MODULES_AVAIL_JSON_OUTPUT``, ``MODULES_LIST_OUTPUT``/
  ``MODULES_LIST_TERSE_OUTPUT``/``MODULES_LIST_JSON_OUTPUT``,
  ``MODULES_SPIDER_OUTPUT``/``MODULES_SPIDER_TERSE_OUTPUT``/
  ``MODULES_SPIDER_JSON_OUTPUT`` env vars are wrongly specified

  - Their value is ignored
  - So the default value takes precedence, unless a ``-o``/``--output`` option is specified
  - Value in environment variable is wrongly specified for instance in the following situations

    - Element set in option value unsupported by module sub-command
    - Elements set in option value not separated by colon character (``:``)

- ``avail_output`` supersedes ``avail_report_dir_sym`` and ``avail_report_mfile_sym`` configurations

  - Enabled ``avail_report_dir_sym`` corresponds to adding ``dirsym`` value to ``avail_output``
  - Enabled ``avail_report_mfile_sym`` corresponds to adding ``sym`` value to ``avail_output``
  - Both ``avail_report_dir_sym`` and ``avail_report_mfile_sym`` could be removed safely as:

    - it was not possible to define them at configure time
    - or change default value with an environment variable

- Some output content cannot be controlled at the moment with the output options:

  - Hidden modules is exclusively controlled by ``--all`` option to get these modules unveiled
  - Indepth/no-indepth output is exclusively controlled by ``--no-indepth/--indepth`` and related configuration option

- When *modulepath* element is removed from an ``avail`` or ``spider``-related option

  - all the modulefiles returned from all searched modulepaths are merged and sorted as a single set
  - a module appearing in several modulepaths is only reported once
  - tags or symbols applying to a lower priority module with same name are still reported

JSON output
^^^^^^^^^^^

- Rationale

  - Each element in the JSON document is a cost: *variant* requires a scan
    evaluation of every modulefile, *mtime* requires to stat every modulefile
    when no module cache file is available
  - Default content is thus kept minimal to preserve response time and an
    output configuration lets user or site add the elements they need
  - Output configuration is applied to ``--json`` mode through the same
    mechanisms as regular and terse modes (configuration option, environment
    variable and ``-o``/``--output`` command-line option) rather than through
    dedicated options

- The content of the JSON document is defined by the ``<cmd>_json_output``
  configuration option relative to the sub-command run

  - Elements in these options select the JSON keys reported in each module
    object
  - The ``-o``/``--output`` option applies to ``<cmd>_json_output`` when
    ``--json`` mode is set, ``+`` and ``-`` prefixes are supported the same
    way as on regular and terse modes
  - ``-o``/``--output`` is still refused on ``--long`` mode

- Some keys are intrinsic to the JSON objects and are always reported

  - ``name`` and ``type`` keys on every object
  - ``pathname`` key on ``modulefile`` objects
  - ``target`` key on ``alias`` objects
  - When output configuration value is an empty string, module objects only
    hold these keys

- Mapping between elements and the content of the JSON document

  - *modulepath*: top-level JSON object is keyed by modulepath, each value
    being an object keyed by module name (``avail`` and ``spider`` only)
  - *alias*: objects of type ``alias`` are reported
  - *provided-alias*: like *alias* plus the aliases provided by modulefiles,
    which requires a scan evaluation of every modulefile (``avail`` and
    ``spider`` only)
  - *dirwsym*: objects of type ``directory`` are reported for directories
    associated with symbolic versions (``avail`` and ``spider`` only)
  - *sym*: ``symbols`` key is added to ``modulefile``, ``alias`` and
    ``directory`` objects
  - *tag*: ``tags`` key is added to ``modulefile`` and ``alias`` objects
  - *variant*: ``variants`` key is added to ``modulefile`` objects

    - Variants and their possible values on ``avail`` and ``spider``
    - Variant values selected for loaded modules on ``list``

  - *variantifspec*: like *variant* but only if a variant has been specified
    in search query (``avail`` and ``spider`` only)
  - *hidden*: hidden modules are reported, like on regular output mode
  - *via*: ``via`` key is added to every object
  - *mtime*: ``mtime`` key is added to ``modulefile`` objects

- *mtime* is a new element specific to JSON output mode

  - It reports the modification time of the modulefile, like ``--long`` mode
    does on text output
  - Value is a JSON string in ISO 8601 format with local time and UTC offset
    (``YYYY-MM-DDTHH:MM:SS±hhmm``) to be both human-readable and parsable by
    JSON consumers without ambiguity, unlike ``YYYY/MM/DD HH:MM:SS`` format
    used on ``--long`` mode
  - No ``mtime`` key is set on ``alias`` and ``directory`` objects, like
    ``--long`` mode which reports no modification time for them
  - Modification time of virtual modules is the one of the modulefile they
    point to
  - Modification time is only fetched when *mtime* element is enabled, as it
    requires to stat every modulefile when no module cache file is available
    (modification time is recorded in module cache files)
  - *mtime* is not accepted on regular and terse output modes as ``--long``
    mode already serves this purpose there

- Elements not accepted on JSON output mode

  - *key*: no legend is reported on JSON output
  - *header* and *idx* (``list``): JSON document has no introduction sentence
    and the position of a loaded module is its position in the top-level
    object
  - *indesym*: symbolic versions are already reported in the ``symbols`` key
    of the object they are attached to

- When an element is not enabled, its corresponding key is omitted from the
  JSON objects rather than set to an empty value

  - A JSON consumer can tell from the document which elements were reported
  - Document is smaller when few elements are requested

- When *modulepath* element is removed from an ``avail`` or ``spider`` JSON
  option

  - Top-level JSON object is directly keyed by module name, like the ``list``
    sub-command JSON document
  - Modules from the different modulepaths are merged as a single set, with
    the same rules as regular output mode (a module appearing in several
    modulepaths is only reported once)
  - Aliases defined in global/user rc are merged in this single set too

- Default values of ``avail_json_output``, ``list_json_output`` and
  ``spider_json_output`` reproduce the JSON document produced prior to the
  introduction of these options

  - Existing JSON consumers get the exact same document unless configuration
    is changed
  - *variant* is thus part of ``list_json_output`` default value but not of
    ``avail_json_output`` and ``spider_json_output`` default values
  - *via* is part of ``list_json_output`` default value even if its value is
    currently always empty on ``list`` sub-command (see
    :ref:`spider-sub-command` design notes)

- ``--all`` option still unveils hidden modules on JSON output mode, like
  *hidden* element does

- Install-time options are added to change the default value of these
  configuration options

  - ``--with-avail-json-output``
  - ``--with-list-json-output``
  - ``--with-spider-json-output``

Output key
^^^^^^^^^^

- An output key is added to print a legend explaining the output

  - Meaning of ``()``, ``{}`` or ``<>`` is explained
  - Default version is colored specifically
  - Every tag shortened to a defined abbreviation
  - Every tag colored specifically
  - Every variant type set (``variant=value``, ``+boolvariant``, ``-boolvariant``, ``%shortcutvariantvalue``, etc)
  - Legend entries only concern elements that can be found in reported output
  - Legend entries are not reported on JSON output mode

- Output key is enabled by default on ``avail``, ``spider`` and ``list`` sub-command output

  - Key is reported at the end of the output
  - No key section is reported if no element need to be described (no color, no symbol, no tag, etc)

- Variant keys are not adapted for ``avail``/``spider`` output

  - Even if all possible values are reported instead of the only one set
  - Users should be able to understand ``name=val1,val2,...`` corresponds to
    the ``name=value`` key entry
  - Same applies to the shortcut variant key

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
