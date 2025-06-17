<script lang="ts">
	export let entity_id: string;
	export let attributes: any;
	export let temperature: number; // Current temperature
	export let size: number = 44; // diameter in pixels
	export let strokeWidth: number = 3;

	// Extract temperature range from attributes or use realistic defaults
	$: minTemp = attributes?.min_temp || 10;  // More realistic minimum
	$: maxTemp = attributes?.max_temp || 30;  // More realistic maximum
	$: unit = attributes?.unit_of_measurement || 'C';

	// Calculate circle properties
	$: radius = (size - strokeWidth) / 2;
	$: circumference = 2 * Math.PI * radius;
	$: strokeDasharray = circumference;
	
	// Calculate temperature as percentage of the range
	$: tempPercentage = Math.max(0, Math.min(100, ((temperature - minTemp) / (maxTemp - minTemp)) * 100));
	$: strokeDashoffset = circumference - (tempPercentage / 100) * circumference;

	// Color based on temperature range - cooler temps = blue, warmer = red
	$: tempColor = getTemperatureColor(tempPercentage);

	function getTemperatureColor(percentage: number): string {
		// More vibrant colors for better visibility
		if (percentage < 25) {
			// Cold - bright blue
			return 'rgba(59, 130, 246, 1)'; // blue-500, full opacity
		} else if (percentage < 50) {
			// Cool - cyan/teal
			return 'rgba(6, 182, 212, 1)'; // cyan-500
		} else if (percentage < 75) {
			// Warm - orange
			return 'rgba(251, 146, 60, 1)'; // orange-400
		} else {
			// Hot - red
			return 'rgba(239, 68, 68, 1)'; // red-500
		}
	}
</script>

<div
	class="temperature-indicator"
	style:width="{size}px"
	style:height="{size}px"
	role="img"
	aria-label="Temperature: {Math.round(temperature)}°{unit}"
>
	<svg width={size} height={size} class="progress-ring">
		<!-- Background circle -->
		<circle
			cx={size / 2}
			cy={size / 2}
			r={radius}
			fill="none"
			stroke="rgba(255, 255, 255, 0.3)"
			stroke-width={strokeWidth}
		/>
		
		<!-- Temperature circle -->
		<circle
			cx={size / 2}
			cy={size / 2}
			r={radius}
			fill="none"
			stroke={tempColor}
			stroke-width={strokeWidth + 1}
			stroke-linecap="round"
			stroke-dasharray={strokeDasharray}
			stroke-dashoffset={strokeDashoffset}
			transform="rotate(-90 {size / 2} {size / 2})"
			class="progress-circle"
		/>
	</svg>
	
	<!-- Temperature text -->
	<div class="temperature-text">
		{Math.round(temperature)}°
	</div>
</div>

<style>
	.temperature-indicator {
		position: relative;
		user-select: none;
		touch-action: none;
		pointer-events: none; /* Temperature is read-only */
	}

	.progress-ring {
		position: absolute;
		top: 0;
		left: 0;
		pointer-events: none;
	}

	.progress-circle {
		transition: stroke-dashoffset 0.5s ease, stroke 0.3s ease;
	}

	.temperature-text {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		font-size: 0.7rem;
		font-weight: 700;
		color: rgba(255, 255, 255, 1);
		pointer-events: none;
		line-height: 1;
		text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5);
	}

	/* Reduced motion support */
	@media (prefers-reduced-motion: reduce) {
		.progress-circle {
			transition: none;
		}
	}
</style>
