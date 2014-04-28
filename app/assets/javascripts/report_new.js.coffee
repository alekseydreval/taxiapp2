$ ->
  date_picker = $('#start_date, #end_date').pickadate 
    onStart: ->
        date = new Date()
        this.set('select', [date.getFullYear(), date.getMonth(), date.getDate()]);
