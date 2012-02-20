#= require tl/mixins/views/tl_widget

# Adapted from http://sc20-jqui.strobeapp.com/js/app.js by Yehuda Katz

# Create a new SproutCore view for the jQuery UI Menu widget (new
# in jQuery UI 1.9). Because it wraps a collection, we extend from
# SproutCore's CollectionView rather than a normal view.
#
# This means that you should use `#collection` in your template to
# create this view.
TL.Menu = Ember.CollectionView.extend TL.JQWidget,
  uiType: 'menu'
  uiOptions: ['disabled']
  uiEvents: ['select']

  tagName: 'ul'

  # Whenever the underlying Array for this `CollectionView` changes,
  # refresh the jQuery UI widget.
  arrayDidChange: (content, start, removed, added) ->
    @_super(content, start, removed, added)

    ui = @get('ui')
    ui.refresh() if ui
