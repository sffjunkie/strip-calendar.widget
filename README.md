## Strip Calendar ##

An Übersicht widget that displays a calendar in a strip that...

* can be displayed in a horizontal or vertical orientation
* can present the information in any locale available in Javascript e.g. en-GB, ar-AS etc.
* provides support for a nine day fortnight

### Nine Day Fortnight ###

If you work a nine day fortnight as I do, where I get every other Friday off, then set `nineDayFortnightStartDay` to the date of a day in the calendar that is a day off e.g. `new Date(2017, 4, 12)`, then any dates a multiple of 14 days after that date will be shown as an off day.

### Horizontal Calendar ###

![Horizontal Calendar](calendar-horizontal.jpg)

### Vertical Calendar ###

![Vertical Calendar](calendar-vertical.jpg)
