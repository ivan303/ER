$(document).ready(function() {
	var employmentClinicSelect = $('#employment_clinic_id');
	var employmentDoctorSelect = $('#employment_doctor_id');
	// if (gon != undefined) {
	var allDoctors = gon.doctors;
	// }

	var updateEmploymentDoctorOptions = function () {
		var clinicID = $('#employment_clinic_id option:selected').val();
		var doctorsIDs = [];
		var toDelete;
		var doctorOptions = [];
		gon.employments.forEach(function (employment, index) {
			if (employment.clinic_id == clinicID) {
				allDoctors.forEach(function (doctor, ind) {
					if (doctor.id == employment.doctor_id) {
						doctorsIDs.push(ind);
					}
				})
			}
		});
		allDoctors.forEach(function (doctor, ind) {
			if (doctorsIDs.indexOf(ind) == -1) {
				doctorOptions.push($('<option></option>').attr('value', doctor.id).text(doctor.firstname + " " + doctor.lastname));
			}
		});
		employmentDoctorSelect.empty();
		doctorOptions.forEach(function (doc, ind) {
			employmentDoctorSelect.append(doc);
		});
	};

	employmentClinicSelect.change(function () {
		updateEmploymentDoctorOptions();
	});
});