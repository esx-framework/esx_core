import { useConfig } from '../contexts/ConfigContext';
import { useEffect, useRef } from 'preact/hooks';

interface HeightInputProps {
	label: string;
	value: number;
	min?: number;
	max?: number;
	step?: number;
	onChange: (val: number) => void;
}


export function HeightInput({ label, value, onChange }: HeightInputProps) {
	const { config } = useConfig();
	const inputRef = useRef<HTMLInputElement>(null);
	
	const min = config?.MinHeight || 120;
	const max = config?.MaxHeight || 220;
	const step = 1;

	// Update CSS variables when config changes
	useEffect(() => {
		if (inputRef.current) {
			inputRef.current.style.setProperty('--val', value.toString());
			inputRef.current.style.setProperty('--range-min', min.toString());
			inputRef.current.style.setProperty('--range-max', max.toString());
		}
	}, [value, min, max]);

	return (
		<div className={'flex flex-col mt-[--input-margin-top]'}>
			<label className={'text-[length:--input-font-size] text-[--color-lightgray] uppercase tracking-tight ml-[--label-margin-left] font-poppins select-none mb-[--label-margin-bottom]'}>
				{label}
			</label>
			<div className={'relative flex items-center h-[--input-height] bg-[--input-background] rounded-[--box-border-radius] p-[--input-padding] pr-[46px]'}>
				<input
					ref={inputRef}
					type="range"
					min={min}
					max={max}
					step={step}
					value={value}
					onInput={(e) => {
						const v = (e.currentTarget as HTMLInputElement).value;
						onChange(parseInt(v, 10));
						(e.currentTarget as HTMLInputElement).style.setProperty('--val', v);
					}}
					className={'w-full bg-transparent focus:outline-none range-sm'}
				/>
				<div className={'absolute right-[--input-value-right] top-1/2 -translate-y-1/2 text-[--color-black] bg-[--color-primary] flex justify-center items-center rounded-[--box-border-radius] h-[18px] w-[26px] font-poppins font-bold text-[12px]'}>
					{value}
				</div>
			</div>
		</div>
	);
}