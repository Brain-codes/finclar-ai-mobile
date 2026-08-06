const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _monthShortNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String budgetMonthLabel(int month) => _monthNames[month - 1];

String budgetMonthShort(int month) => _monthShortNames[month - 1];

String budgetDateLabel(DateTime? d) {
  if (d == null) return '—';
  return '${budgetMonthShort(d.month)} ${d.day}, ${d.year}';
}
