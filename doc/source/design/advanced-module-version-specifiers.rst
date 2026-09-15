.. _advanced-module-version-specifiers:

Advanced module version specifiers
==================================

Configuration
-------------

- Introduce :mconfig:`advanced_version_spec` option name

  - off by default in v4 as previously *soft@1* could be a module name
  - on by default in v5
  - in case :mconfig:`extended_default` is disabled

    - means short-hand notation cannot be used

      - for soft/1.1 query soft@1 returns nothing

  - in case :mconfig:`implicit_default` is disabled

    - means a default should be found over version range or list in selection context

Specification
-------------

- Following Spack spec

  - see https://github.com/spack/spack/blob/develop/lib/spack/spack/spec.py
  - or https://spack.readthedocs.io/en/latest/basic_usage.html#version-specifier
  - this specs covers all needs to specify module versions finely
  - Spack users are already familiar with it
  - it copes very well with command-line typing, avoiding most problematic characters

    - that are interpreted by shells (like < or >)

  - specification for one module could

    - be almost condensed into one word "soft@1.8:"
    - or be expanded into multiple "soft @1.8:"

- same grammar used whatever the context

  - command-line or as argument to modulefile command (like command)

- versions are specified whether

  - as specific words (separated by " ")
  - or as suffix to module name

- change command specifications which were previously accepting list of modules

  - like *module1 module2/vers module3*
  - now these modules could express versions appended to their name with *@*

    - like *module1@1.8 module2@vers module3*

  - or these versions could be defined as words next to module name

    - like *module1@1.8 module2 @vers module3*

  - as a consequence, it denies use of *@* in module names
  - such change requires an option to be enabled to avoid breaking compat

- single version could be specified with soft@vers

  - which matches *soft/vers* modulefile

- version could be specified as range

  - *soft@:vers* or *soft@vers:* or *soft@vers1:vers2*
  - Tcl-dictionarily determine what is between specified range
  - ``extended_default`` is always considered *on* when matching range

    - as *2.10* is included in *@1:3* whatever the configuration

  - to be specified in a range or compared to a range, version major element should match an hexadecimal number

    - which also means be only composed by [0-9af] characters
    - for instance *10a*, *1.2.3*, *1.foo*, *10.2.good* are versions valid for range comparison
    - but *10g*, *default*, *foo.2*, *.1.3.4* are versions invalid for range comparison

  - a version range using in its definition version invalid for range comparison raises error

    - for instance *@bar:foo*

  - existing module versions invalid for range comparison are ignored

    - which means versions *10g*, *default*, *.1.13.4* or *new* are excluded from result for a *@1.10:* range query

  - when range is defined as *@major:major.minor*, version matching *major* version but above *major.minor* are excluded

    - for instance *@1:1.10* will matches *1.0* and *1.8* but not *1.12*

  - the upper bound may be less precise than the lower bound

    - an abbreviated upper bound includes all versions that extend it,
      provided they also satisfy the lower bound
    - for instance *@1.2:1* matches *1.2* and *1.10* but not *1.1* or *2.0*
    - a reversed range remains invalid unless the lower bound extends the
      abbreviated upper bound, so *@2.0:1* is still rejected

- version could be specified as list

  - soft@vers,vers,vers
  - version specified could be text, like if symbolic version names are used
  - should benefit from extended default specification

    - to just express version with their major release number for instance

  - an empty string among list is considered as a specification error

    - for instance *soft@vers,vers,* or *soft@vers,,vers*

  - any version in list can be a single version or a version range

    - like *soft@1.2,1.4:1.6,1.8*
    - helps to designate all versions except a few ones

- when using extended default syntax

  - version selection is performed same way for *@vers* than for */vers*
  - described in extended default design

- when :mconfig:`icase` is enabled for selection context and multiple directories match module name

  - for instance query is *ICase@1.1,1.2,1.4* and following modules exist: *ICASE/1.1*, *icase/1.2*, *iCaSe/1.3* and *iCaSe/1.4*
  - as no *ICase* directory exists, and a version in highest directory *icase* matches query (*1.2*), *icase/1.2* is returned
  - if query is *iCaSe@1.1,1.2,1.4*, *iCaSe/1.4* will be selected as *iCaSe* directory matches query module name
  - if query is *ICase@1.1,1.4* or *icase@1.1,1.4*, as no version match in highest directory *iCaSe/1.4* will be selected

- in case of deep modulefiles

  - specified version is matched at the level directly under specified module name

    - not below levels
    - for instance soft@vers, will match *soft/vers*, not *soft/deep/vers*
    - to specify version for deep modules:*"soft/deep@vers*
    - to ease version comparison deep version cannot be specified after the *@* character like *soft@deep/vers*

      - such specification will raise an error

- advanced version specifier cannot be used with full path modulefile

  - when a full path modulefile is specified any advanced version set afterward is treated literally
  - for instance */path/to/modulefiles/mymod@1.2* will lead to the access of file *mymod@1.2* in directory */path/to/modulefiles*

- in case version is specified multiple times

  - lastly mentioned (read from left to right) value is retained (it overwrite previous values)
  - like *module@1.8 @2.0* or *module@1.8@2.0*
  - beware of version specified over a fully qualified modulefile like in *soft/1.8@1.10" or "soft/1.8 @1.10*

    - it resolves to *soft/1.8/1.10* as advanced version specified is treated as an additional directory level

- in case modulefile is named *module@vers* in filesystem

  - it is not found when option ``advanced_version_spec`` is enabled
  - as it is translated to *module/vers*

- when special characters like *?* or \* are used in version name or value

  - they are evaluated as Tcl glob pattern on return all matching modules context
  - they are treated literally on single module selection and compatibility check context, no wildcard meaning is applied
  - like currently done when specifying module version on command-line

    - which leads to errors as no corresponding module is found::

        $ module load loc_dv6/*
        ERROR: Unable to locate a modulefile for 'loc_dv6/*'

- if version range or list does not contain a defined default

  - in a selection context

    - highest version is returned if ``implicit_default`` is enabled
    - error returned if ``implicit_default`` is disabled

      - even if version range or list specifies non-existent modules and only one existent module

  - in a compatibility expression context

    - range or list is matched against loaded environment whether the ``implicit_default`` state
    - when no match found and evaluation are triggered, selection context applies

- when version is specified over an alias

  - should proceed like for real modulefile
  - when alias equal to a bare module with no version

    - foo is alias on bar modulefile, bar is a file (not a dir with version modulefiles)
    - query alias@:2 should behave like query alias/2

  - when alias equal to a module/version modulefile

    - foo is alias on bar/3 modulefile
    - query alias@:2 should behave like query alias/2

- Contexts where it could be used

  - :ref:`module_version_specification_to_return_all_matching_modules`
  - :ref:`module_version_specification_to_select_one_module`
  - :ref:`module_version_specification_to_check_compatibility`

.. note:: Advanced version specifier does not apply for the moment to the
   :ref:`module_identification_to_select_one_module` context. Adding support
   for this context will require a significant rework on module alias and
   symbolic version registering and resolving code.

- impact of advanced version specifier implementation over code

  - question especially over :mconfig:`auto_handling` code like conflict and prereq handling
  - it should not impact triggers and actions
  - but consist in an overall change of procedures comparing queries against loaded environment

    - procedures like ``doesModuleConflict``

  - also adapting ``getModules`` to restrict version possibilities to what has been specified

    - for instance with query *soft@1,2* should only return versions matching

- prereq/conflict persistency

  - ``LMPREREQ`` and ``LMCONFLICT`` content should reflect specified version constraint
  - it could be expressed in these variables somewhat like it is specified to the

    - prereq/conflict modulefile commands
    - for instance ``__MODULES_LMPREREQ=soft/1.10&bar@1.8,1.10&foo@<2|foo@3<4``
    - delimiters characters are *:*, *&* and *|*

      - so use of characters * *, *@*, *,* is not an issue
      - but for *:* which express version ranges it should be substituted to *<*

- prereq/conflict specification

  - could consolidate different version set for same module on the same prereq/conflict list

    - to indicate a preferred order (if available)
    - like ``prereq foo@1.8 foo@1.10``
    - or ``prereq foo @1.8 foo@1.10``

  - also to trigger alternative requirement resolution in case first one failed

    - as each module version specification leads to one evaluation only

      - even if multiple modulefiles correspond to this specification

        - like ``prereq soft@1.8,1.9,1.10`` will lead to *soft/1.10* load

      - best candidate is chosen from matches

        - in case ``implicit_default`` is disabled an explicit default should be part of the list or range for the triggered evaluation to succeed

    - whereas ``prereq soft@1.8 soft@1.9 soft@1.10`` will lead to a tentative load

      - of *soft/1.8*, then *soft/1.9* if it failed then *soft/1.8* if it also failed

  - one module version specification may match multiple loaded modules

    - like ``conflict soft@1.8,1.9,1.10`` matches loaded modules *soft/1.8* and *soft/1.10*
    - similar to situations where requirement or conflict is expressed over module generic name, like *soft*, and multiple versions of module are loaded

Corner cases
------------

- When ``icase`` is enabled on all contexts and multiple directories match same icase module name

  - for instance following modules exist: *ICASE/1.1*, *icase/1.2*, *iCaSe/1.3* and *iCaSe/1.4*
  - a ``module avail -i icase`` will sort *iCaSe/1.4* as the highest entry
  - however a ``module load -i icase@1.1,1.2,1.4`` command will load *icase/1.2*

    - as *icase* directory matches query and version *1.2* is found in *icase* directory

  - but a ``module load -i icase@1.1,1.4`` command will load *iCaSe/1.4*

    - as no version *1.1* nor *1.4* is found in *icase* directory

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
