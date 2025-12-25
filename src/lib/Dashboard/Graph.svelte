<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { connection, states, editMode } from '$lib/Stores';
	import { openModal } from 'svelte-modals';
	import type { HassEntity } from 'home-assistant-js-websocket';
	import type { ConfigGraph } from '$lib/Types';

	export let sel: any;
	export const sectionName: string | undefined = undefined;

	$: entity_id = sel?.entity_id;
	$: config = sel?.config || { hours: 24, stroke_color: '#4fc3f7', fill_color: '#4fc3f740' };

	let canvas: HTMLCanvasElement;
	let ctx: CanvasRenderingContext2D;
	let history: Array<{ state: string; last_changed: string }> = [];
	let width = 0;
	let height = 200;
	
	$: hours = config?.hours || 24;
	$: strokeColor = config?.stroke_color || '#4fc3f7';
	$: fillColor = config?.fill_color || '#4fc3f740';

	$: entity = entity_id && $states?.[entity_id] as HassEntity;
	$: if (canvas && entity_id) {
		fetchHistory();
	}

	// Redraw graph when colors or other config changes
	$: if (canvas && ctx && history.length > 0 && (strokeColor || fillColor || hours)) {
		drawGraph();
	}

	// Try to fetch the entity state if it's not in the store
	$: if (entity_id && !entity && $connection) {
		console.log('Graph: Entity not found in states, trying to fetch:', entity_id);
		// Note: In a real HA environment, entities should be in states already
		// This is mainly for development/demo purposes
	}

	// Debug logging
	$: console.log('Graph component debug:', { 
		entity_id, 
		entity: entity ? 'found' : 'not found', 
		states_available: Object.keys($states || {}).length,
		available_entities: Object.keys($states || {}).filter(key => key.startsWith('sensor.')).slice(0, 5),
		config,
		strokeColor,
		fillColor,
		hours
	});

	async function fetchHistory() {
		if (!$connection || !entity_id) return;

		const endTime = new Date();
		const startTime = new Date(endTime.getTime() - hours * 60 * 60 * 1000);

		try {
			// Try statistics first
			try {
				const response: any = await $connection.sendMessagePromise({
					type: 'recorder/statistics_during_period',
					start_time: startTime.toISOString(),
					end_time: endTime.toISOString(),
					statistic_ids: [entity_id],
					period: 'hour'
				});

				if (response?.[entity_id]?.length > 0) {
					history = response[entity_id].map((item: any) => ({
						state: (item.mean !== undefined ? item.mean : item.state)?.toString(),
						last_changed: item.start
					}));
					drawGraph();
					return;
				}
			} catch (statsError) {
				console.log('Statistics not available, trying regular history:', statsError);
			}

			// Fallback to regular history
			const response: any = await $connection.sendMessagePromise({
				type: 'history/history_during_period',
				start_time: startTime.toISOString(),
				end_time: endTime.toISOString(),
				entity_ids: [entity_id],
				minimal_response: true
			});

			if (response?.[0]) {
				history = response[0];
				drawGraph();
			}
		} catch (error) {
			console.error('Failed to fetch history:', error);
		}
	}

	function drawGraph() {
		if (!ctx || !history.length) return;

		console.log('Drawing graph with colors:', { strokeColor, fillColor });

		ctx.clearRect(0, 0, width, height);

		const values = history
			.map(point => parseFloat(point.state))
			.filter(val => !isNaN(val));

		if (values.length < 2) return;

		const minValue = Math.min(...values);
		const maxValue = Math.max(...values);
		const range = maxValue - minValue || 1;

		const points: Array<{ x: number; y: number }> = [];

		history.forEach((point, index) => {
			const value = parseFloat(point.state);
			if (!isNaN(value)) {
				const x = (index / (history.length - 1)) * width;
				const y = height - ((value - minValue) / range) * height;
				points.push({ x, y });
			}
		});

		// Draw filled area
		if (points.length > 1) {
			ctx.beginPath();
			ctx.moveTo(points[0].x, height);
			points.forEach(point => ctx.lineTo(point.x, point.y));
			ctx.lineTo(points[points.length - 1].x, height);
			ctx.closePath();
			ctx.fillStyle = fillColor;
			ctx.fill();
		}

		// Draw line
		if (points.length > 1) {
			ctx.beginPath();
			ctx.moveTo(points[0].x, points[0].y);
			points.forEach(point => ctx.lineTo(point.x, point.y));
			ctx.strokeStyle = strokeColor;
			ctx.lineWidth = 2;
			ctx.stroke();
		}
	}

	/**
	 * Handle click events in edit mode
	 */
	function handleClick() {
		if ($editMode) {
			openModal(() => import('$lib/Modal/DashboardGraphConfig.svelte'), {
				sel
			});
		}
	}

	/**
	 * Handle keyboard events for accessibility
	 */
	function handleKeydown(event: KeyboardEvent) {
		if ($editMode && (event.key === 'Enter' || event.key === ' ')) {
			event.preventDefault();
			handleClick();
		}
	}

	onMount(() => {
		if (canvas) {
			ctx = canvas.getContext('2d')!;
			const resizeObserver = new ResizeObserver(() => {
				width = canvas.offsetWidth;
				height = canvas.offsetHeight;
				canvas.width = width;
				canvas.height = height;
				drawGraph();
			});
			resizeObserver.observe(canvas);
		}
	});
</script>

<div 
	class="graph-container" 
	class:edit-mode={$editMode}
	on:click={handleClick}
	on:keydown={handleKeydown}
	style={!$editMode ? 'cursor: pointer;' : ''}
	role="button"
	tabindex="0"
>
	{#if !entity_id}
		<div class="unavailable">No entity selected</div>
	{:else if !entity && history.length === 0}
		<div class="unavailable">Loading entity: {entity_id}</div>
	{:else}
		<div class="header">
			<span class="entity-name">
				{(entity && entity.attributes?.friendly_name) || entity_id}
			</span>
			<span class="current-value">
				{#if entity && typeof entity === 'object'}
					{entity.state} {entity.attributes?.unit_of_measurement || ''}
				{:else}
					Loading...
				{/if}
			</span>
		</div>
		<canvas bind:this={canvas} class="graph-canvas"></canvas>
	{/if}
</div>

<style>
	.graph-container {
		display: grid;
		grid-template-rows: auto 1fr;
		width: 100%;
		height: 100%;
		aspect-ratio: 2 / 1;
		border-radius: 0.7em;
		background: var(--theme-button-background-color-off);
		padding: 0.85em;
		gap: 0.5em;
		overflow: hidden;
		margin: 0;
	}

	.edit-mode {
		cursor: pointer;
		opacity: 0.8;
	}

	.header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		font-size: 0.875rem;
		min-height: 1.25rem;
	}

	.entity-name {
		font-weight: 500;
		color: var(--theme-colors-fg-primary);
		font-size: 0.875rem;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.current-value {
		color: var(--theme-colors-fg-secondary);
		font-weight: 600;
		font-size: 0.875rem;
		white-space: nowrap;
	}

	.graph-canvas {
		width: 100%;
		height: 100%;
		min-height: 0;
	}

	.unavailable {
		display: flex;
		align-items: center;
		justify-content: center;
		height: 100%;
		color: var(--theme-colors-fg-secondary);
		font-style: italic;
		font-size: 0.875rem;
	}
</style>
