#= require tl/mixins/views/tl_widget

# Adapted from http://sc20-jqui.strobeapp.com/js/app.js by Yehuda Katz

# Create a new SproutCore view for the jQuery UI Button widget
TL.Button = Ember.View.extend TL.JQWidget,
  uiType: 'button'
  uiOptions: ['label', 'disabled']

  tagName: 'button'
