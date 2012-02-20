TL.Grid = Em.View.extend

  # NOTE: SlickGrid expects its rows to be defined as an array of
  # basic JavaScript objects. For performance reasons, we keep
  # it like that until a row is selected, at which point its
  # defining object ("hash") will be used by a controller to instantiate
  # a model object. For this reason, the GridView expects a +dataBinding+
  # and a +selectedRowNumbersBinding+ to be defined by a subclass or instance.

  didInsertElement: ->
    return if @grid

    unless @gridColumns
      Em.Logger.error "#{@}: Missing grid columns definition!"
      return
    @gridOptions ||= {}

    @$node = @$()
    @_createGrid()
    @_createButtons()
    @_tl_grid_setupEventHandlers()
    @_dataDidChange()


  selectLastRow: ->
    rowNo = @grid.getDataLength() - 1
    @grid.setSelectedRows([rowNo])
    @grid.scrollRowIntoView(rowNo)


  updateSelectedRow: (json) ->
    Em.propertyWillChange(@, 'data')

    rowNo = @grid.getSelectedRows()[0]
    row = @grid.getDataItem(rowNo)
    row.id = json.id

    for column in @gridColumns
      field = column.field
      row[field] = json[field]

    Em.propertyDidChange(@, 'data')


  removeSelectedRow: ->
    Em.propertyWillChange(@, 'data')

    rowNo = @grid.getSelectedRows()[0]
    dataLength = @grid.getDataLength()

    data = @grid.getData()
    row = @grid.getDataItem(rowNo)
    data.deleteItem(row.id)

    if(rowNo is dataLength - 1)
      @set('selectedRowNumbers', [rowNo - 1])
    else
      @set('selectedRowNumbers', [rowNo])

    Em.propertyDidChange(@, 'data')


  ##################
  # private methods
  ##################

  _createGrid: ->
    dataView = new Slick.Data.DataView
    @grid = new Slick.Grid($('.grid', @$node), dataView, @gridColumns, @gridOptions)
    @grid.setSelectionModel(new Slick.RowSelectionModel)


  _createButtons: () ->
    @$node.find('.edit-button').button
      text: false
      icons:
        primary: 'ui-icon-pencil'

    @$node.find('.add-button').button
      text: false
      icons:
        primary: 'ui-icon-plus'

    @$node.find('.delete-button').button
      text: false
      icons:
        primary: 'ui-icon-minus'


  _tl_grid_setupEventHandlers: ->
    @grid.onSelectedRowsChanged.subscribe (event, info) =>
      gridRows = info.rows.sort(TL.numericalSort)
      boundRows = @get('selectedRowNumbers')

      # Only set selectedRowNumbers if it differs from its current value
      # to avoid an infinite loop
      if gridRows.length isnt boundRows.length or gridRows.some((item, index) -> item isnt boundRows[index])
        @set('selectedRowNumbers', gridRows)


  _selectedRowNumbersDidChange: (->
    if @grid
      numbers = @get('selectedRowNumbers')
      @grid.setSelectedRows(numbers)
  ).observes('selectedRowNumbers')


  _dataDidChange: (->
    data = @get('data')
    return unless data and @grid

    @grid.invalidateAllRows()
    @grid.getData().setItems(data)
    @grid.resizeCanvas()

    unless @_dataChangedAlready
      @grid.setSelectedRows([0])
      @_dataChangedAlready = true
  ).observes('data.@each')


  # _initData: ->
  #   @controller.observe('records', @_onControllerRecordsChanged.bind(@))
  #   @$node.spin()
  #   @controller.index()   # loads data from the server
