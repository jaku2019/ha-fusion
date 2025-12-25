<script lang="ts">
	import { dashboard, states, connection, lang, record, ripple, entityList } from '$lib/Stores';
	import { onDestroy } from 'svelte';
	import Graph from '$lib/Dashboard/Graph.svelte';
	import Select from '$lib/Components/Select.svelte';
	import ConfigButtons from '$lib/Modal/ConfigButtons.svelte';
	import InputClear from '$lib/Components/InputClear.svelte';
	import Modal from '$lib/Modal/Index.svelte';
	import { updateObj, getName } from '$lib/Utils';
	import type { ConfigGraph } from '$lib/Types';
	import Ripple from 'svelte-ripple';

	export let isOpen: boolean;
	export let sel: any;
	export let demo: string | undefined = undefined;

	if (demo) {
		set('entity_id', demo);
	} else if (!sel.entity_id) {
		// Use a fallback entity that's likely to exist
		const fallbackEntity = 'sensor.memory_use_percent';
		console.log('DashboardGraphConfig: No demo entity, using fallback:', fallbackEntity);
		set('entity_id', fallbackEntity);
	}

	// Ensure we have a config object
	if (!sel.config) {
		sel.config = {
			hours: 24,
			stroke_color: '#4fc3f7',
			fill_color: '#4fc3f740'
		};
		$dashboard = $dashboard;
	}

	// Debug: Watch for entity availability
	$: if (sel?.entity_id) {
		console.log('DashboardGraphConfig: entity_id changed to', sel.entity_id);
		console.log('DashboardGraphConfig: entity in states?', !!$states?.[sel.entity_id]);
		if ($states?.[sel.entity_id]) {
			console.log('DashboardGraphConfig: entity state:', $states[sel.entity_id].state);
		}
	}

	let name = sel?.name;

	let options: { id: string; label: string }[];

	// Use regular sensor entities as fallback
	$: if (!options) {
		const sensorEntities = $entityList('sensor');
		// Add some known working entities from the dashboard config
		const knownEntities = [
			{ id: 'sensor.memory_use_percent', label: 'Memory Usage (%)' },
			{ id: 'sensor.processor_use', label: 'CPU Usage' },
			{ id: 'sensor.energy_meter_phase_a_power', label: 'Energy Usage' },
			{ id: 'sensor.thor_memory_usage_real_4', label: 'Thor Memory Usage' }
		];

		if (sensorEntities.length === 0) {
			options = knownEntities;
		} else {
			// Combine known entities with available sensor entities
			const existingIds = new Set(sensorEntities.map((e) => e.id));
			const additionalKnown = knownEntities.filter((e) => !existingIds.has(e.id));
			options = [...additionalKnown, ...sensorEntities];
		}
		console.log('DashboardGraphConfig: Available options:', options.length);
	}

	const hoursOptions = [
		{ id: '1', label: '1 hour' },
		{ id: '6', label: '6 hours' },
		{ id: '12', label: '12 hours' },
		{ id: '24', label: '24 hours' },
		{ id: '48', label: '48 hours' },
		{ id: '168', label: '1 week' }
	];

	function set(key: string, event?: any) {
		sel = updateObj(sel, key, event);
		$dashboard = $dashboard;
	}

	onDestroy(() => $record());

	connection.subscribe(async (conn) => {
		if (!conn) return;

		try {
			const [res1, res2]: [any, any] = await Promise.all([
				conn.sendMessagePromise({ type: 'recorder/list_statistic_ids' }),
				conn.sendMessagePromise({ type: 'recorder/validate_statistics' })
			]);

			const list_statistic_ids = Object.values(res1)
				.map((entry: any) =>
					entry?.statistic_id?.startsWith('sensor.') ? entry.statistic_id : null
				)
				.filter(Boolean);

			const validate_statistics_set = new Set(
				Object.values(res2)
					.map((entry: any) => entry[0]?.data?.statistic_id)
					.filter(Boolean)
			);

			const statisticsOptions = list_statistic_ids
				.filter((id) => !validate_statistics_set.has(id))
				.map((item) => ({ id: item, label: item }));

			// Combine statistics entities with regular sensor entities
			if (statisticsOptions.length > 0) {
				options = [...statisticsOptions, ...$entityList('sensor')];
			}
		} catch (err) {
			console.error('Failed to fetch statistics entities:', err);
			// Fallback to regular sensor entities
			options = $entityList('sensor');
		}
	});
</script>

{#if isOpen}
	<Modal>
		<h1 slot="title">{$lang('graph')}</h1>

		<h2>{$lang('preview')}</h2>

		<div class="preview">
			{#if sel?.entity_id}
				<Graph {sel} />
			{:else}
				<div
					style="display: flex; align-items: center; justify-content: center; height: 100%; color: #888;"
				>
					Select an entity to see preview
				</div>
			{/if}
		</div>

		<h2>{$lang('entity')}</h2>

		<div
			style="margin-bottom: 1rem; padding: 0.5rem; background: rgba(255,255,255,0.1); border-radius: 0.25rem; font-size: 0.85rem;"
		>
			Debug: Current entity_id = "{sel?.entity_id || 'none'}"<br />
			Debug: Entity in states = {sel?.entity_id && $states?.[sel?.entity_id] ? 'YES' : 'NO'}<br />
			Debug: Available sensor entities = {Object.keys($states || {}).filter((key) =>
				key.startsWith('sensor.')
			).length}
		</div>

		{#if options && options.length > 0}
			<Select
				computeIcons={true}
				{options}
				placeholder="Select a sensor entity"
				value={sel?.entity_id}
				on:change={(event) => {
					console.log('Entity selection changed:', event?.detail);
					set('entity_id', event);
				}}
			/>
		{:else}
			<div style="color: #888; font-style: italic;">Loading entities...</div>
		{/if}

		<h2>{$lang('name')}</h2>

		<InputClear
			condition={name}
			on:clear={() => {
				name = undefined;
				set('name');
			}}
			let:padding
		>
			<input
				name={$lang('name')}
				class="input"
				type="text"
				placeholder={getName(sel, (sel.entity_id && $states[sel.entity_id]) || undefined) ||
					$lang('name')}
				autocomplete="off"
				spellcheck="false"
				bind:value={name}
				on:change={(event) => set('name', event)}
				style:padding
			/>
		</InputClear>

		<h2>Time Range</h2>

		{#if hoursOptions}
			<Select
				options={hoursOptions}
				placeholder="Select time range"
				value={sel?.config?.hours?.toString() || '24'}
				on:change={(event) => {
					if (!sel.config) sel.config = {};
					sel.config.hours = parseInt(event?.detail || '24');
					$dashboard = $dashboard;
				}}
			/>
		{/if}

		<h2>Stroke Color</h2>

		<input
			class="input"
			type="color"
			value={sel?.config?.stroke_color || '#4fc3f7'}
			on:input={(event) => {
				if (!sel.config) sel.config = {};
				sel.config.stroke_color = event.currentTarget.value;
				$dashboard = $dashboard;
			}}
		/>

		<h2>Fill Color</h2>

		<input
			class="input"
			type="color"
			value={sel?.config?.fill_color?.replace('40', '') || '#4fc3f7'}
			on:input={(event) => {
				if (!sel.config) sel.config = {};
				sel.config.fill_color = event.currentTarget.value + '40';
				$dashboard = $dashboard;
			}}
		/>

		<ConfigButtons {sel} />
	</Modal>
{/if}

<style>
	.preview {
		height: 12rem;
		border: 1px solid rgba(255, 255, 255, 0.1);
		border-radius: 0.5rem;
		overflow: hidden;
	}
</style>
