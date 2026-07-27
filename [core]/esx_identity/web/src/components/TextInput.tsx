import { useConfig } from '../contexts/ConfigContext';

interface TextInputProps {
	label: string;
	value: string;
	onValueChange?: (value: string) => void;
	maxLength?: number;
}


export function TextInput({ label, value, onValueChange }: TextInputProps) {
	const { config } = useConfig();
	const maxLength = config?.MaxNameLength || 20;
	const checked = value.trim().length > 0;

	return (
		<div className={'flex flex-col mt-[--input-margin-top]'}>
			<label className={'text-[length:--input-font-size] text-[--color-lightgray] uppercase tracking-tight ml-[--label-margin-left] font-poppins select-none mb-[--label-margin-bottom]'}>
				{label}
			</label>

			<div className={'relative'}>
				<input
					value={value}
					type="text"
					maxLength={maxLength}
					onInput={(e) => onValueChange?.(e.currentTarget.value)}
					className={'bg-[--input-background] text-[--color-white] poppins-input rounded-[--box-border-radius] w-full p-[--input-padding] pr-[50px] focus:outline-none h-[--input-height]'}
				/>

				<div
					className={`absolute right-[--input-value-right] top-1/2 -translate-y-1/2 w-[--input-box-xy] h-[--input-box-xy] rounded-[--box-border-radius] flex items-center justify-center transition-colors pointer-events-none ${checked ? 'bg-[--color-primary] checkbox-toggle' : 'bg-[--input-box-unchecked-background]'}`}
				>
					{checked && (
						<svg xmlns="http://www.w3.org/2000/svg" className={'mr-[1px]'} width="14" height="14" fill="#000000" viewBox="0 0 16 16">
							<path d="M12.736 3.97a.733.733 0 0 1 1.047 0c.286.289.29.756.01 1.05L7.88 12.01a.733.733 0 0 1-1.065.02L3.217 8.384a.757.757 0 0 1 0-1.06.733.733 0 0 1 1.047 0l3.052 3.093 5.4-6.425z" />
						</svg>
					)}
				</div>
			</div>
		</div>
	);
}
