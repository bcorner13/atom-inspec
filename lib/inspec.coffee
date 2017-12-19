INSpecView = require './inspec-view'
{CompositeDisposable} = require 'atom'
url = require 'url'

module.exports =
  config:
    command:
      type: 'string'
      default: 'inspec'
    spec_directory:
      type: 'string'
      default: 'spec'
    save_before_run:
      type: 'boolean'
      default: false
    force_colored_results:
      type: 'boolean'
      default: true
    split:
      type: 'string'
      default: 'right'
      description: 'The direction in which to split the pane when launching inspec'
      enum: [
        {value: 'right', description: 'Right'}
        {value: 'left', description: 'Left'}
        {value: 'up', description: 'Up'}
        {value: 'down', description: 'Down'}
      ]


  inspecView: null
  subscriptions: null

  activate: (state) ->
    if state?
      @lastFile = state.lastFile
      @lastLine = state.lastLine

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'inspec:run': =>
        @run()

      'inspec:run-for-line': =>
        @runForLine()

      'inspec:run-last': =>
        @runLast()

      'inspec:run-all': =>
        @runAll()

    atom.workspace.addOpener (uriToOpen) ->
      {protocol, pathname} = url.parse(uriToOpen)
      return unless protocol is 'inspec-output:'
      new INSpecView(pathname)

  deactivate: ->
    @inspecView.destroy()
    @subscriptions.dispose()

  serialize: ->
    if @inspecView
      inspecViewState: @inspecView.serialize()
    lastFile: @lastFile
    lastLine: @lastLine

  openUriFor: (file, lineNumber) ->
    @lastFile = file
    @lastLine = lineNumber

    previousActivePane = atom.workspace.getActivePane()
    uri = "inspec-output://#{file}"
    atom.workspace.open(uri, split: atom.config.get("inspec.split"), activatePane: false, searchAllPanes: true).then (inspecView) ->
      if inspecView instanceof INSpecView
        inspecView.run(lineNumber)
        previousActivePane.activate()

  runForLine: ->
    console.log "Starting runForLine..."
    editor = atom.workspace.getActiveTextEditor()
    console.log "Editor", editor
    return unless editor?

    cursor = editor.getLastCursor()
    console.log "Cursor", cursor
    line = cursor.getBufferRow() + 1
    console.log "Line", line

    @openUriFor(editor.getPath(), line)

  runLast: ->
    return unless @lastFile?
    @openUriFor(@lastFile, @lastLine)

  run: ->
    console.log "RUN"
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    @openUriFor(editor.getPath())

  runAll: ->
    project = atom.project
    return unless project?

    @openUriFor(project.getPaths()[0] +
    "/" + atom.config.get("inspec.spec_directory"), @lastLine)
