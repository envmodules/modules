.. _lua-modulefile-support:

Lua modulefile support
======================

The objective is to be able to evaluate Lua modulefiles as Lmod does. Same
syntax should be supported. Also the same precedence mechanisms than Lmod
should be supported regarding mixing Lua and Tcl modulefiles in same
modulepath should.

Evaluating Lua modulefile should have similar performances than Tcl modulefile
evaluation. Of course, it will cost a bit more as a Lua interpreter has to be
run in addition to the Tcl interpreter. But user must not notice the extra
processing time.

Modulefile evaluation
---------------------

For the sake of efficiency as less processes as possible should be involved to
evaluate Lua modulefiles and Lua modulercs.

The idea is to start a persistent Lua script and interact with it to make it
evaluate the successive modulefiles without restart. One Lua script will be
made to evaluate Lua modulefiles, another Lua script will be made to evaluate
Lua modulercs.

The general architecture is to start a Tcl interpreter that starts the
persistent Lua script and interact with it.

The Lua scripts will support all Lua Module functions supported by Lmod. They
will translate these functions into Tcl modulefile commands that will be
sent back to the Tcl interpreter for evaluation.

Lua script also have to update their local environment to get the correct
value for environment variable if these value are accessed later-on by
modulefile.

Environment changes resulting from executed Tcl modulefile commands should be
forwarded to the Lua script to make it update itself.

If executed Tcl modulefile command ends evaluation, this information should be
sent to Lua interpreter to end evaluation on its side.

Error or other kind of messages are sent to the Tcl interpreter as command to
evaluate.

Between two modulefile or modulerc evaluations, Lua script should reset to an
initial state (variable and function reset as done for Tcl interpreter).

Tcl-Lua interpreter bridge implementation
-----------------------------------------

Goal is to have a persistent Lua interpreter connected to a Tcl interpreter:

* Tcl interpreter starts the Lua interpreter as a piped command
* It sends it information on its *stdin* channel

  * Evaluation properties, aka *DATA*
  * Environment variable changes, aka *ENVI*
  * Lua code, aka *CODE*
  * Exit current evaluation, aka *EXIT*

* Lua interpreter sends back information via its *stdout* channel

  * Tcl code to interpret (including error or other messages to raise)
  * End of evaluation signal (via a ``__MODULES_ITRP_ENDEVAL__`` marker)

* Tcl interpreter close pipe to mean end of work
* When *stdin* is not working anymore, Lua interpreter exits

Information exchange from Tcl to Lua
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Information exchange from Tcl interpreter to Lua interpreter is done via the
channel opened when Lua interpreter is executed as a piped command.

Thus Lua interpreter gets the information through its stdin channel. Stdin is
read line by line, within a co-routine, not to block the interpreter execution
with an I/O wait.

Each line read from stdin is analyzed to determine if another line should get
read immediately (before yielding). The ``__MODULES_ITRP_EXCHANGE__`` marker
is used to indicate multiple lines should be read, until reaching another
`__MODULES_ITRP_EXCHANGE__`` marker line.

An empty modulefile content or an empty list of environment change have to be
sent by the Tcl interpreter to release the Lua interpreter from its stdin read
wait.

Reading things line by line may have an impact on performances, for instance
if modulefiles have numerous code lines. It should be evaluated.

Some leads to improve the Tcl-Lua performances:

* Improve asynchronous I/O co-routine mechanism to be able to read full content
  of modulefile in one read call (is this possible?)
* Reduce the number of information to exchange between the 2 interpreter

  * Compute environment variable changes directly within Lua interpreter, but
    it will need to handle any protected variables or other kind of
    mechanisms (but these information may be sent with other properties via
    *DATA*).
  * Send modulefile path instead of content to read it directly from Lua
    interpreter. But doing so, it will not benefit from module cache.

Evaluation end from Tcl or Lua
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Evaluation may end on the Lua side:

* Everything goes well: end of evaluation is signaled by Lua interp to Tcl
* Code does not compile: report module error Tcl code is sent to Tcl
* Code evaluation fails: report module error Tcl code is sent to Tcl unless an
  *EXIT* order was already received from Tcl (a Lua internal marker,
  ``__MODULES_ITRP_EXITEVAL__``, is used to convey this *EXIT* order)

Evaluation may end on the Tcl side:

* Tcl code is evaluated to handle an error raised on the Lua side (either the
  code does not compile or its evaluation fails): in this case, nothing has to
  be sent to the Lua interp, as evaluation is already finished there
* Tcl code evaluation raises an error: an *EXIT* order is sent to the Lua
  interp to kill current evaluation.

Sandboxing evaluation in Lua interpreter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lua provides a convenient ``load`` function to evaluate Lua code. A restricted
environment can be defined for this evaluation. With that feature, the list of
functions reachable by evaluated code can be controlled.

With ``load``, the variables or functions defined by some evaluated code are
accessible from the next ``load`` evaluation. Some cleanup should be done thus
between evaluations, like performed on Tcl side. Such feature may not be
necessary on day 0 as Lmod is not providing such cleaning between evals.

``load`` command first evaluate code to produce a function. During this step
it catches any syntax error. Then this function can be evaluated.

``os.exit`` command is changed into a call to the Tcl ``exit`` modulefile
command. ``os.exit`` would otherwise ends current modulefile evaluation but
also the whole Lua interpreter script.

Handling evaluation modes
^^^^^^^^^^^^^^^^^^^^^^^^^

The various evaluation modes (``load``, ``unload``, etc) are handled by the
Tcl interpreter which is initialized to perform a mode-specific evaluation of
the modulefile commands. As the Lua interpreter sends to the Tcl interpreter
a conversion of the Lua commands in Tcl commands, it does not need to handle
the mode particularities.

The ``help`` Lua command is translated into new ``module-help`` Tcl command
outputting its string argument to the stderr channel.

There is no equivalent of ``ModulesDisplay`` and ``ModulesTest`` in Lmod. Also
Lmod has no ``test`` evaluation mode. Running ``module spider`` evaluates
modules with ``spider`` mode on Lmod whereas ``scan`` mode is used on Modules.

Differences with Lmod
---------------------

This section lists the differences spotted between a Lua modulefile evaluated
with Lmod and Modules. Most differences comes from the translation of the Lua
modulefile commands into Tcl modulefile commands: the former may have
different behavior than the latter.

* ``os.exit`` is evaluated as the Tcl ``exit`` command that does not return
  an exit code value equal to its argument.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
