.. _module-tags:

Module tags
===========

Configuration
-------------

- No specific configuration

Specification
-------------

- Introduce one new modulefile command to set tags on modulefiles: :mfcmd:`module-tag`

  - A tag is a piece of information associated to individual modulefiles
  - That is reported along module name on ``avail``, ``spider`` or ``list`` sub-command results
  - This piece of information could lead to specific behaviors when handling modulefile over the different module sub-commands or modulefile evaluation modes

    - For instance, a module with a ``sticky`` tag set on it cannot be unloaded

- Tag may also be set manually with the :option:`--tag` sub-command option

  - Applies to :subcmd:`load`, :subcmd:`try-load`, :subcmd:`load-any` and :subcmd:`switch` sub-commands
  - When directly used from the terminal session or within modulefile
  - Applies to :mfcmd:`always-load`, :mfcmd:`depends-on`, :mfcmd:`prereq`, :mfcmd:`prereq-all` and :mfcmd:`prereq-any` modulefile commands

- 3 different kind of tag exist:

  - Those inherited from module state, consequence of a specific modulefile command or module action

    - This kind of tag cannot be defined with the ``module-tag`` command

      - An error is returned otherwise
      - Specific modulefile command should be used instead as such tag may have specific properties that should also be defined along
      - Easier for everybody to only have one way to define such tags and not 2 different commands

    - Every tag holding specific properties should have its dedicated modulefile command to define it

  - Those set with ``module-tag`` or ``--tag`` option that lead to a specific behavior
  - Those set with ``module-tag`` or ``--tag`` option that are purely informational, no specific behavior

- Tags inherited from module state:

  - ``hidden``: module not visible, not reported by default in ``avail`` and ``spider`` result (tag acquired through :mfcmd:`module-hide`)
  - ``hidden-loaded``: loaded module not reported by default in ``list`` result (tag acquired through ``module-hide --hidden-loaded`` or ``--tag`` option)
  - ``forbidden``: module that cannot be loaded (tag acquired through :mfcmd:`module-forbid`)
  - ``nearly-forbidden``: module that soon cannot be loaded (tag acquired through ``module-forbid``)
  - ``loaded``: loaded module
  - ``auto-loaded``: module automatically loaded by another module
  - ``warning``: warning message reported on load (tag acquired through ``module-warn``)

- Tags set with ``module-tag`` or ``--tag`` option associated to a specific behavior:

  - ``sticky``: loaded module cannot be unloaded unless forced or reloaded or when restoring a collection or initial environment (see :ref:`sticky-modules`)
  - ``super-sticky``: loaded module cannot be unloaded even if forced, it stills can be unloaded if reloaded afterward (see :ref:`sticky-modules`)
  - ``keep-loaded``: auto_handling mechanism does not unload auto-loaded module

- Starting Modules 5.7, :subcmd:`purge` also preserves the direct and
  indirect requirements of retained ``sticky`` or ``super-sticky`` modules.
  Requirements do not inherit these tags. Their unload is skipped according
  to :mconfig:`sticky_purge`, including when a requirement has no sticky tag.
  With :option:`--force`, only requirements needed by retained super-sticky
  modules are protected by this mechanism.

- Tags inherited from module state cannot be set with ``module-tag`` command

  - An error is otherwise thrown

- Tags inherited from module state cannot be set with ``--tag`` option

  - Exception made for ``hidden-loaded`` tag
  - An error is otherwise thrown

- Modules project may introduce in the future new tags inherited from new states or new specific behaviors

  - These new tags will supersede tags set by users using the same naming


Defining
^^^^^^^^

- ``module-tag [options] tag modspec...``

  - Apply ``tag`` to all modules matching ``modspec`` module specification
  - :ref:`advanced-module-version-specifiers` are supported if relative module option is enabled
  - Full path module specification is not supported, as modulerc are not evaluated when reaching a modulefile specified as full path
  - One tag could be applied to multiple module specifications with a single ``module-tag`` command call

- ``module-tag`` accepts the following options:

  - ``--not-user``: specify a list of users unaffected by specified tagging
  - ``--not-group``: specify a list of groups whose member are unaffected by specified tagging
  - ``--user``: specify a list of users specifically affected by specified tagging
  - ``--group``: specify a list of groups whose member are specifically affected by specified tagging

- ``--user``, ``--group``, ``--not-user`` and ``--not-group`` specification is only supported on Unix platform

  - These options raise an error when used on Windows platform
  - In which case relative ``module-tag`` command is made ineffective as well as remaining content of the modulerc script hosting them
  - Error message is clearly seen when trying to load related modules and indicate where to find the erroneous command

- ``--user`` and ``--group`` options prevail over ``--not-user`` and ``--not-group`` options

  - When ``--user`` or ``--group`` is set, exclusion list from ``--not-user`` and ``--not-group`` are ignored

- ``module-tag`` is intended to be used in modulerc files

  - to be easily fetched during ``avail`` and ``spider`` sub-commands processing
  - they also need to be enabled in modulefile context as global/user rc files are evaluated as modulefile, not modulerc
  - it enables to dissociate environment changes described in the modulefile from the properties of this modulefile

    - as these properties are usually site-specific
    - and modulefile are automatically generated by a build tool
    - but properties are not always related and set by the build tool

- ``module load --tag tag modspec...``

  - Apply ``tag`` to the loading module selected through ``modspec`` module specification
  - Available from all loading module sub-commands (``load``, ``try-load``, ``load-any`` and ``switch``)
  - Option is preferably written:

    - ``--tag=tag`` when called from command-line
    - ``--tag tag`` when called from modulefile
    - but both syntaxes work from both locations

  - Multiple tags can be set at once by providing a tag list separated by ``:``

    - e.g., ``--tag foo:bar`` or ``--tag=foo:bar``


Persistency
^^^^^^^^^^^

- The :envvar:`__MODULES_LMTAG` environment variable holds all tag information applying to loaded modules

  - Following the same syntax scheme than ``__MODULES_LMCONFLICT``
  - For instance ``module/vers&tag&tag:module2&tag``

- The ``loaded`` tag is not recorded in ``__MODULES_LMTAG`` environment variable

  - As it obviously applies to all loaded modules defined in ``LOADEDMODULES`` environment variable

- The ``auto-loaded`` tag is now recorded in ``__MODULES_LMTAG`` environment variable

  - Before version 5.0, this tag was not recorded and auto loaded modules where listed in the ``__MODULES_LMNOTUASKED`` environment variable
  - This environment variable has been removed in Modules 5.0

- Tags applied to loaded modules are saved in collection

  - Saving tags in collection is introduced in Modules 5.1
  - When one or more tags are set on a module to save, the
    ``--tag=tag1:tag2`` option is added

    - After ``module load``
    - And before module specification

  - When option ``--tag=`` is found on a module to restore

    - Defined tags are transmitted to apply them to the module to load

  - With this change, the ``--notuasked`` option used in collection
    previously to indicate module has been auto loaded is replaced by
    ``--tag=auto-loaded`` option

  - No difference is made between tags set manually (through ``--tag``
    option) or tags set in modulerc (through ``module-tag`` or loaded module
    states): both kind of tags are recorded in collection

- The :mconfig:`collection_pin_tag` configuration option determines what tags
  should be recorded in collection

  - When disabled (default), only the tags set through ``--tag`` option or
    resulting from the way the module has been loaded (``auto-loaded`` and
    ``keep-loaded`` tags) are recorded in collections
  - When enabled, all tags applying to modules are recorded
  - Exception made for ``nearly-forbidden`` tag, as its temporal meaning
    is not fit for being saved
  - Changing default value of :mconfig:`collection_pin_tag` defines the
    :envvar:`MODULES_COLLECTION_PIN_TAG` variable

- The :envvar:`__MODULES_LMEXTRATAG` environment variable holds all tags
  applying to loaded modules that have been set through the ``--tag`` option

  - It helps to distinguish these specifically set tags from the others
  - To only record these tags and those resulting from the way the module
    has been loaded (like ``auto-loaded``) in collections by default
  - The following tags set with ``--tag`` option but which describe a
    specific state of loaded module are excluded from
    ``__MODULES_LMEXTRATAG`` record:

    - ``auto-loaded``
    - ``keep-loaded``

- When a collection saved with ``collection_pin_tag`` option enabled is
  restored all tags set are then considered extra tags (as they are found set
  through the ``--tag`` option).


Reporting
^^^^^^^^^

- Defined tags are reported on ``avail``, ``spider`` and ``list`` sub-command results

  - Reported along modulefile name, within angle brackets (following the HTML tag fashion)
  - Each tag separated by a colon
  - For instance ``module/version <tag1:tag2>``
  - Tags are right-aligned on each column
  - One space character at least separates module name and version or list of symbolic version from tag list

- Defines tags are reported on module evaluation message block

  - Applies to *Loading*, *Unloading*, *Refreshing*, *Tagging* message blocks
  - Only for the module designation set in the header of the block

    - Not on the error message, or list of requirement loaded/unloaded
    - To avoid overloading the output

  - Tags are reported the same way than on ``list`` sub-command
  - If load evaluation fails, the tags are not reported as they were not yet set

- Tags applying to module alias are reported on ``avail`` and ``spider`` reports only

  - Where the module alias stands for itself in the report
  - On ``list`` reports, alias is reported along its modulefile target

    - So the tags applying to the alias are not reported
    - Also these tags of the alias are not inherited by alias' target

- Tags applying to symbolic version are never reported

  - As symbols are never reported alone on ``avail``, ``spider`` or ``list`` reports
  - Always reported along their modulefile target
  - Also these tags of the symbolic versions are not inherited by symbol's target

- Some tags are not reported on ``avail`` and ``spider`` outputs:

  - ``hidden-loaded``: correspond to hiding module from loaded list, not from available list

- Some tags are not reported on ``list`` output:

  - ``loaded``: as every modules reported on ``list`` are loaded
  - ``forbidden``: forbidden module cannot be loaded, so it cannot be found among loaded module list
  - ``hidden``: correspond to hiding module from availabilities, not from loaded list

- When reported in JSON output format

  - tags are listed under the ``tags`` key

- Default ``--long`` report does not contain tag information

  - Not to exceed the 80-column output limit by default

Abbreviations
"""""""""""""

- Tag abbreviations are used to translate tag names when reporting them on ``avail``, ``spider`` or ``list`` sub-command output

- The :mconfig:`tag_abbrev` configuration defines the abbreviations to apply to each tag

  - Set by default at configure time to ``auto-loaded=aL:loaded=L:hidden=H:hidden-loaded=H:forbidden=F:nearly-forbidden=nF:sticky=S:super-sticky=sS:keep-loaded=kL:warning=W``

    - Note that by default, *hidden* and *hidden-loaded* tags share the same abbreviation, as they operate on separate contexts (respectively avail and list contexts)

  - Configuration value consists in a ``key=val`` pair value, each key pair are separated by a ``:`` character

    - Follow the same syntax than ``colors`` configuration

  - If an existing tag name is not part of the configuration, it means no abbreviation applies to it

  - If a tag name has an empty string abbreviation defined it is not reported

    - Unless if there is an SGR color configuration defined for this tag

  - The :envvar:`MODULES_TAG_ABBREV` environment variable is used to set a specific value for ``tag_abbrev`` configuration

    - If ``MODULES_TAG_ABBREV`` is set to an empty string, no tag abbreviation applies

- In case default value or environment value of ``tag_abbrev`` is badly set

  - a warning message is returned
  - value is ignored
  - if nor the environment nor the default value is correct then no abbreviation applies to tag

- Tags are not translated to their defined abbreviation in JSON output format

SGR
"""

- If a tag name or tag abbreviation has an SGR code defined in the color list, this SGR code is applied to the module name this tag refer to

  - Tag name or abbreviation is not reported by itself in this case
  - As it is now represented by the SGR applied to module name
  - If an abbreviation exists for a tag, SGR code should be defined for this abbreviation in color list

    - An SGR code set for tag full name does not apply on the abbreviation of this tag

- If multiple tags apply to the same modules and have an SGR code defined for them in the color list

  - All these SGR codes are rendered one after the other over the module name
  - For instance if 2 tags apply, the first one will be rendered over the first half of the module name, the second tag over the second half of

- Tags use by default background color change to stand out

  - As module kind (alias, directory, etc) is mainly represented with foreground color change by default,

- In case if there are more tags to graphically render than character in module name

  - The remaining tags are reported by there name or abbreviation and SGR applies over this name or abbreviation

- The :envvar:`MODULES_TAG_COLOR_NAME` environment variable is used to define the tags whose name (or abbreviation if set) should be reported

  - Their name does not vanish if a SGR code is defined in the color list for them
  - Their SGR code is not rendered over the module name
  - Instead the SGR is applied to the reported tag name (or tag abbreviation if set)
  - ``MODULES_TAG_COLOR_NAME`` is bound to the :mconfig:`tag_color_name` configuration
  - ``MODULES_TAG_COLOR_NAME`` contains the list of tag name (or abbreviation), each tag separated with colon character (``:``)
  - If an abbreviation is defined for a tag and one want it to be reported by itself not rendered over module name

    - This abbreviation should be set in ``MODULES_TAG_COLOR_NAME``
    - Not the full tag name this abbreviation refers to

Querying
^^^^^^^^

- The ``tags`` sub-command of :mfcmd:`module-info` modulefile command enables modulefile to know what tags apply to itself

  - ``module-info tags`` returns a list of all the tags applying to currently evaluated module
  - an empty list is returned when called from a modulerc evaluation context or if no tag applies to current modulefile

- Tags cannot be queried to select modules

  - Symbolic versions or variants can be used to select modules

Updating tags on already loaded modules
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- An attempt to load an already loaded module with a ``--tag`` option set will
  update the list of extra tags set for this loaded module

  - Works for every sub-command and modulefile commands accepting the
    ``--tag`` option
  - Does not imply the reload of the loaded module
  - Add tags to the tag list already set, no removal
  - As tags defined with ``module-tag`` cannot be unset

- A ``tag`` sub-command may seem useful to update tag list of already loaded
  modules

  - But it is simpler to use the loading/enabling sub-command to set these
    extra tags, especially to distinguish between tagging modules or
    modulepaths
  - So no need for a dedicated sub-command, use loading or enabled
    sub-commands instead

- If extra tags specified are already set as non-extra tags on already loaded
  module, the tags are not updated (extra tag list is not updated)

- With ``prereq``-like commands:

  - all loaded requirement in specified list get their tag list updated
  - loading requirement does not get its tag list updated (no real use case
    foreseen for cyclic dependencies)

- When restoring collection, extra tags of modules are unset to only keep the
  extra tags defined in collection.

  - Extra tags are cleared either when module is unloaded or specifically
    if module is already loaded at the correct position

- When unloading a module, the ``auto-loaded``, ``keep-loaded`` and all
  extra tags are unset from in-memory knowledge, not to reapply automatically
  these tags if the module is loaded again: only the extra and state tags
  from this new load will be set.

Tags set over full path module designation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sometimes a tag should be applied on a specific modulefile whose name and
version is available in several modulepaths. For that need, tag has to be set
over full path module designation.

Tags set over module full path designation cannot be mixed with tags set over
regular module name and version as they only apply to the one modulefile in
one modulepath and not to every module using the same short name and version
designation.

Forbidden tag set over module full path designation and its properties get
precedence over same tag's properties set over short module name and version.

It makes code more complex as full path designation has to be passed as
argument along short name to get all tags applying to module.

When checking tag definition for stickiness, if tag is set over full path
module then it means stickiness applies to fully qualified module. Thus it
cannot be swapped by another version of this module. Defining stickiness over
full path module directory is not possible as full path designation should
match a modulefile.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
