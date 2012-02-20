#= require tl/mixins/views/tl_widget

# Adapted from http://sc20-jqui.strobeapp.com/js/app.js by Yehuda Katz

# Create a new Ember view for the jQuery UI Progress Bar widget
TL.ProgressBar = Ember.View.extend TL.JQWidget,
  uiType: 'progressbar'
  uiOptions: ['value', 'max']
  uiEvents: ['change', 'complete']

