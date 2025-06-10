// Package imports:
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

// DataSource para Syncfusion SfCalendar
class SfAppointmentDataSource extends sfc.CalendarDataSource {
  SfAppointmentDataSource(List<sfc.Appointment> source) {
    appointments = source;
  }
}
