<script lang="ts">
	import { callService } from 'home-assistant-js-websocket';
	import { connection } from '$lib/Stores';
	import { getDomain } from '$lib/Utils';

	export let entity_id: string;
	export let attributes: any;
	export let value: number; // 0-100 percentage
	export let size: number = 40; // diameter in pixels
	export let strokeWidth: number = 3;

	let isDragging = false;
	let container: HTMLDivElement;

	// Calculate circle properties
	$: radius = (size - strokeWidth) / 2;
	$: circumference = 2 * Math.PI * radius;
	$: strokeDasharray = circumference;
	$: strokeDashoffset = circumference - (value / 100) * circumference;

	function getValueFromPosition(clientX: number, clientY: number): number {
		if (!container) return value;

		const rect = container.getBoundingClientRect();
		const centerX = rect.left + rect.width / 2;
		const centerY = rect.top + rect.height / 2;

		// Calculate angle from center
		const deltaX = clientX - centerX;
		const deltaY = clientY - centerY;
		let angle = Math.atan2(deltaY, deltaX);

		// Convert to 0-360 degrees, starting from top
		angle = (angle * 180) / Math.PI + 90;
		if (angle < 0) angle += 360;

		// Convert angle to percentage (0-100)
		const percentage = Math.round((angle / 360) * 100);
		return Math.max(0, Math.min(100, percentage));
	}

	function handlePointerDown(event: PointerEvent) {
		event.preventDefault();
		event.stopPropagation();
		isDragging = true;
		container.setPointerCapture(event.pointerId);
		
		const newValue = getValueFromPosition(event.clientX, event.clientY);
		updateBrightness(newValue);
	}

	function handlePointerMove(event: PointerEvent) {
		if (!isDragging) return;
		event.preventDefault();
		event.stopPropagation();
		
		const newValue = getValueFromPosition(event.clientX, event.clientY);
		updateBrightness(newValue);
	}

	function handlePointerUp(event: PointerEvent) {
		isDragging = false;
		container.releasePointerCapture(event.pointerId);
	}

	function updateBrightness(newValue: number) {
		const domain = getDomain(entity_id);
		
		if (domain === 'light') {
			// Convert percentage back to Home Assistant brightness (0-255)
			const brightness = Math.round((newValue / 100) * 255);
			
			callService($connection, 'light', 'turn_on', {
				entity_id,
				brightness
			});
		} else if (domain === 'cover') {
			callService($connection, 'cover', 'set_cover_position', {
				entity_id,
				position: newValue
			});
		} else if (domain === 'media_player') {
			callService($connection, 'media_player', 'volume_set', {
				entity_id,
				volume_level: newValue / 100
			});
		}
	}
</script>

<div
	bind:this={container}
	class="circular-indicator"
	class:dragging={isDragging}
	style:width="{size}px"
	style:height="{size}px"
	on:pointerdown={handlePointerDown}
	on:pointermove={handlePointerMove}
	on:pointerup={handlePointerUp}
	on:pointercancel={handlePointerUp}
	role="slider"
	tabindex="0"
	aria-valuenow={value}
	aria-valuemin="0"
	aria-valuemax="100"
	aria-label="Brightness control"
>
	<svg width={size} height={size} class="progress-ring">
		<!-- Background circle -->
		<circle
			cx={size / 2}
			cy={size / 2}
			r={radius}
			fill="none"
			stroke="rgba(0, 0, 0, 0.3)"
			stroke-width={strokeWidth}
		/>
		
		<!-- Progress circle -->
		<circle
			cx={size / 2}
			cy={size / 2}
			r={radius}
			fill="none"
			stroke="rgba(0, 0, 0, 0.8)"
			stroke-width={strokeWidth}
			stroke-linecap="round"
			stroke-dasharray={strokeDasharray}
			stroke-dashoffset={strokeDashoffset}
			transform="rotate(-90 {size / 2} {size / 2})"
			class="progress-circle"
		/>
	</svg>
	
	<!-- Percentage text -->
	<div class="percentage-text">
		{value}%
	</div>
</div>

<style>
	.circular-indicator {
		position: relative;
		cursor: pointer;
		user-select: none;
		touch-action: none;
		transition: transform 0.2s ease;
	}

	.circular-indicator:hover {
		transform: scale(1.05);
	}

	.circular-indicator.dragging {
		transform: scale(1.1);
	}

	.progress-ring {
		position: absolute;
		top: 0;
		left: 0;
		pointer-events: none;
	}

	.progress-circle {
		transition: stroke-dashoffset 0.3s ease;
	}

	.circular-indicator.dragging .progress-circle {
		transition: none;
	}

	.percentage-text {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		font-size: 0.65rem;
		font-weight: 600;
		color: rgba(0, 0, 0, 0.9);
		pointer-events: none;
		line-height: 1;
	}

	/* Focus styles for accessibility */
	.circular-indicator:focus-visible {
		outline: 2px solid rgba(255, 255, 255, 0.5);
		outline-offset: 2px;
		border-radius: 50%;
	}

	/* Reduced motion support */
	@media (prefers-reduced-motion: reduce) {
		.circular-indicator,
		.progress-circle {
			transition: none;
		}
	}
</style>
