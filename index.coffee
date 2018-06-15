settings =
    # The locale in which to display day and month names
    locale: "en-GB"

    layout: "horiz"

    # Sunday & Saturday
    offdayIndices: [0, 6]

    # First day off in a nine day fortnight
    nineDayFortnightStartDay: new Date(2017,4,12)

    fontFamily: "-apple-system"
    fontSize: "14px"
    color:
        background:
          midline: "rgba(#fff, 0.5)"
          midlineToday: "rgba(#0bf, 0.8)"
          midlineOffDay: "rgba(#f77, 0.5)"
          midlineOffToday: "rgba(#fc3, 0.8)"
        offDay: "rgba(#f77, 1.0)"

command: "echo 'Lauching LineCalendar...'"
refreshFrequency: 50000
displayedDate: null

style: """
  bottom: 10px
  right: 10px
  #{if settings.layout == "horiz" then "left: 21.9%"}

  .calendar
    padding: 4px
    font-family: #{settings.fontFamily}
    font-size: #{settings.fontSize}
    font-weight: 500
    color: #fff
    border-radius: 10px
    background: rgba(green, 0)

  .calendar.horiz
    width: 100%

  .calendar.vert
    width: 10%

  caption
    padding: 0 10px 10px
    text-align: right
    margin-right: 0
    margin-left: auto
    font-size: 20px
    font-weight: 500

  caption span
    display: inline-block

  caption .month
    /* text-transform: uppercase */
    font-variant: small-caps
    color: rgba(#fff, 0.7)

  caption .year
    color: rgba(#fff, 0.9)

  table
    border-collapse: collapse
    table-layout: fixed
    width: 100%

  td
    text-align: center

  .calendar.horiz .weekday td
    padding-top: 6px
    padding-bottom: 6px
    border-radius: 3px 3px 0 0

  .calendar.vert .weekday td
    padding-left: 6px
    padding-right: 6px
    border-radius: 3px 0 0 3px

  .calendar.horiz .date td
    padding-top: 6px
    padding-bottom: 6px
    border-radius: 0 0 3px 3px

  .calendar.vert td
    padding-left: 6px
    padding-right: 6px
    border-radius: 0 3px 3px 0

  .calendar.horiz .midline
    height: 3px

  .calendar.vert .midline
    width: 3px

  .today
    background: rgba(#fff, 0.2)

  .midline
    background: #{settings.color.background.midline}

  .midline .today
    background: #{settings.color.background.midlineToday}

  .midline .offday
    background: #{settings.color.background.midlineOffDay}

  .midline .offday.today
    background: #{settings.color.background.midlineOffToday}

  .offday
    color: #{settings.color.offDay}
"""

convertMilliSecondsToHours: (value) ->
  return Math.floor(value / ( 24 * 60 * 60 * 1000 ))

toMilliSeconds: (value) ->
  return value * ( 24 * 60 * 60 * 1000 )

toordinal: (date) ->
  zeroDate = new Date('0000-12-31')
  zeroDays = Math.abs(@convertMilliSecondsToHours(zeroDate.getTime()))
  return zeroDays + @convertMilliSecondsToHours(date.getTime())

getLocaleName: (d, locale, type, length) ->
  return d.toLocaleDateString(locale, {"#{type}": length})

getDayNames: () ->
  dates = (new Date(2017, 0, day) for day in [1...8])
  return (@getLocaleName(d, settings.locale, "weekday", "short") for d in dates)

getMonthNames: () ->
  dates = (new Date(2017, month, 1) for month in [0...12])
  return (@getLocaleName(d, settings.locale, "month", "long") for d in dates)

render: (output) -> """<div class="calendar #{settings.layout}">
    <table>
    <caption><span class='month'></span> <span class='year'></span></caption>
    <tbody>
    <tr class="weekday"></tr>
    <tr class="midline"></tr>
    <tr class="date"></tr>
    </tbody>
    </table>
    </div>
    """

getClassName: (y, m, d, w, today) ->
  theDate = new Date(y, m, d)

  isToday = (d == today.getDate())

  if settings.nineDayFortnightStartDay isnt null
    isFridayOff = (((@toordinal(theDate) - @toordinal(settings.nineDayFortnightStartDay)) % 14) == 0)
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

  dayNames = @getDayNames()
  monthNames = @getMonthNames()

  weekdays = []
  midlines = []
  dates = []

  for dayOfMonth in [1..lastDay]
    dayOfWeek = ((dayOfMonth + firstWeekDay - 1) % 7)
    className = @getClassName(y, m, dayOfMonth, dayOfWeek, date)
    weekdays.push "<td class=\"#{className}\">#{dayNames[dayOfWeek]}</td>"

    midlines.push "<td class=\"#{className}\"></td>"

    dayOfMonth = dayOfMonth.toLocaleString(settings.locale)
    dates.push "<td class=\"#{className}\">#{dayOfMonth}</td>"

  year = y.toLocaleString(settings.locale, {useGrouping: false})
  $(domEl).find("caption .month").html("#{monthNames[m]}")
  $(domEl).find("caption .year").html("#{year}")
  $(domEl).find(".weekday").html(weekdays.join(""))
  $(domEl).find(".midline").html(midlines.join(""))
  $(domEl).find(".date").html(dates.join(""))
  return
