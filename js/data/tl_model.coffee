TL.Model = DS.Model.extend

  # Override the init method to use our own state manger
  # for models
  init: ->
    stateManager = TL.DataStateManager.create
      model: @

    @set('stateManager', stateManager)
    stateManager.goToState('empty')

  # TODO: This probably doesn't work with non-embedded relations.
  # Creates a JSON representation of the model that includes related models
  # in a format that works with Rails' accepts_nested_attributes_for
  toJSON: ->
    JSON.stringify(@buildDataRecursively())

  buildDataRecursively: ->
    data = Em.copy(@get('data'), true)

    for own name, value of data
      if value instanceof Array  # assume that all arrays are relations
        children = @get(name)
        data["#{name}_attributes"] = children.map (child) -> child.buildDataRecursively()
        delete data[name]

    return data

  # Should this model be saved if it's dirty? If it belongs to another model
  # (identified by an xxx_id property), that model (or rather, the model at
  # the root of the hierarchy) will have been marked as dirty when this one
  # became dirty, and the one at the root of the hierarchy is the one that
  # should be saved, not this one. This is the easiest way to set the xxx_id
  # if the parent model has not yet been persisted, and then we might as well
  # do it that way anyhow. Of course, if this model does not belong to any
  # other model, it should be saved if it's dirty.
  shouldSave: ->
    return false unless @get('isDirty')

    for own attr of @get('data')
      matches = attr.match(/^(.+)_id/)
      if matches
        # If the parent has been persisted, we can find it via the xxx_id
        # property. Otherwise, xxx_id will be undefined, but then we should
        # have made sure to set xxxClientId instead when we created this
        # model, so we can use that (of course, that property will not have
        # been set if we have loaded the model from the server, which is why
        # we try xxx_id first).

        assoc = matches[1]
        parent = @get(assoc)
        unless parent
          store = @get('store')
          type = @constructor.typeForAssociation(assoc)
          parent = store.findByClientId(type, @get("#{assoc}ClientId"))

        if parent and parent.get('isDirty')
          # pretend that we were already updated
          @get('stateManager').send('didUpdate')
          return false

    return true

  makeParentDirty: ->
    data = @get('data')
    for own prop of data
      matches = prop.match(/(.+)_id/)

      if matches
        parent = @get(matches[1])

        if parent
          # This model belongs to another model. We need to mark the other
          # model as updated, and that again will mark any model IT belongs to
          # as updated, and so on, so that what is sent to the server in the
          # end is always the model at the root of the hierarchy (the models
          # have a shouldSave method that is called by the adapter and that
          # makes sure that only the root model is saved).

          # This is necesary in order to make sure that all models have the
          # same data representations - if we were to save a model that is not
          # at the root, the models closer to the root will end up with a
          # stale representation of models further down the "belongs to"
          # hierarchy.
          parent.markAsUpdated()


  markAsUpdated: ->
    @get('stateManager').send('markAsUpdated')

  cancelEdit: -> @get('stateManager').send('cancelEdit')


TL.reopen
  # These just make it possible to use TL instead of DS everywhere - easier
  # to remember
  attr: DS.attr
  hasMany: DS.hasMany
  hasOne: DS.hasOne
