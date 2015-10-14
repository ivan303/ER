$(document).ready(function () {
	var doctorSelect = $('#appointment_doctor_id');
	var clinicSelect = $('#appointment_clinic_id');
	var calendarAppointments = $('#calendar-appointments');

	var firstAppointmentInClinicButton = $('#first-visit-in-clinic');
	var firstAppointmentAtDoctorButton = $('#first-visit-at-doctor');

	doctorSelect.change(function () {
		updateCalendar();
	});

	clinicSelect.change(function () {
		updateDoctorSelectOptions();
		updateCalendar();
	});

	firstAppointmentInClinicButton.click(function () {
		var selectedClinic = $('#appointment_clinic_id option:selected').val();
		if (selectedClinic) {
			var createAppointmentInClinicUrl = '/appointments/create_appointment_in_clinic';

			$.ajax({
				url: createAppointmentInClinicUrl,
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
				dataType: 'JSON',
				method: 'POST',
				data: $.param({ appointment: { clinic_id: selectedClinic, patient_id: gon.current_user_id }}),
				success: function(data, textStatus, jqXHR) {
					var htmlToInsert = "<div class='alert alert-success'>";
					htmlToInsert += data.flash;
					htmlToInsert += "<div class='br'></div>";
					htmlToInsert += "</div>"
					$( ".flash-message" ).empty().append(htmlToInsert);
					updateCalendar();
				}
			})
		}
	});

	firstAppointmentAtDoctorButton.click(function () {
		var selectedDoctor = $('#appointment_doctor_id option:selected').val();
		if (selectedDoctor) {
			var createAppointmentAtDoctorUrl = '/appointments/create_appointment_at_doctor';

			$.ajax({
				url: createAppointmentAtDoctorUrl,
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
				dataType: 'JSON',
				method: 'POST',
				data: $.param({ appointment: { doctor_id: selectedDoctor, patient_id: gon.current_user_id }}),
				success: function(data, textStatus, jqXHR) {
					var htmlToInsert = "<div class='alert alert-success'>";
					htmlToInsert += data.flash;
					htmlToInsert += "<div class='br'></div>";
					htmlToInsert += "</div>"
					$( ".flash-message" ).empty().append(htmlToInsert);
					updateCalendar();
				}
			});
		}
	});

	var updateCalendar = function () {
		var selectedClinic = $('#appointment_clinic_id option:selected').val();
		var selectedDoctor = $('#appointment_doctor_id option:selected').val();

		if (selectedClinic && selectedDoctor) {
			var updateCalendarUrl = '/appointments/update_calendar';
			$.ajax({
	            url: updateCalendarUrl,
	            dataType: 'JSON',
	            method: 'GET',
	            data: $.param({ doctor_id: selectedDoctor, clinic_id: selectedClinic }),
	            success: function(data, textStatus, jqXHR) {

					calendarAppointments.fullCalendar('removeEvents');
		            calendarAppointments.fullCalendar('addEventSource', function (start, end, timezone, callback) { 

						var events = []
						var schedules = data[0];
						var appointments = data[1];

						schedules.forEach(function (element, index) {

							var scheduleID = element.id;
							var eventID = 'eventID_' + scheduleID;

							var days = matchingDaysBetween(start, end, function (day) {
				            	return day.format('ddd') === element.weekday; //test function
				        	});

							days.forEach(function(el, ind) {
								var beginTime = moment(el).hour(moment(element.begins_at).format('H'))
														.minute(moment(element.begins_at).format('m'))
														.second(moment(element.begins_at).format('s'));
								var endTime = moment(el).hour(moment(element.ends_at).format('H'))
													.minute(moment(element.ends_at).format('m'))
													.second(moment(element.ends_at).format('s'));
								events.push({
									id 		: eventID,
									start 	: beginTime.format('YYYY-MM-DDTHH:mm:ssZ'),
									end 	: endTime.format('YYYY-MM-DDTHH:mm:ssZ'),
									schedule_id: element.id
								})
							})
						});
						appointments.forEach(function (element, index) {
							var appointmentID = element.id;
							var eventID = 'eventID_' + appointmentID;

							events.push({
								id  		: eventID,
								start 		: moment(element.begins_at).format('YYYY-MM-DDTHH:mm:ss'),
								end 		: moment(element.ends_at).format('YYYY-MM-DDTHH:mm:ss'),
								color 		: 'red'
							})
						})
						callback(events)	
					});         
	    	        calendarAppointments.fullCalendar('rerenderEvents' );
	            }
	        });
		} else {
			calendarAppointments.fullCalendar('removeEvents');
		    calendarAppointments.fullCalendar('addEventSource', function (start, end, timezone, callback) { 
		    	var events = [];
		    	callback(events);
		    });
		    calendarAppointments.fullCalendar('rerenderEvents');
		}
	};

	var updateDoctorSelectOptions = function () {
		var clinicID = $('#appointment_clinic_id option:selected').val();
		var doctors = [];
		if (gon.employments) {
			gon.employments.forEach(function (employment, index) {
				if (employment.clinic_id == clinicID) {
					if (gon.doctors) {
						gon.doctors.forEach(function (doctor, index) {
							if (employment.doctor_id == doctor.id) {
								doctors.push($('<option></option>').attr("value", doctor.id).text(doctor.firstname + " " + doctor.lastname));
								// break;
							}
						})
					}
				}
			});
		}
		doctorSelect.empty();
		doctors.forEach(function (doc, ind) {
			doctorSelect.append(doc);
		});
	};

	calendarAppointments.fullCalendar({
		height: 760,
    	minTime: "07:00:00",
    	maxTime: "22:00:00",
    	// timezone: "UTC",
    	timezone: "Europe/Warsaw",
    	firstDay: 1,
    	header: {
    		left:   '',
		    center: '',
		    right:  'prev,next'
		},
    	allDaySlot: false,

	    eventSources: [{
	        events: function (start, end, timezone, callback) { 

				if (gon.schedules && gon.schedules.length == 0) {
					var events = []
					gon.schedules.forEach(function (element, index) {

						var scheduleID = element.id;
						var eventID = 'eventID_' + scheduleID;

						var days = matchingDaysBetween(start, end, function (day) {
			            	return day.format('ddd') === element.weekday; //test function
			        	});


						days.forEach(function(el, ind) {
							var beginTime = moment(el).hour(moment(element.begins_at).format('H'))
													.minute(moment(element.begins_at).format('m'))
													.second(moment(element.begins_at).format('s'));
							var endTime = moment(el).hour(moment(element.ends_at).format('H'))
												.minute(moment(element.ends_at).format('m'))
												.second(moment(element.ends_at).format('s'));
							events.push({
								id 		: eventID,
								start 	: beginTime.format('YYYY-MM-DDTHH:mm:ss'),
								end 	: endTime.format('YYYY-MM-DDTHH:mm:ss'),
								schedule_id: element.id
							});
						});
					});

					if (gon.appointments) {
						gon.appointments.forEach(function (element, index) {
							var appointmentID = element.id;
							var eventID = 'eventID_' + appointmentID;

							events.push({
								id 			: eventID,
								start		: moment(element.begins_at).format('YYYY-MM-DDTHH:mm:ss'),
								end 		: moment(element.ends_at).format('YYYY-MM-DDTHH:mm:ss'),
								color 		: 'red'
							});
						});
					}
					gon.schedules = []
					callback(events);
				} else {
					updateCalendar();
				}

			}
		}],

		eventClick: function(calEvent, jsEvent, view) {

	    }
	});
	calendarAppointments.fullCalendar('changeView', 'agendaWeek');

});