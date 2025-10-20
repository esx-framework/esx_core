import { createContext } from 'preact';
import { useContext, useState } from 'preact/hooks';

interface Config {
	DateFormat: 'DD/MM/YYYY' | 'MM/DD/YYYY' | 'YYYY/MM/DD';
	MaxNameLength: number;
	MinHeight: number;
	MaxHeight: number;
	MaxAge: number;
}

interface ConfigContextType {
	config: Config | null;
	setConfig: (config: Config) => void;
}

const ConfigContext = createContext<ConfigContextType | undefined>(undefined);

export function ConfigProvider({ children }) {
	const [config, setConfig] = useState<Config | null>(null);

	return (
		<ConfigContext.Provider value={{ config, setConfig }}>
			{children}
		</ConfigContext.Provider>
	);
}

export function useConfig() {
	const context = useContext(ConfigContext);
	if (context === undefined) {
		throw new Error('useConfig must be used within a ConfigProvider');
	}
	return context;
}
