{$, $$$, EditorView, ScrollView} = require 'atom-space-pen-views'
path = require 'path'
ChildProcess  = require 'child_process'
TextFormatter = require './text-formatter'

class INSpecView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new INSpecView(filePath)

  @content: ->
    @div class: 'inspec inspec-console', tabindex: -1, =>
      @div class: 'inspec-spinner', 'Starting INSpec...'
      @pre class: 'inspec-output'

  initialize: ->
    super
    inspec = this
    atom.commands.add 'atom-workspace','core:copy': (event) ->
      inspec.copySelectedText()

  constructor: (filePath) ->
    super
    console.log "File path:", filePath
    @filePath = filePath

    @output  = @find(".inspec-output")
    @spinner = @find(".inspec-spinner")
    @output.on("click", @terminalClicked)

  serialize: ->
    deserializer: 'INSpecView'
    filePath: @getPath()

  copySelectedText: ->
    text = window.getSelection().toString()
    return if text == ''
    atom.clipboard.write(text)

  getTitle: ->
    "INSpec - #{path.basename(@getPath())}"

  getURI: ->
    "inspec-output://#{@getPath()}"

  getPath: ->
    @filePath

  showError: (result) ->
    failureMessage = "The error message"

    @html $$$ ->
      @h2 'Running INSpec Failed'
      @h3 failureMessage if failureMessage?

  terminalClicked: (e) =>
    if e.target?.href
      line = $(e.target).data('line')
      file = $(e.target).data('file')
      console.log(file)
      file = "#{atom.project.getPaths()[0]}/#{file}"

      promise = atom.workspace.open(file, { searchAllPanes: true, initialLine: line })
      promise.then (editor) ->
        editor.setCursorBufferPosition([line-1, 0])

  run: (lineNumber) ->
    atom.workspace.saveAll() if atom.config.get("inspec.save_before_run")
    @spinner.show()
    @output.empty()
    projectPath = atom.project.getPaths()[0]

    spawn = ChildProcess.spawn

    # Atom saves config based on package name, so we need to use inspec here.
    specCommand = atom.config.get("inspec.command")
    options = " "
    options += " " if atom.config.get("inspec.force_colored_results")
    command = "#{specCommand} #{options} #{@filePath}"
    command = "#{command}:#{lineNumber}" if lineNumber

    console.log "[INSpec] running: #{command}"

    terminal = spawn("bash", ["-l"])

    terminal.on 'close', @onClose

    terminal.stdout.on 'data', @onStdOut
    terminal.stderr.on 'data', @onStdErr

    terminal.stdin.write("cd #{projectPath} && #{command}\n")
    terminal.stdin.write("exit\n")

  addOutput: (output) =>
    formatter = new TextFormatter(output)
    output = formatter.htmlEscaped().colorized().fileLinked().text

    @spinner.hide()
    @output.append("#{output}")
    @scrollTop(@[0].scrollHeight)

  onStdOut: (data) =>
    @addOutput data

  onStdErr: (data) =>
    @addOutput data

  onClose: (code) =>
    console.log "[INSpec] exit with code: #{code}"

module.exports = INSpecView
