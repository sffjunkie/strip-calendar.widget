command: "echo 'Lauching StripCalendar...'"

settings = {
    locale: "en-GB" # The locale in which to display day and month names
    layout: "horizontal" # Orientation, either horizontal or vertical

    offdayIndices: [0, 6] # Sunday & Saturday
    # offdayIndices: [5, 6] # Friday & Saturday

    nineDayFortnightStartDay: null # Don't use a nine day fortnight
    #nineDayFortnightStartDay: new Date(2017,4,12) # First day off in a nine day fortnight

    font: {
      family: "-apple-system"
      size: "14px"
    }
    
    color: {
      bg: {
        calendar: "rgba(#000, 0.3)"
        midline: "rgba(#fff, 0.5)"
        midlineToday: "rgba(#0bf, 0.8)"
        midlineOffDay: "rgba(#f77, 0.8)"
        midlineOffToday: "rgba(#fc3, 0.8)"
      }
      fg: {
        offDay: "rgba(#f77, 1.0)"
      }
    }
}

refreshFrequency: 50000
displayedDate: null
localizedMonthNames: null
localizedDayNames: null

style: """
  #{if settings.layout == "horizontal" then "bottom" else "top"}: 10px
  #{if settings.layout == "horizontal" then "right" else "left"}: 10px

  .debug
    background: rgba(green, 1)

  .calendar
    padding: 4px
    font-family: #{settings.font.family}
    font-size: #{settings.font.size}
    font-weight: 500
    color: #fff
    border-radius: 10px
    background: #{settings.color.bg.calendar}

  table
    border-collapse: collapse
    table-layout: fixed

  caption
    padding: 0 10px 10px
    margin-right: 0
    margin-left: auto
    font-size: 20px
    font-weight: 500

  .horizontal caption
    text-align: right

  caption span
    display: inline-block

  caption .month
    text-transform: uppercase
    color: rgba(#fff, 0.7)

  caption .year
    color: rgba(#fff, 0.9)

  th, td
    text-align: center

  .calendar.horizontal th, .calendar.horizontal td
    min-width: 4em

  .calendar.vertical th, .calendar.vertical td
    min-width: 3em

  .calendar.horizontal th
    padding-top: 6px
    padding-bottom: 6px
    border-radius: 3px 3px 0 0
    border-bottom: 3px solid #{settings.color.bg.midline}

  .calendar.horizontal th.today
    border-bottom: 3px solid #{settings.color.bg.midlineToday}

  .calendar.horizontal th.offday
    border-bottom: 3px solid #{settings.color.bg.midlineOffDay}

  .calendar.horizontal th.offday.today
    border-bottom: 3px solid #{settings.color.bg.midlineOffToday}

  .calendar.vertical th
    padding-top: 8px
    padding-bottom: 8px
    border-radius: 3px 0 0 3px
    border-right: 3px solid #{settings.color.bg.midline}

  .calendar.vertical th.today
    border-right: 3px solid #{settings.color.bg.midlineToday}

  .calendar.vertical th.offday
    border-right: 3px solid #{settings.color.bg.midlineOffDay}

  .calendar.vertical th.offday.today
    border-right: 3px solid #{settings.color.bg.midlineOffToday}

  .calendar.horizontal td
    padding-top: 6px
    padding-bottom: 6px
    border-radius: 0 0 3px 3px

  .calendar.vertical td
    padding-left: 6px
    padding-right: 6px
    border-radius: 0 3px 3px 0

  .today
    background: rgba(#fff, 0.2)

  .offday
    color: #{settings.color.fg.offDay}
"""

converticalMilliSecondsToHours: (value) ->
  return Math.floor(value / ( 24 * 60 * 60 * 1000 ))

toMilliSeconds: (value) ->
  return value * ( 24 * 60 * 60 * 1000 )

toordinal: (date) ->
  zeroDate = new Date('0000-12-31')
  zeroDays = Math.abs(@converticalMilliSecondsToHours(zeroDate.getTime()))
  return zeroDays + @converticalMilliSecondsToHours(date.getTime())

getLocaleName: (d, locale, type, length) ->
  return d.toLocaleDateString(locale, { "#{type}": length })

getLocalizedDayNames: () ->
  dates = (new Date(2017, 0, day) for day in [1...8])
  return (@getLocaleName(d, settings.locale, "weekday", "short") for d in dates)

getLocalizedMonthNames: () ->
  dates = (new Date(2017, month, 1) for month in [0...12])
  return (@getLocaleName(d, settings.locale, "month", "long") for d in dates)

getClassName: (y, m, d, w, today) ->
  theDate = new Date(y, m, d)

  isToday = (d == today.getDate())

  if settings.nineDayFortnightStartDay isnt null
    dateDiff = @toordinal(theDate) - @toordinal(settings.nineDayFortnightStartDay)
    isFridayOff = ((dateDiff % 14) == 0)
  else
    isFridayOff = false

  isOffDay = (settings.offdayIndices.indexOf(w) isnt -1) or isFridayOff

  if isToday or isOffDay
    classNames = []
    if isToday
      classNames.push "today"
    if isOffDay
      classNames.push "offday"
  else
    classNames = ["ordinary"]

  return classNames.join(" ")

render: (output) -> """<div class="calendar #{settings.layout}">
    <table>
    <caption><span class='month'></span> <span class='year'></span></caption>
    <tbody>
    </tbody>
    </table>
    </div>
    """

afterRender: (domEl) ->
  @localizedDayNames = @getLocalizedDayNames()
  @localizedMonthNames = @getLocalizedMonthNames()

update: (output, domEl) ->
  date = new Date()
  y = date.getFullYear()
  m = date.getMonth()
  today = date.getDate()

  # DON'T MANUPULATE DOM IF NOT NEEDED
  newDate = [today, m, y].join("/")
  if(displayedDate != null && displayedDate == newDate)
    return
  else
    displayedDate = newDate

  firstOfMonth = new Date(y, m, 1)
  firstWeekDay = firstOfMonth.getDay()
  lastDay = new Date(y, m + 1, 0).getDate()

  weekdays = []
  midlines = []
  dates = []

  days = [1..lastDay]
  daysOfWeek = (((dayOfMonth + firstWeekDay - 1) % 7) for dayOfMonth in days)

  if settings.layout == "horizontal"
    for dayOfMonth in [1..lastDay]
      dayOfWeek = ((dayOfMonth + firstWeekDay - 1) % 7)
      className = @getClassName(y, m, dayOfMonth, dayOfWeek, date)
      weekdays.push "<th class=\"#{className}\">#{@localizedDayNames[dayOfWeek]}</th>"

      dayOfMonth = dayOfMonth.toLocaleString(settings.locale)
      dates.push "<td class=\"#{className}\">#{dayOfMonth}</td>"

    tbody_html = """
      <tr class="weekday">#{weekdays.join("")}</tr>
      <tr class="midline">#{midlines.join("")}</tr>
      <tr class="date">#{dates.join("")}</tr>
    """
  else
    tbody_html = ""
    c = days.map((e, i) -> [e, daysOfWeek[i]])
    for item in c
      dayOfMonth = item[0]
      dayOfWeek = item[1]
      className = @getClassName(y, m, dayOfMonth, dayOfWeek, date)
      tbody_html += """<tr>
        <th class=\"#{className}\">#{dayOfMonth}</th>
        <td class=\"#{className}\">#{@localizedDayNames[dayOfWeek]}</td>
      </tr>"""

  $(domEl).find("tbody").html(tbody_html)

  year = y.toLocaleString(settings.locale, { useGrouping: false })
  $(domEl).find("caption .month").html("#{@localizedMonthNames[m]}")
  $(domEl).find("caption .year").html("#{year}")
  return
