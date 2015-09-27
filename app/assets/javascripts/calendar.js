$(document).ready(function() {

	var calendarSchedules = $('#calendar-schedules');
	var calendarAppointments = $('#calendar-appointments');
	var doctorSelect = $('#doctors_name');
	var clinicSelect = $('#clinics_name');

	var updateCalendar = function () {
		var selectedClinic = $('#clinics_name option:selected').val();
		var selectedDoctor = $('#doctors_name option:selected').val();

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
					data.forEach(function (element, index) {

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
							})
						})
					})
					callback(events)	
				});         
    	        calendarAppointments.fullCalendar('rerenderEvents' );
            }
        });
	};

	var updateDoctorSelectOptions = function () {
		var clinicID = $('#clinics_name option:selected').val();
		var doctors = [];
		gon.employments.forEach(function (employment, index) {
			if (employment.clinic_id == clinicID) {
				gon.doctors.forEach(function (doctor, index) {
					if (employment.doctor_id == doctor.id) {
						doctors.push($('<option></option>').attr("value", doctor.id).text(doctor.firstname + " " + doctor.lastname));
						// break;
					}
				})
			}
		});
		doctorSelect.empty();
		doctors.forEach(function (doc, ind) {
			doctorSelect.append(doc);
		});
	}


	doctorSelect.change(function () {
		updateCalendar();
	})

	clinicSelect.change(function () {
		updateDoctorSelectOptions();
		updateCalendar();
	});


    calendarSchedules.fullCalendar({
    	height: 760,
    	minTime: "07:00:00",
    	maxTime: "22:00:00",
    	timezone: "UTC",
    	firstDay: 1,
    	header: false,
    	allDaySlot: false,
    	// aspectRatio		check!!!

	    eventSources: [{
	        events: function (start, end, timezone, callback) { 

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
						})
					})
				})
				callback(events)	
	        },
	    }],

	    eventClick: function(calEvent, jsEvent, view) {

	    	var eventID = calEvent._id;

	    	if (confirm('Are you sure you want to delete this schedule?') === true) {
		    	var destroyUrl = '/schedules/' + calEvent.schedule_id;
				$.ajax({
		            url: destroyUrl,
		            dataType: 'JSON',
		            method: 'DELETE',
		            success: function(data, textStatus, jqXHR) {
		            	calendar.fullCalendar('removeEvents',  eventID);
		            	for (var i=0; i<gon.schedules.length; i++) {
		            		if (gon.schedules[i].id == calEvent.schedule_id) {
		            			gon.schedules.splice(i, 1);
		            			break;
		            		}
		            	}
		            }
		        });	  

	    	}

    	}
    });
	calendarSchedules.fullCalendar('changeView', 'agendaWeek');


	var appointmentsEventSource = function (start, end, timezone, callback) { 

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
				})
			})
		})
		callback(events)	
	}

	calendarAppointments.fullCalendar({
		height: 760,
    	minTime: "07:00:00",
    	maxTime: "22:00:00",
    	timezone: "UTC",
    	firstDay: 1,
    	header: false,
    	allDaySlot: false,

	    eventSources: [{
	        events: appointmentsEventSource
		}],

		eventClick: function(calEvent, jsEvent, view) {

	    	var eventID = calEvent._id;
	    	console.log(eventID);
	    	$('.fc-time-grid-event').css('background-color', 'yellow');
	    	calEvent.backgroundColor = 'red';
    		// calendarAppointments.fullCalendar( 'rerenderEvents' );
	});
	calendarAppointments.fullCalendar('changeView', 'agendaWeek');

});

var matchingDaysBetween = function (start, end, test) {
    var days = [];
    for (var day = moment(start)/*start*/; day.isBefore(end); day.add(1, 'd')) {
        if (test(day)) {
            days.push(moment(day)/*day*/); // push a copy of day
        }
    }
    return days;
};

