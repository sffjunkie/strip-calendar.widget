## Strip Calendar ##

An [Übersicht widget](http://tracesof.net/uebersicht-widgets/) that displays a calendar in a strip
that...

* can be displayed in a horizontal or vertical orientation
* can present the information in any locale available in Javascript e.g. en-GB, ar-AS etc.
* provides support for a nine day fortnight

This widget is based on the [widget](https://github.com/ashikahmad/horizontal-calendar-widget) from
ashikahmad but converted to Coffeescript and with the extra functionality listed above.

### Nine Day Fortnight ###

If you work a nine day fortnight as I do, where I get every other Friday off, then set
`nineDayFortnightStartDay` to the date of a day in the calendar that is a day off
e.g. `new Date(2017, 4, 12)`, then any dates a multiple of 14 days after that date will be shown
as an off day.

### Pay Day ###

You can specify which day is your pay day by changing the `payDay` object setting.

If you get paid every *n* weeks then change the `payDay` setting to an object with 3 items

1. period: 'w' - for weekly pay days
2. value: *n* - for the number of weeks
3. base: *firstDay* -  The date of your first pay day.

If you get paid on a fixed day every month then change the `payDay` setting to an object with 2
items

1. period: 'd' - for days
2. value: *n* - Positive integers are the actual day number, negative integers are a number of days
   from the end of the month

If you get paid on a fixed day at the start or end of the month then set the `payDay` setting to
an object with 2 items

1. period: 'd' - for days
2. value: "sun"|"mon"|"tue"|"wed"|"thu"|"fri"|"sat" - One of these day names. Names preceeded by
   a '-' are the last day in the month otherwise it is the first day in the month

e.g. if you get paid on the last Friday in the month use "['d', '-fri]"

### Horizontal Calendar ###

![Horizontal Calendar](screenshot.png)

### Vertical Calendar ###

![Vertical Calendar](calendar-vertical.png)

### License ###

[CC0 1.0 Universal](./LICENSE)