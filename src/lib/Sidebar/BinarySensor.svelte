<script lang="ts">
	import { states, editMode, motion, lang } from '$lib/Stores';
	import type { HassEntity } from 'home-assistant-js-websocket';
	import Icon from '@iconify/svelte';

	export let entity_id: string | undefined = undefined;
	export let prefix: string | undefined = undefined;
	export let suffix: string | undefined = undefined;
	export let icon_on: string | undefined = undefined;
	export let icon_off: string | undefined = undefined;
	export let on_value: string | undefined = undefined;
	export let off_value: string | undefined = undefined;

	let entity: HassEntity;

	$: if (entity_id && $states?.[entity_id]?.last_updated !== entity?.last_updated) {
		entity = $states?.[entity_id];
	}

	$: state = entity?.state;
	$: isOn = state === 'on';
	$: isOff = state === 'off';
	$: isUnavailable = ['unavailable', 'unknown'].includes(state);

	// Determine display text
	$: displayText = isUnavailable 
		? $lang(state) 
		: isOn 
			? (on_value || $lang('on'))
			: isOff 
				? (off_value || $lang('off'))
				: state;

	// Determine icon to show
	$: currentIcon = isOn 
		? (icon_on || entity?.attributes?.icon || getDefaultIcon(entity_id, true))
		: (icon_off || entity?.attributes?.icon || getDefaultIcon(entity_id, false));

	function getDefaultIcon(entityId: string | undefined, isOn: boolean): string {
		if (!entityId) return 'mdi:help-circle';
		
		// Door sensors
		if (entityId.includes('door')) {
			return isOn ? 'mdi:door-open' : 'mdi:door-closed';
		}
		// Window sensors
		if (entityId.includes('window')) {
			return isOn ? 'mdi:window-open' : 'mdi:window-closed';
		}
		// Motion sensors
		if (entityId.includes('motion') || entityId.includes('pir')) {
			return isOn ? 'mdi:motion-sensor' : 'mdi:motion-sensor-off';
		}
		// Contact sensors
		if (entityId.includes('contact')) {
			return isOn ? 'mdi:door-open' : 'mdi:door-closed';
		}
		// Occupancy sensors
		if (entityId.includes('occupancy')) {
			return isOn ? 'mdi:home-account' : 'mdi:home-outline';
		}
		// Generic binary sensor
		return isOn ? 'mdi:checkbox-marked-circle' : 'mdi:checkbox-blank-circle-outline';
	}
</script>

<div
	class="container"
	class:visible={!entity || state || $editMode}
	class:on={isOn}
	class:off={isOff}
	class:unavailable={isUnavailable}
	style:padding-top={!entity || state || $editMode ? '' : '0'}
	style:padding-bottom={!entity || state || $editMode ? '' : '0'}
	style:transition="grid-template-rows {$motion}ms ease, padding {$motion}ms ease"
>
	<div class="expandable">
		<div class="content">
			{#if currentIcon}
				<div class="icon">
					<Icon icon={currentIcon} />
				</div>
			{/if}
			
			<div class="text">
				{#if isUnavailable}
					{prefix || ''}{displayText}{suffix || ''}
				{:else if displayText}
					{prefix || ''}{displayText}{suffix || ''}
				{:else if entity && !state}
					<span>{entity_id}</span>
				{:else if !entity_id && !state}
					<span>{$lang('binary_sensor')}</span>
				{:else}
					{$lang('unknown')}
				{/if}
			</div>
		</div>
	</div>
</div>

<style>
	.container {
		display: grid;
		grid-template-rows: 0fr;
		overflow: hidden;
		pointer-events: none;
		text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.2);

		/* need to specify to properly show emoji */
		font-family: 'Inter Variable';
		text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.1);
		padding: var(--theme-sidebar-item-padding);
	}

	.visible {
		grid-template-rows: 1fr;
	}

	.expandable {
		min-height: 0;
		white-space: pre-line;
	}

	.content {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.icon {
		flex-shrink: 0;
		font-size: 1rem;
		transition: color var(--transition-medium);
	}

	.text {
		flex: 1;
	}

	/* State-based styling */
	.on .icon {
		color: var(--theme-colors-primary, #4fc3f7);
	}

	.off .icon {
		color: var(--theme-colors-fg-secondary, rgba(255, 255, 255, 0.6));
	}

	.unavailable .icon {
		color: var(--theme-colors-fg-tertiary, rgba(255, 255, 255, 0.3));
	}

	span {
		color: rgba(255, 255, 255, 0.25);
	}
</style>
