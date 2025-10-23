import { render } from 'preact';
import { useState, useEffect } from 'preact/hooks';

import charRight from './assets/charRight.png';
import charLeft from './assets/charLeft.png';

import LightEllipse from './components/LightEllipse';
import { TextInput } from './components/TextInput';
import { DateInput } from './components/DateInput';
import { HeightInput } from './components/HeightInput';
import { NationalitySelect } from './components/NationalitySelect';
import { GenderSelect } from './components/GenderSelect';
import { ConfigProvider, useConfig } from './contexts/ConfigContext';

import './styles/fonts.css'
import './styles/style.css';

function AppContent() {
	const { config, setConfig } = useConfig();

	const [firstName, setFirstName] = useState('');
	const [lastName, setLastName] = useState('');

	const [birthDate, setBirthDate] = useState('//');

	const [height, setHeight] = useState(180);

	const [nationality, setNationality] = useState('United States');

	const [gender, setGender] = useState('Male');

	const [isBirthDateValid, setIsBirthDateValid] = useState(true);

	const canSubmit =
		firstName.trim().length > 0 &&
		lastName.trim().length > 0 &&
		isBirthDateValid && birthDate.trim().length >= 8
		// ⬆ Minimum 1 per DD and MM (2 in total) + 4 digits for YYYY + Separators (//) = 8
		&& birthDate.split('/')[2].length === 4
		// ⬆ Ensure year is 4 digits
		;

	const onSubmit = (e: Event) => {
		e.preventDefault();
		if (!canSubmit) return;

		const data = {
			firstname: firstName.trim() || null,
			lastname: lastName.trim() || null,
			dateofbirth: birthDate.trim() || null,
			sex: gender.toLowerCase() == "male" ? "m" : "f",
			height: height,
			nationality: nationality || null,
		};

		fetch("http://esx_identity/register", {
			method: "POST",
			body: JSON.stringify(data),
		});

		setFirstName('');
		setLastName('');
		setBirthDate('//');
		setHeight(config?.MinHeight ? Math.floor((config.MinHeight + (config.MaxHeight || config.MinHeight)) / 2) : 180);
		setNationality('United States');
	}

	useEffect(() => {
		document.body.classList.add("none");

		fetch("http://esx_identity/ready", {
			method: "POST",
			body: JSON.stringify({}),
		}).then(async (res) => {
			const response = await res.json();
			if (response.config) {
				setConfig(response.config);
				setHeight(response.config.MaxHeight ? Math.floor((response.config.MinHeight + response.config.MaxHeight) / 2) : 180);
			}
		});

		const handleMessage = (event) => {
			switch (event.data.type) {
				case "enableui":
					document.body.classList[event.data.enable ? "remove" : "add"]("none");
					break;
			};
		}

		window.addEventListener("message", handleMessage);

		return () => window.removeEventListener("message", handleMessage);
	}, []);


	return (
		<div className={'w-screen h-screen'}>
			<div className="absolute -z-10 h-full w-full">
				<div className="absolute bottom-0 left-0 rotate-270" style={{ width: '39vw', height: '90vh' }}>
					<img
						src={charLeft}
						alt="Character Left"
						className="w-full h-full object-contain object-bottom"
					/>
				</div>

				<div className="absolute left-[61.5vw] bottom-0" style={{ width: '39vw', height: '100vh' }}>
					<img
						className="w-full h-full object-contain object-bottom"
						src={charRight}
						alt="Character Right"
					/>
				</div>

				<div className="absolute z-0 top-[-32vh] left-[50vw]" style={{ width: '50vw', height: '75vh' }}>
					<LightEllipse id="orange-ellipse" color={'#FB9B04'} opacity={0.4} />
				</div>

				<div className="absolute z-0 bottom-[-25vh] left-[-18.519vw]" style={{ width: '50vw', height: '80vh' }}>
					<LightEllipse id="white-ellipse" color={'#FFFFFF'} opacity={0.15} />
				</div>
			</div>

			<div className={'absolute z-20 w-screen h-screen flex justify-center items-center'}>
				<div className={'w-[--ui-width] h-[--ui-height] bg-[--ui-background] border-[1px] border-[--ui-border] px-[--ui-padding] pb-[--ui-padding] rounded-[20px] backdrop-blur-[5px] font-poppins'}>
					<h1 className={'mt-[33px] font-bold text-[length:--header-font-size] uppercase text-center text-white tracking-[0%] mb-[30px]'}>Character <span className={'text-[--color-primary]'}>Identity</span></h1>

					<TextInput
						label="First Name"
						value={firstName}
						onValueChange={setFirstName}
					/>

					<TextInput
						label="Last Name"
						value={lastName}
						onValueChange={setLastName}
					/>

					<DateInput
						label="Birth Date"
						value={birthDate}
						onValueChange={setBirthDate}
						onValidityChange={setIsBirthDateValid}
					/>

					<HeightInput
						label="Height (CM)"
						value={height}
						onChange={setHeight}
					/>

					<NationalitySelect
						label="Nationality"
						value={nationality}
						onChange={setNationality}
					/>

					<GenderSelect
						label="Gender"
						value={gender}
						onChange={setGender}
					/>

					<button
						onClick={onSubmit}
						disabled={!canSubmit}
						className={
							'bg-[--color-primary] h-[--input-height] w-full mt-[31px] uppercase rounded-[--box-border-radius] text-[13px] font-poppins font-[600] text-[--color-black] ' +
							'hover:bg-[--color-submit-hover] active:scale-95 transition-all duration-150 ' +
							'disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-[--color-primary] disabled:active:scale-100'
						}
					>
						Create My Character
					</button>
				</div>
			</div>
		</div>
	);
}

function App() {
	return (
		<ConfigProvider>
			<AppContent />
		</ConfigProvider>
	);
}

render(<App />, document.getElementById('app'));
