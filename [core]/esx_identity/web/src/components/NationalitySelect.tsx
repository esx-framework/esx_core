import { useEffect, useMemo, useRef, useState } from 'preact/hooks';
import Nationalities from '../utils/Nationalities';
import { polyfillCountryFlagEmojis } from "country-flag-emoji-polyfill";

interface NationalitySelectProps {
	label: string;
	value: string;
	onChange: (value: string) => void;
}


export function NationalitySelect({ label, value, onChange }: NationalitySelectProps) {
	const containerRef = useRef<HTMLDivElement>(null);
	const [open, setOpen] = useState(false);
	const [highlight, setHighlight] = useState(0);

	const [search, setSearch] = useState('');
	const [typing, setTyping] = useState(false);


	// Get selected option/index from current value
	const selectedIndex = useMemo(
		() => Nationalities.findIndex((o) => o.value.toLowerCase() === (value || '').toLowerCase()),
		[value]
	);
	const selected = selectedIndex >= 0 ? Nationalities[selectedIndex] : null;

	// Filter search only when typing -> otherwise show all
	const filtered = useMemo(() => {
		if (!typing || search.trim() === '') return Nationalities;
		const q = search.toLowerCase();
		return Nationalities.filter((o) => o.label.toLowerCase().includes(q) || o.value.toLowerCase().includes(q));
	}, [typing, search]);

	// When search changes -> reset highlight
	useEffect(() => {
		setHighlight(0);
	}, [typing, search]);

	// Close on outside click & reset search/typing
	useEffect(() => {
		const onDocClick = (e: MouseEvent) => {
			if (!containerRef.current) return;
			if (!containerRef.current.contains(e.target as Node)) {
				setOpen(false);
				setTyping(false);
				setSearch('');
			}
		};
		document.addEventListener('mousedown', onDocClick);
		return () => document.removeEventListener('mousedown', onDocClick);
	}, []);


	// Handle typing for search
	function inputKeyDown(e: KeyboardEvent) {
		if (e.key === 'ArrowDown') {
			e.preventDefault();
			setOpen(true);
			setHighlight((h) => Math.min(h + 1, Math.max(0, filtered.length - 1)));
		} else if (e.key === 'ArrowUp') {
			e.preventDefault();
			setOpen(true);
			setHighlight((h) => Math.max(0, h - 1));
		} else if (e.key === 'Enter') {
			if (open && filtered[highlight]) {
				onChange(filtered[highlight].value);
				setOpen(false);
				setTyping(false);
				setSearch('');
			}
		} else if (e.key === 'Escape') {
			setOpen(false);
			setTyping(false);
			setSearch('');
		}
	}

	useEffect(() => {
		polyfillCountryFlagEmojis();
	}, []);


	return (
		<div className={'flex flex-col mt-[--input-margin-top]'} ref={containerRef}>
			<label className={'text-[length:--input-font-size] text-[--color-lightgray] uppercase tracking-tight ml-[--label-margin-left] font-poppins select-none mb-[--label-margin-bottom]'}>
				{label}
			</label>

			<div className="relative">

				{selected && !typing && (
					<span className="pointer-events-none absolute left-[11px] top-1/2 -translate-y-1/2 text-base leading-none font-emoji">
						{selected.flag}
					</span>
				)}

				<input
					value={typing ? search : (selected ? selected.label : value)}
					onInput={(e) => {
						const newValue = (e.currentTarget as HTMLInputElement).value;
						setTyping(true);
						setSearch(newValue);
						setOpen(true);
					}}
					onFocus={() => {
						setOpen(true);
						// Reset if not already typing
						if (!typing) {
							setTyping(false);
							setSearch('');
							setHighlight(selectedIndex >= 0 ? selectedIndex : 0);
						}
					}}
					onClick={() => {
						// Clicking while already focused -> start fresh / show all options
						if (!open) {
							setTyping(false);
							setSearch('');
							setHighlight(selectedIndex >= 0 ? selectedIndex : 0);
						}
					}}
					onKeyDown={(e) => inputKeyDown(e)}
					placeholder="Type or select nationality"
					className={`bg-[--input-background] h-[--input-height] text-[--color-white] poppins-input rounded-[--box-border-radius] w-full p-[--input-padding] pr-[--select-padding] focus:outline-none ${selected && !typing ? 'pl-[--select-padding]' : ''}`}
				/>

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
					<ul className="absolute z-20 mt-1 max-h-48 w-full overflow-auto rounded-[6px] bg-[--select-background] border border-[--select-border] shadow-lg scrollbar-none">
						{filtered.length === 0 ? (
							<li className="px-3 py-2 text-[--color-lightgray] poppins-input">No matches</li>
						) : (
							filtered.map((opt, idx) => (
								<li
									key={opt.value}
									onMouseEnter={() => setHighlight(idx)}
									onMouseDown={(e) => {
										e.preventDefault();
										onChange(opt.value);
										setOpen(false);
										setTyping(false);
										setSearch('');
									}}
									className={'px-3 py-2 cursor-pointer flex gap-2 items-center text-[--color-white] hover:bg-[--select-hover]'}
								>
									<span className="text-base leading-none font-emoji">{opt.flag}</span>
									<span className="poppins-input">{opt.label}</span>
								</li>
							))
						)}
					</ul>
				)}
				
			</div>
		</div>
	);
}
