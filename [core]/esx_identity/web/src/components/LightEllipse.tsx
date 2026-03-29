export default function LightEllipse({ id, color, opacity }: { id: string, color: string, opacity?: number }) {

	return (
		<svg
			width="100%"
			height="100%"
			viewBox="0 0 400 400"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			style={{
				opacity: opacity ?? 1,
				overflow: "visible",
			}}
		>
			<defs>
				<radialGradient id={id} cx="50%" cy="50%" r="50%">
					<stop offset="0%" stop-color={color} stop-opacity="1" />
					<stop offset="70%" stop-color={color} stop-opacity="0.6" />
					<stop offset="100%" stop-color={color} stop-opacity="0" />
				</radialGradient>

				<filter
					id={`${id}-filter`}
					x="-200%"
					y="-200%"
					width="500%"
					height="500%"
					filterUnits="userSpaceOnUse"
					colorInterpolationFilters="sRGB"
				>
					<feGaussianBlur in="SourceGraphic" stdDeviation={120} />
				</filter>
			</defs>
			<ellipse
				cx="200"
				cy="200"
				rx="200"
				ry="200"
				fill={`url(#${id})`}
				filter={`url(#${id}-filter)`}
			/>
		</svg>
	);
}