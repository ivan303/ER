$(document).ready(function() {

	var calendar = $('#calendar')
    calendar.fullCalendar({
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
    })
	calendar.fullCalendar('changeView', 'agendaWeek');

});

var matchingDaysBetween = function (start, end, test) {
    var days = [];
    for (var day = moment(start)/*start*/; day.isBefore(end); day.add(1, 'd')) {
        if (test(day)) {
            days.push(moment(day)/*day*/); // push a copy of day
        }
    }
    return days;
}