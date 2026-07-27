export default function IsValidDate(day: string, month: string, year: string, maxAge: number = 100): { valid: boolean; message: string } {
	// So the date doesnt get the invalid date error when all fields are empty - initial state
	if (!day && !month && !year) return { valid: true, message: '' };

	const dayNum = parseInt(day);
	const monthNum = parseInt(month);
	const yearNum = parseInt(year);

	// Check basic ranges
	if (monthNum < 1 || monthNum > 12) {
		return { valid: false, message: 'Month must be between 1 and 12' };
	}

	if (dayNum < 1 || dayNum > 31) {
		return { valid: false, message: 'Day must be between 1 and 31' };
	}

	// Validate year range (current year - maxAge to current year - 18)
	const currentYear = new Date().getFullYear();
	const minYear = currentYear - maxAge; // Config.MaxAge
	const maxYear = currentYear - 18;  // Minimum age requirement
	
	if (yearNum < minYear || yearNum > maxYear) {
		return { valid: false, message: `Year must be between ${minYear} and ${maxYear}` };
	}

	// Check if the date actually exists -> No Feb 30th.
	const testDate = new Date(yearNum, monthNum - 1, dayNum);
	if (testDate.getMonth() !== monthNum - 1 || testDate.getDate() !== dayNum) {
		return { valid: false, message: 'Invalid date' };
	}

	return { valid: true, message: '' };
};