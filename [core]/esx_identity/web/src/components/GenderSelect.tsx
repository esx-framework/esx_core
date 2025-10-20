import { useEffect, useRef, useState } from 'preact/hooks';
import Genders from '../utils/Genders';


interface GenderSelectProps {
	label: string;
	value: string;
	onChange: (value: string) => void;
}


export function GenderSelect({ label, value, onChange }: GenderSelectProps) {
	const containerRef = useRef<HTMLDivElement>(null);
	const [open, setOpen] = useState(false);

	const selected = Genders.find((o) => o.value === value) || Genders[0];

	// Close on outside click
	useEffect(() => {
		const onDocClick = (e: MouseEvent) => {
			if (!containerRef.current) return;
			if (!containerRef.current.contains(e.target as Node)) {
				setOpen(false);
			}
		};
		document.addEventListener('mousedown', onDocClick);
		return () => document.removeEventListener('mousedown', onDocClick);
	}, []);

	return (
		<div className={'flex flex-col mt-[--input-margin-top]'} ref={containerRef}>
			<label className={'text-[length:--input-font-size] text-[--color-lightgray] uppercase tracking-tight ml-[--label-margin-left] font-poppins select-none mb-[--label-margin-bottom]'}>
				{label}
			</label>

			<div className="relative">
				<button
					type="button"
					onClick={() => setOpen(!open)}
					className="bg-[--input-background] h-[--input-height] text-[--color-white] poppins-input rounded-[--box-border-radius] w-full p-[--input-padding] px-[--select-padding] focus:outline-none text-left flex items-center"
				>
					<span className="absolute left-[11px] flex items-center">
						{selected.icon}
					</span>
					{selected.label}
				</button>

				<div className="pointer-events-none absolute right-[--input-value-right] top-1/2 -translate-y-1/2 text-[--color-lightgray]">
					<svg width="14" height="7" viewBox="0 0 14 7" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
						<g clip-path="url(#clip0_6_43)">
							<path fill-rule="evenodd" clip-rule="evenodd" d="M6.58521 5.92455L3.28529 2.62464L4.11013 1.7998L6.99763 4.6873L9.88513 1.7998L10.71 2.62464L7.41004 5.92455C7.30065 6.03391 7.15231 6.09535 6.99763 6.09535C6.84295 6.09535 6.6946 6.03391 6.58521 5.92455Z" fill="var(--color-white)" />
						</g>
						<defs>
							<clipPath id="clip0_6_43">
								<rect width="7" height="14" fill="white" transform="matrix(0 1 -1 0 14 0)" />
							</clipPath>
						</defs>
					</svg>
				</div>

				{open && (
					<ul className="absolute z-20 mt-1 w-full rounded-[6px] bg-[--select-background] border border-[--select-border] shadow-lg">
						{Genders.map((opt) => (
							<li
								key={opt.value}
								onMouseDown={(e) => {
									e.preventDefault();
									onChange(opt.value);
									setOpen(false);
								}}
								className="px-3 py-2 cursor-pointer flex gap-2 items-center hover:bg-[--select-hover] text-[--color-white]"
							>
								<span className="flex items-center">{opt.icon}</span>
								<span className="poppins-input">{opt.label}</span>
							</li>
						))}
					</ul>
				)}
			</div>
		</div>
	);
}
