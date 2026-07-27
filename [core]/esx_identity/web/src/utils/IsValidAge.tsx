import IsValidDate from "./IsValidDate";

export default function IsValidAge(day: string, month: string, year: string, maxAge: number = 100): { valid: boolean; message: string } {
	const dateCheck = IsValidDate(day, month, year);

	if (!dateCheck.valid || !day || !month || !year || year.length < 4) {
		return { valid: true, message: '' }; // Date error takes priority
	}

	const birthDate = new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
	const today = new Date();
	const age = today.getFullYear() - birthDate.getFullYear();
	const monthDiff = today.getMonth() - birthDate.getMonth();
	const dayDiff = today.getDate() - birthDate.getDate();

	// Calculate actual age
	const actualAge = monthDiff < 0 || (monthDiff === 0 && dayDiff < 0) ? age - 1 : age;

	if (actualAge < 18) {
		return { valid: false, message: 'You must be at least 18 years old' };
	}

	if (actualAge > maxAge) {
		return { valid: false, message: `Age cannot exceed ${maxAge} years` };
	}

	return { valid: true, message: '' };
};