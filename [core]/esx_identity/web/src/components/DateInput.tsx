import { useState, useEffect } from 'preact/hooks';
import IsValidDate from '../utils/IsValidDate';
import IsValidAge from '../utils/IsValidAge';
import { useConfig } from '../contexts/ConfigContext';

interface DateInputProps {
	label: string;
	value: string;
	onValueChange?: (value: string) => void;
	onValidityChange?: (valid: boolean) => void;
}


export function DateInput({ label, value, onValueChange, onValidityChange }: DateInputProps) {
	const { config } = useConfig();
	const [showError, setShowError] = useState(false);
	const [errorMessage, setErrorMessage] = useState('');

	const getDateParts = () => {
		const parts = value.split('/');
		if (!config) return { day: '', month: '', year: '' };

		switch (config.DateFormat) {
			case 'MM/DD/YYYY':
				return { month: parts[0] || '', day: parts[1] || '', year: parts[2] || '' };
			case 'YYYY/MM/DD':
				return { year: parts[0] || '', month: parts[1] || '', day: parts[2] || '' };
			case 'DD/MM/YYYY':
			default:
				return { day: parts[0] || '', month: parts[1] || '', year: parts[2] || '' };
		}
	};

	const { day, month, year } = getDateParts();

	useEffect(() => {
		if (!config) return;
		
		const { day, month, year } = getDateParts();
		const maxAge = config.MaxAge || 100;

		const dateCheck = IsValidDate(day, month, year, maxAge);
		const ageCheck = IsValidAge(day, month, year, maxAge);

		setShowError(!dateCheck.valid || !ageCheck.valid);
		setErrorMessage(!dateCheck.valid ? dateCheck.message : ageCheck.message);
	}, [value, config]);


	useEffect(() => {
		onValidityChange?.(!showError);
	}, [showError, onValidityChange]);


	// Handlers
	const handleDateChange = (part: 'day' | 'month' | 'year', newValue: string) => {
		if (!onValueChange || !config) return;

		const currentParts = getDateParts();
		currentParts[part] = newValue;

		// Format based on config
		let formattedValue: string;
		switch (config.DateFormat) {
			case 'MM/DD/YYYY':
				formattedValue = `${currentParts.month}/${currentParts.day}/${currentParts.year}`;
				break;
			case 'YYYY/MM/DD':
				formattedValue = `${currentParts.year}/${currentParts.month}/${currentParts.day}`;
				break;
			case 'DD/MM/YYYY':
			default:
				formattedValue = `${currentParts.day}/${currentParts.month}/${currentParts.year}`;
				break;
		}

		onValueChange(formattedValue);
	};


	const handleClear = () => {
		if (onValueChange) {
			onValueChange('');
		}
	};


	// Render inputs based on format
	const renderInputs = () => {
		if (!config) return null;

		const dayInput = (
			<input
				value={day}
				type="text"
				inputMode="numeric"
				placeholder="DD"
				maxLength={2}
				onChange={(e) => handleDateChange('day', e.currentTarget.value)}
				onKeyPress={(e) => {
					if (!/[0-9]/.test(e.key)) {
						e.preventDefault();
					}
				}}
				className={'bg-transparent w-[23px] p-0 m-0 border-none focus:outline-none text-center tabular-nums placeholder:text-[--color-white]'}
			/>
		);

		const monthInput = (
			<input
				value={month}
				type="text"
				inputMode="numeric"
				placeholder="MM"
				maxLength={2}
				onChange={(e) => handleDateChange('month', e.currentTarget.value)}
				onKeyPress={(e) => {
					if (!/[0-9]/.test(e.key)) {
						e.preventDefault();
					}
				}}
				className={'bg-transparent w-[23px] p-0 m-0 border-none focus:outline-none text-center tabular-nums placeholder:text-[--color-white]'}
			/>
		);

		const yearInput = (
			<input
				value={year}
				type="text"
				inputMode="numeric"
				placeholder="YYYY"
				maxLength={4}
				onChange={(e) => handleDateChange('year', e.currentTarget.value)}
				onKeyPress={(e) => {
					if (!/[0-9]/.test(e.key)) {
						e.preventDefault();
					}
				}}
				className={'bg-transparent poppins-input w-[30px] p-0 m-0 border-none focus:outline-none text-left tabular-nums placeholder:text-[--color-white]'}
			/>
		);

		const separator = <span className={'mx-1'}>/</span>;

		switch (config.DateFormat) {
			case 'MM/DD/YYYY':
				return <>{monthInput}{separator}{dayInput}{separator}{yearInput}</>;
			case 'YYYY/MM/DD':
				return <>{yearInput}{separator}{monthInput}{separator}{dayInput}</>;
			case 'DD/MM/YYYY':
			default:
				return <>{dayInput}{separator}{monthInput}{separator}{yearInput}</>;
		}
	};

	return (
		<div className={'flex flex-col mt-[--input-margin-top]'}>
			<label className={'text-[length:--input-font-size] text-[--color-lightgray] uppercase tracking-tight ml-[--label-margin-left] select-none mb-[--label-margin-bottom]'}>
				{label}
			</label>

			<div className={`relative flex h-[--input-height] items-center bg-[--input-background] rounded-[--box-border-radius] p-[--input-padding] pr-[50px] poppins-input text-[--color-white] placeholder:text-[--color-white] ${showError ? 'ring-2 ring-red-800' : ''}`}
			>

				{renderInputs()}

				<div
					onClick={handleClear}
					className={'absolute right-[--input-value-right] top-1/2 -translate-y-1/2 w-[--input-box-xy] h-[--input-box-xy] rounded-[--box-border-radius] flex items-center justify-center cursor-pointer bg-[--color-black] date-clear'}
				>
					<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8" fill="var(--color-lightgray)" viewBox="0 0 16 16">
						<path d="M2.146 2.854a.5.5 0 1 1 .708-.708L8 7.293l5.146-5.147a.5.5 0 0 1 .708.708L8.707 8l5.147 5.146a.5.5 0 0 1-.708.708L8 8.707l-5.146 5.147a.5.5 0 0 1-.708-.708L7.293 8z" />
					</svg>
				</div>
			</div>

			{showError && errorMessage && (
				<span className={'text-[length:--input-font-size] text-red-500 ml-[--label-margin-left] mt-[4px]'}
				>
					{errorMessage}
				</span>
			)}
		</div>
	);
}
