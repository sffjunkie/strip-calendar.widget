settings = {
    locale: "en-GB" # The locale in which to display day and month names
    layout: "horizontal" # Orientation, either horizontal or vertical

    offdayIndices: [0, 6] # Sunday & Saturday
    # offdayIndices: [5, 6] # Friday & Saturday

    nineDayFortnightStartDay: null # Don't use a nine day fortnight
    #nineDayFortnightStartDay: new Date(2017,4,12) # First day off in a nine day fortnight

    payDay: {
      period: 'w'
      value: 4
      base: new Date(2018, 9, 12)
    }

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
        payDay: "rgba(#ff0, 0.1)"
      }
      fg: {
        offDay: "rgba(#f77, 1.0)"
      }
    }
}

_cache = {
  displayedDate: null
  localizedMonthNames: null
  localizedDayNames: null
}

_convertMilliSecondsToHours = (value) ->
  return Math.floor(value / ( 24 * 60 * 60 * 1000 ))

_toMilliSeconds = (value) ->
  return value * ( 24 * 60 * 60 * 1000 )

_toordinal = (date) ->
  zeroDate = new Date('0000-12-31')
  _zeroDays = Math.abs(_convertMilliSecondsToHours(zeroDate.getTime()))
  _return zeroDays + _convertMilliSecondsToHours(date.getTime())

_getLocaleName = (d, locale, type, length) ->
  return d.toLocaleDateString(locale, { "#{type}": length })

_getLocalizedDayNames = () ->
  dates = (new Date(2017, 0, day) for day in [1...8])
  return (_getLocaleName(d, settings.locale, "weekday", "short") for d in dates)

_getLocalizedMonthNames = () ->
  dates = (new Date(2017, month, 1) for month in [0...12])
  return (_getLocaleName(d, settings.locale, "month", "long") for d in dates)

_dayOfWeekIndex = (dayName) ->
  dayName = dayName.slice(0, 3).toLowerCase()
  ["sun", "mon", "tue", "wed", "thu", "fri", "sat"].indexOf(dayName)

_isPayDay = (options) ->
  if settings.payDay is null
    return false

  options = if typeof options is 'undefined' then {} else options
  date = if 'date' in options then options['date'] else new Date()
  period = if 'period' in options then options.period else period
  value = if 'value' in options then options.value else value
  base = if 'base' in options then options.base else base

  endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0)
  payday = switch
    when period is 'w'
      abs(_toordinal(base) - _toordinal(date)) % (7 * value) is 0

    when period is 'd'
      if(typeof value is "number")
        if(value > 0)
          pd == value
        else
          daysInMonth = endOfMonth.getDate()
          pd = daysInMonth + value
      else if(typeof value is "string")
        if(value[0] == "-")
          day = value.splice(1)
          dayIndex = _dayOfWeekIndex(day)
          lastDayIndex = endOfMonth.getDay()
          if(lastDayIndex > dayIndex)
            offset = dayIndex - lastDayIndex
          else
            offset = lastDayIndex - dayIndex - 1
          pd = endOfMonth.getDate() + offset
        else
          dayIndex = _dayOfWeekIndex(value)
          lastDayIndex = endOfMonth.getDay()
          offset = (7 - (lastDayIndex - dayIndex)) %% 7
          pd = 1 + offset

      date.getDate() == pd

_getClassName = (y, m, d, w, today) ->
  theDate = new Date(y, m, d)

  isToday = (d == today.getDate())

  if settings.nineDayFortnightStartDay isnt null
    _dateDiff = _toordinal(theDate) - _toordinal(settings.nineDayFortnightStartDay)
    isFridayOff = ((dateDiff % 14) == 0)
  else
    isFridayOff = false

  isOffDay = (settings.offdayIndices.indexOf(w) isnt -1) or isFridayOff
  isPayDay = _isPayDay()

  if isToday or isOffDay or isPayDay
    classNames = []
    if isToday
      classNames.push "today"
    if isOffDay
      classNames.push "offday"
    if isPayDay
      classNames.push "payday"
  else
    classNames = ["ordinary"]

  return classNames.join(" ")

{
  command: "echo 'Lauching StripCalendar...'"

  refreshFrequency: 50000

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

      .payday
        background-color: #{settings.color.bg.payDay}

    .calendar.horizontal
      th
      td
        min-width: 4em

    .calendar.vertical
      th
      td
        min-width: 3em

    .calendar.horizontal
      th
        padding-top: 6px
        padding-bottom: 6px
        border-radius: 3px 3px 0 0
        border-bottom: 3px solid #{settings.color.bg.midline}

      th.today
        border-bottom: 3px solid #{settings.color.bg.midlineToday}

      th.offday
        border-bottom: 3px solid #{settings.color.bg.midlineOffDay}

      th.offday.today
        border-bottom: 3px solid #{settings.color.bg.midlineOffToday}

      td
        padding-top: 6px
        padding-bottom: 6px
        border-radius: 0 0 3px 3px

    .calendar.vertical
      th
        padding-top: 8px
        padding-bottom: 8px
        border-radius: 3px 0 0 3px
        border-right: 3px solid #{settings.color.bg.midline}

      th.today
        border-right: 3px solid #{settings.color.bg.midlineToday}

      th.offday
        border-right: 3px solid #{settings.color.bg.midlineOffDay}

      th.offday.today
        border-right: 3px solid #{settings.color.bg.midlineOffToday}

      td
        padding-left: 6px
        padding-right: 6px
        border-radius: 0 3px 3px 0

    .today
      background: rgba(255, 255, 255, 0.2)

    .offday
      color: #{settings.color.fg.offDay}
  """

  render: (output) -> """<div class="calendar #{settings.layout}">
      <table>
      <caption><span class='month'></span> <span class='year'></span></caption>
      <tbody>
      </tbody>
      </table>
      </div>
      """

  afterRender: (domEl) ->
    _cache.localizedDayNames = _getLocalizedDayNames()
    _cache.localizedMonthNames = _getLocalizedMonthNames()

  update: (output, domEl) ->
    date = new Date()
    y = date.getFullYear()
    m = date.getMonth()
    today = date.getDate()

    # DON'T MANUPULATE DOM IF NOT NEEDED
    newDate = [today, m, y].join("/")
    if(_cache.displayedDate != null && _cache.displayedDate == newDate)
      return
    else
      _cache.displayedDate = newDate

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
        dayOfWeek = daysOfWeek[dayOfMonth - 1]
        className = _getClassName(y, m, dayOfMonth, dayOfWeek, date)
        weekdays.push "<th class=\"#{className}\">#{_cache.localizedDayNames[dayOfWeek]}</th>"

        dayOfMonth = dayOfMonth.toLocaleString(settings.locale)
        dates.push "<td class=\"#{className}\">#{dayOfMonth}</td>"

      tbody_html = """
        <tr class="weekday">#{weekdays.join("")}</tr>
        <tr class="midline">#{midlines.join("")}</tr>
        <tr class="date">#{dates.join("")}</tr>
      """
    else
      tbody_html = ""
      daysTransposed = days.map((e, i) -> [e, daysOfWeek[i]])
      for item in daysTransposed
        dayOfMonth = item[0].toLocaleString(settings.locale)
        dayOfWeek = item[1]
        className = _getClassName(y, m, dayOfMonth, dayOfWeek, date)
        tbody_html += """<tr>
          <th class=\"#{className}\">#{dayOfMonth}</th>
          <td class=\"#{className}\">#{_cache.localizedDayNames[dayOfWeek]}</td>
        </tr>"""

    $(domEl).find("tbody").html(tbody_html)

    year = y.toLocaleString(settings.locale, { useGrouping: false })
    $(domEl).find("caption .month").html("#{_cache.localizedMonthNames[m]}")
    $(domEl).find("caption .year").html("#{year}")
}
