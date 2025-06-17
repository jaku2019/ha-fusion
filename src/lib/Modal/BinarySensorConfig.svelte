<script lang="ts">
	import {
		dashboard,
		entityList,
		history,
		historyIndex,
		lang,
		record,
		ripple,
		states
	} from '$lib/Stores';
	import { onDestroy, tick } from 'svelte';
	import BinarySensor from '$lib/Sidebar/BinarySensor.svelte';
	import Select from '$lib/Components/Select.svelte';
	import InputClear from '$lib/Components/InputClear.svelte';
	import ConfigButtons from '$lib/Modal/ConfigButtons.svelte';
	import Modal from '$lib/Modal/Index.svelte';
	import Ripple from 'svelte-ripple';
	import { updateObj } from '$lib/Utils';
	import type { BinarySensorItem } from '$lib/Types';

	export let isOpen: boolean;
	export let sel: BinarySensorItem;
	export let demo: string | undefined = undefined;

	if (demo) {
		// replace history entry with demo
		$history.splice($historyIndex, 1);
		set('entity_id', demo);
	}

	let prefix: string | undefined = sel?.prefix;
	let suffix: string | undefined = sel?.suffix;
	let icon_on: string | undefined = sel?.icon_on;
	let icon_off: string | undefined = sel?.icon_off;
	let on_value: string | undefined = sel?.on_value;
	let off_value: string | undefined = sel?.off_value;

	$: entity_id = sel?.entity_id;
	$: options = $entityList('binary_sensor');

	function set(key: string, event?: any) {
		sel = updateObj(sel, key, event);
		$dashboard = $dashboard;
	}

	onDestroy(() => $record());

	/**
	 * Icon suggestions based on entity type
	 */
	const iconSuggestions = {
		door: {
			on: ['mdi:door-open', 'mdi:door-open-variant'],
			off: ['mdi:door-closed', 'mdi:door-closed-lock']
		},
		window: {
			on: ['mdi:window-open', 'mdi:window-open-variant'],
			off: ['mdi:window-closed', 'mdi:window-closed-variant']
		},
		motion: {
			on: ['mdi:motion-sensor', 'mdi:run-fast', 'mdi:walk'],
			off: ['mdi:motion-sensor-off', 'mdi:sleep']
		},
		contact: {
			on: ['mdi:door-open', 'mdi:magnetic'],
			off: ['mdi:door-closed', 'mdi:magnet-on']
		},
		occupancy: {
			on: ['mdi:home-account', 'mdi:account-check'],
			off: ['mdi:home-outline', 'mdi:account-off']
		},
		safety: {
			on: ['mdi:alert', 'mdi:fire', 'mdi:water'],
			off: ['mdi:shield-check', 'mdi:check-circle']
		}
	};

	$: entityType = entity_id ? getEntityType(entity_id) : 'generic';
	$: suggestedIcons = iconSuggestions[entityType as keyof typeof iconSuggestions] || {
		on: ['mdi:checkbox-marked-circle', 'mdi:toggle-switch'],
		off: ['mdi:checkbox-blank-circle-outline', 'mdi:toggle-switch-off']
	};

	function getEntityType(entityId: string): string {
		const id = entityId.toLowerCase();
		if (id.includes('door')) return 'door';
		if (id.includes('window')) return 'window';
		if (id.includes('motion') || id.includes('pir')) return 'motion';
		if (id.includes('contact')) return 'contact';
		if (id.includes('occupancy')) return 'occupancy';
		if (id.includes('smoke') || id.includes('fire') || id.includes('gas') || id.includes('water')) return 'safety';
		return 'generic';
	}
</script>

{#if isOpen}
	<Modal>
		<h1 slot="title">{$lang('binary_sensor')}</h1>

		<h2>{$lang('preview')}</h2>

		<div class="preview">
			<BinarySensor
				entity_id={sel?.entity_id}
				prefix={prefix}
				suffix={suffix}
				icon_on={icon_on}
				icon_off={icon_off}
				on_value={on_value}
				off_value={off_value}
			/>
		</div>

		<h2>{$lang('entity')}</h2>

		{#if options && options.length > 0}
			<Select
				computeIcons={true}
				{options}
				placeholder="Select a binary sensor entity"
				value={sel?.entity_id}
				on:change={(event) => set('entity_id', event)}
			/>
		{:else}
			<div style="color: #888; font-style: italic;">No binary sensor entities found</div>
		{/if}

		<h2>{$lang('prefix')}</h2>

		<InputClear
			condition={prefix}
			on:clear={() => {
				prefix = undefined;
				set('prefix');
			}}
			let:padding
		>
			<input
				name={$lang('prefix')}
				class="input"
				type="text"
				placeholder={$lang('prefix')}
				autocomplete="off"
				spellcheck="false"
				bind:value={prefix}
				on:change={(event) => set('prefix', event)}
				style:padding
			/>
		</InputClear>

		<h2>{$lang('suffix')}</h2>

		<InputClear
			condition={suffix}
			on:clear={() => {
				suffix = undefined;
				set('suffix');
			}}
			let:padding
		>
			<input
				name={$lang('suffix')}
				class="input"
				type="text"
				placeholder={$lang('suffix')}
				autocomplete="off"
				spellcheck="false"
				bind:value={suffix}
				on:change={(event) => set('suffix', event)}
				style:padding
			/>
		</InputClear>

		<h2>Text when ON</h2>

		<InputClear
			condition={on_value}
			on:clear={() => {
				on_value = undefined;
				set('on_value');
			}}
			let:padding
		>
			<input
				name="Text when ON"
				class="input"
				type="text"
				placeholder="e.g., Open, Active, Detected"
				autocomplete="off"
				spellcheck="false"
				bind:value={on_value}
				on:change={(event) => set('on_value', event)}
				style:padding
			/>
		</InputClear>

		<h2>Text when OFF</h2>

		<InputClear
			condition={off_value}
			on:clear={() => {
				off_value = undefined;
				set('off_value');
			}}
			let:padding
		>
			<input
				name="Text when OFF"
				class="input"
				type="text"
				placeholder="e.g., Closed, Inactive, Clear"
				autocomplete="off"
				spellcheck="false"
				bind:value={off_value}
				on:change={(event) => set('off_value', event)}
				style:padding
			/>
		</InputClear>

		<h2>Icon when ON</h2>

		<InputClear
			condition={icon_on}
			on:clear={() => {
				icon_on = undefined;
				set('icon_on');
			}}
			let:padding
		>
			<input
				name="Icon when ON"
				class="input"
				type="text"
				placeholder="e.g., mdi:door-open"
				autocomplete="off"
				spellcheck="false"
				bind:value={icon_on}
				on:change={(event) => set('icon_on', event)}
				style:padding
			/>
		</InputClear>

		<!-- Icon suggestions for ON state -->
		{#if suggestedIcons.on.length > 0}
			<div class="icon-suggestions">
				<span class="suggestions-label">Suggestions:</span>
				{#each suggestedIcons.on as suggestedIcon}
					<button
						class="icon-suggestion"
						type="button"
						use:Ripple={{
							...$ripple,
							color: 'rgba(0, 0, 0, 0.35)'
						}}
						on:click={() => {
							icon_on = suggestedIcon;
							set('icon_on', { target: { value: suggestedIcon } });
						}}
					>
						{suggestedIcon}
					</button>
				{/each}
			</div>
		{/if}

		<h2>Icon when OFF</h2>

		<InputClear
			condition={icon_off}
			on:clear={() => {
				icon_off = undefined;
				set('icon_off');
			}}
			let:padding
		>
			<input
				name="Icon when OFF"
				class="input"
				type="text"
				placeholder="e.g., mdi:door-closed"
				autocomplete="off"
				spellcheck="false"
				bind:value={icon_off}
				on:change={(event) => set('icon_off', event)}
				style:padding
			/>
		</InputClear>

		<!-- Icon suggestions for OFF state -->
		{#if suggestedIcons.off.length > 0}
			<div class="icon-suggestions">
				<span class="suggestions-label">Suggestions:</span>
				{#each suggestedIcons.off as suggestedIcon}
					<button
						class="icon-suggestion"
						type="button"
						use:Ripple={{
							...$ripple,
							color: 'rgba(0, 0, 0, 0.35)'
						}}
						on:click={() => {
							icon_off = suggestedIcon;
							set('icon_off', { target: { value: suggestedIcon } });
						}}
					>
						{suggestedIcon}
					</button>
				{/each}
			</div>
		{/if}

		<ConfigButtons {sel} />
	</Modal>
{/if}

<style>
	.preview {
		background: rgba(0, 0, 0, 0.15);
		border-radius: 0.6rem;
		padding: 1rem;
		margin-bottom: 1rem;
	}

	.icon-suggestions {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
		margin-top: 0.5rem;
		align-items: center;
	}

	.suggestions-label {
		font-size: 0.875rem;
		color: var(--theme-colors-fg-secondary);
		margin-right: 0.5rem;
	}

	.icon-suggestion {
		background: var(--theme-colors-bg-secondary);
		border: 1px solid var(--theme-colors-border);
		border-radius: 0.375rem;
		padding: 0.25rem 0.5rem;
		font-size: 0.75rem;
		color: var(--theme-colors-fg-primary);
		cursor: pointer;
		transition: all var(--transition-fast);
	}

	.icon-suggestion:hover {
		background: var(--theme-colors-bg-tertiary);
		border-color: var(--theme-colors-primary);
	}
</style>
