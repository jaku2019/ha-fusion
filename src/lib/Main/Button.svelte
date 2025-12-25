<script lang="ts">
	import ComputeIcon from '$lib/Components/ComputeIcon.svelte';
	import StateLogic from '$lib/Components/StateLogic.svelte';
	import {
		connection,
		editMode,
		itemHeight,
		lang,
		motion,
		onStates,
		climateHvacActionToMode,
		ripple,
		states,
		templates,
		config,
		selectedLanguage,
		calendarView,
		calendarFirstDay
	} from '$lib/Stores';
	import { getDomain, getName, getTogglableService } from '$lib/Utils';
	import Icon, { loadIcon } from '@iconify/svelte';
	import { callService, type HassEntity } from 'home-assistant-js-websocket';
	import { marked } from 'marked';
	import { onDestroy } from 'svelte';
	import { openModal } from 'svelte-modals';
	import Ripple from 'svelte-ripple';
	import parser from 'js-yaml';

	export let demo: string | undefined = undefined;
	export let sel: any;
	export let sectionName: string | undefined = undefined;

	$: entity_id = demo || sel?.entity_id;
	$: template = $templates?.[sel?.id];
	$: icon = (sel?.template?.icon && template?.icon?.output) || sel?.icon;
	$: color = (sel?.template?.color && template?.color?.output) || sel?.color;
	$: marquee = sel?.marquee;
	$: more_info = sel?.more_info;

	let entity: HassEntity;
	let contentWidth: number;
	let container: HTMLDivElement;
	let loading: boolean;
	let resetLoading: ReturnType<typeof setTimeout> | null;
	let stateOn: boolean;

	/** display loader if no state change has occurred within `$motion`ms */
	let delayLoading: ReturnType<typeof setTimeout> | null;

	// Long press functionality
	let pressTimer: ReturnType<typeof setTimeout> | null = null;
	let isLongPress = false;
	const LONG_PRESS_DURATION = 500; // milliseconds

	/**
	 * Observes changes in the `last_updated` property of an entity.
	 * When the `last_updated` property changes:
	 *
	 * - Updates `entity` with the new state from `$states`
	 * - Resets the `loading` state to `false`
	 * - Clears any pending loading or reset timeouts
	 */
	$: if (entity_id && $states?.[entity_id]?.last_updated !== entity?.last_updated) {
		entity = $states?.[entity_id];

		loading = false;

		if (delayLoading) {
			clearTimeout(delayLoading);
			delayLoading = null;
		}

		if (resetLoading) {
			clearTimeout(resetLoading);
			resetLoading = null;
		}
	}

	$: attributes = entity?.attributes;

	$: iconColor = color
		? color
		: attributes?.hs_color
			? `hsl(${attributes?.hs_color}%, 50%)`
			: 'rgb(75, 166, 237)';

	// icon is image if extension, e.g. test.png, OR if person entity with entity_picture
	$: image =
		icon?.includes('.') || (getDomain(entity_id) === 'person' && attributes?.entity_picture);

	$: if (sel?.template?.set_state && template?.set_state?.output) {
		// template
		stateOn = $onStates?.includes(template?.set_state?.output?.toLocaleLowerCase());
	} else if (attributes?.hvac_action) {
		// climate
		stateOn = $onStates?.includes(
			$climateHvacActionToMode?.[attributes?.hvac_action]?.toLocaleLowerCase()
		);
	} else if (attributes?.in_progress) {
		// update
		stateOn = typeof attributes.in_progress === 'number';
	} else {
		// default
		stateOn = $onStates?.includes(entity?.state?.toLocaleLowerCase());
	}

	/**
	 * Toggles the state of the specified entity
	 * using the correct service call...
	 */
	function toggle() {
		// if service template
		if (sel?.template?.service && template?.service?.output) {
			try {
				// template is string, try to parse it
				const _template = parser.load(template?.service?.output) as {
					service: string;
					data: Record<string, string | number | boolean>;
				};

				if (_template?.service) {
					const [domain, service] = _template.service.split('.');
					callService($connection, domain, service, _template?.data);
				}
			} catch (error) {
				console.error('Template service YAML parse error:', error);
			}

			return;
		}

		// default
		const service = getTogglableService(entity);

		if (service) {
			// use returned domain to handle specific cases such
			// as 'remote', which uses 'homeassistant.toggle'
			const [_domain, _service] = service.split('.');
			callService($connection, _domain, _service, {
				entity_id
			});

			// loader
			delayLoading = setTimeout(() => {
				loading = true;
			}, $motion);

			// loader 20s fallback
			resetLoading = setTimeout(() => {
				loading = false;
			}, 20_000);
		} else {
			// not in getTogglableService just open modal
			handleClickEvent();
		}
	}

	/**
	 * Handle pointer down - start long press timer
	 */
	function handlePointerDown(event: PointerEvent) {
		if ($editMode) return;

		isLongPress = false;
		pressTimer = setTimeout(() => {
			isLongPress = true;
			// Provide haptic feedback if available
			if (navigator.vibrate) {
				navigator.vibrate(50);
			}
			// Open modal on long press
			handleClickEvent();
		}, LONG_PRESS_DURATION);
	}

	/**
	 * Handle pointer up - execute short press action or cancel long press
	 */
	function handlePointerUp(event: PointerEvent) {
		if (pressTimer) {
			clearTimeout(pressTimer);
			pressTimer = null;
		}

		// If it wasn't a long press, execute toggle
		if (!isLongPress && !$editMode) {
			toggle();
		}

		isLongPress = false;
	}

	/**
	 * Handle pointer leave - cancel long press if pointer leaves button
	 */
	function handlePointerLeave() {
		if (pressTimer) {
			clearTimeout(pressTimer);
			pressTimer = null;
		}
		isLongPress = false;
	}

	/**
	 * Delegate to handleEvent
	 */
	function handlePointer() {
		handleEvent({ type: 'preload' });
	}

	/**
	 * handleEvent
	 * pointerenter | pointerdown | click
	 */
	async function handleEvent(event: any) {
		if (event.type === 'click') {
			// In edit mode, allow click to open config
			if ($editMode) {
				await handleClickEvent();
			}
			// In normal mode, click is handled by pointer events for long press
		} else {
			await handlePointerEvent();
		}
	}

	/**
	 * Handle click events
	 * Opens modal for specified domain
	 */
	async function handleClickEvent() {
		if ($editMode) {
			openModal(() => import('$lib/Modal/ButtonConfig.svelte'), {
				demo: entity_id,
				sel,
				sectionName
			});
		} else if (more_info === false) {
			toggle();
		} else {
			switch (getDomain(sel?.entity_id)) {
				// light
				case 'light':
					openModal(() => import('$lib/Modal/LightModal.svelte'), {
						sel: sel
					});
					break;

				// switch
				case 'input_boolean':
				case 'remote':
				case 'siren':
				case 'switch':
					openModal(() => import('$lib/Modal/SwitchModal.svelte'), { sel });
					break;

				// script
				case 'script':
					openModal(() => import('$lib/Modal/ScriptModal.svelte'), { sel });
					break;

				// automation
				case 'automation':
					openModal(() => import('$lib/Modal/AutomationModal.svelte'), { sel });
					break;

				// calendar
				case 'calendar': {
					// set first day of week
					$calendarFirstDay =
						'weekInfo' in Intl.Locale.prototype
							? (new Intl.Locale($selectedLanguage) as any)?.weekInfo.firstDay
							: (await import('weekstart')).getWeekStartByLocale($selectedLanguage);

					// set calendar view type
					$calendarView = localStorage.getItem('calendar');

					openModal(() => import('$lib/Modal/CalendarModal.svelte'), { sel });
					break;
				}

				// sensor
				case 'air_quality':
				case 'date':
				case 'time':
				case 'event':
				case 'image_processing':
				case 'mailbox':
				case 'sensor':
				case 'binary_sensor':
				case 'stt':
				case 'weather':
				case 'button':
				case 'scene':
				case 'schedule':
				case 'sun':
				case 'person':
				case 'zone':
				case 'input_button':
					openModal(() => import('$lib/Modal/SensorModal.svelte'), { sel });
					break;

				// update
				case 'update':
					openModal(() => import('$lib/Modal/UpdateModal.svelte'), { sel });
					break;

				// number
				case 'input_number':
				case 'number':
					openModal(() => import('$lib/Modal/InputNumberModal.svelte'), { sel });
					break;

				// date
				case 'input_datetime':
				case 'datetime':
					openModal(() => import('$lib/Modal/InputDateModal.svelte'), { sel });
					break;

				// select
				case 'input_select':
				case 'select':
					openModal(() => import('$lib/Modal/InputSelectModal.svelte'), { sel });
					break;

				// text
				case 'input_text':
				case 'text':
					openModal(() => import('$lib/Modal/InputTextModal.svelte'), { sel });
					break;

				case 'timer':
					openModal(() => import('$lib/Modal/TimerModal.svelte'), { sel });
					break;

				case 'vacuum':
					openModal(() => import('$lib/Modal/VacuumModal.svelte'), { sel });
					break;

				case 'lawn_mower':
					openModal(() => import('$lib/Modal/LawnMowerModal.svelte'), { sel });
					break;

				case 'valve':
					openModal(() => import('$lib/Modal/ValveModal.svelte'), { sel });
					break;

				case 'image':
					openModal(() => import('$lib/Modal/ImageModal.svelte'), { sel });
					break;

				case 'todo':
					openModal(() => import('$lib/Modal/TodoModal.svelte'), { sel });
					break;

				case 'counter':
					openModal(() => import('$lib/Modal/CounterModal.svelte'), { sel });
					break;

				case 'alarm_control_panel':
					openModal(() => import('$lib/Modal/AlarmControlPanelModal.svelte'), { sel });
					break;

				case 'lock':
					openModal(() => import('$lib/Modal/LockModal.svelte'), { sel });
					break;

				case 'climate':
					openModal(() => import('$lib/Modal/ClimateModal.svelte'), { sel });
					break;

				case 'camera':
					openModal(() => import('$lib/Modal/CameraModal.svelte'), { sel });
					break;

				case 'water_heater':
					openModal(() => import('$lib/Modal/WaterHeaterModal.svelte'), { sel });
					break;

				case 'humidifier':
					openModal(() => import('$lib/Modal/HumidifierModal.svelte'), { sel });
					break;

				case 'media_player':
					openModal(() => import('$lib/Modal/MediaPlayer.svelte'), {
						selected: sel
					});
					break;

				case 'group':
					openModal(() => import('$lib/Modal/GroupModal.svelte'), { sel });
					break;

				case 'device_tracker': {
					if ($states?.[sel?.entity_id]?.attributes?.source_type === 'gps') {
						openModal(() => import('$lib/Modal/DeviceTrackerModal.svelte'), { sel });
					} else {
						openModal(() => import('$lib/Modal/SensorModal.svelte'), { sel });
					}
					break;
				}

				case 'cover':
					openModal(() => import('$lib/Modal/CoverModal.svelte'), {
						selected: sel
					});
					break;

				case 'fan':
					openModal(() => import('$lib/Modal/FanModal.svelte'), {
						selected: sel
					});
					break;

				default:
					openModal(() => import('$lib/Modal/Unknown.svelte'), {
						selected: sel
					});
					break;
			}
		}
	}

	/**
	 * Preloads module before click event
	 */
	async function handlePointerEvent() {
		if ($editMode) {
			await import('$lib/Modal/ButtonConfig.svelte');
		} else {
			switch (getDomain(sel?.entity_id)) {
				case 'light':
					await import('$lib/Modal/LightModal.svelte');
					break;
				case 'switch':
					await import('$lib/Modal/SwitchModal.svelte');
					break;
				case 'climate':
					await import('$lib/Modal/ClimateModal.svelte');
					break;
				case 'media_player':
					await import('$lib/Modal/MediaPlayer.svelte');
					break;
				default:
					await import('$lib/Modal/Unknown.svelte');
					break;
			}
		}
	}

	////// templates //////

	$: if ($config?.state === 'RUNNING' && sel?.template) {
		// for each changed entry in template
		Object.entries(sel?.template as Record<string, string>).forEach(([key, value]) => {
			const compareTemplate = value === template?.[key]?.input;
			const compareEntityId = sel?.entity_id === template?.[key]?.entity_id;
			if (compareTemplate && compareEntityId) return;
			renderTemplate(key, value);
		});
	}

	let unsubscribe: () => void;

	async function renderTemplate(key: string, value: string) {
		if (!$connection || !sel?.id) return;

		try {
			unsubscribe = await $connection.subscribeMessage(
				(response: { result: string } | { error: string; level: 'ERROR' | 'WARNING' }) => {
					let data: any = {
						input: value
					};

					if ('result' in response) {
						data.output =
							key === 'state' || key === 'name'
								? marked.parseInline(String(response.result))
								: String(response.result);
					} else if (response?.level === 'ERROR') {
						console.error(response.error);
						data.error = response.error;
					}

					data.entity_id = sel?.entity_id;

					$templates[sel?.id] = { ...$templates[sel?.id], [key]: data };
				},
				{
					type: 'render_template',
					template: value,
					report_errors: true,
					variables: {
						entity_id: sel?.entity_id
					}
				}
			);
		} catch (error) {
			console.error('Template error:', error);
		}
	}

	onDestroy(() => {
		unsubscribe?.();
		if (pressTimer) {
			clearTimeout(pressTimer);
		}
	});
</script>

<div
	class="container"
	bind:this={container}
	data-state={stateOn}
	data-layout={sel?.layout || 'square'}
	tabindex="-1"
	style={!$editMode ? 'cursor: pointer;' : ''}
	style:min-height="{$itemHeight}px"
	on:pointerenter={handlePointer}
	on:pointerdown={handlePointerDown}
	on:pointerup={handlePointerUp}
	on:pointerleave={handlePointerLeave}
	on:click={handleEvent}
	use:Ripple={{
		...$ripple,
		color: !$editMode
			? stateOn
				? 'rgba(0, 0, 0, 0.25)'
				: 'rgba(255, 255, 255, 0.15)'
			: 'rgba(0, 0, 0, 0)'
	}}
>
	<!-- ICON -->
	<div class="icon-container" on:keydown role="button" tabindex="0">
		<div
			class="icon"
			data-state={stateOn}
			style:--icon-color={iconColor}
			style:background-color={sel?.template?.color && template?.color?.output
				? template?.color?.output
				: undefined}
			style:background-image={(getDomain(entity_id) === 'person' && attributes?.entity_picture) ||
			(!icon && attributes?.entity_picture)
				? `url(${attributes?.entity_picture})`
				: image && icon
					? `url(${icon})`
					: 'none'}
			class:image
			class:person-avatar={getDomain(entity_id) === 'person' && attributes?.entity_picture}
		>
			{#if loading}
				<img src="loader.svg" alt="loading" style="margin:0 auto" />
			{:else if image || (getDomain(entity_id) === 'person' && attributes?.entity_picture) || (!icon && attributes?.entity_picture)}
				&nbsp;
			{:else if icon}
				{#await loadIcon(icon)}
					<!-- loading -->
					<Icon icon="ooui:help-ltr" height="none" width="100%" />
				{:then resolvedIcon}
					<!-- exists -->
					<Icon icon={resolvedIcon} height="none" width="100%" />
				{:catch}
					<!-- doesn't exist -->
					<Icon icon="ooui:help-ltr" height="none" width="100%" />
				{/await}
			{:else if entity_id}
				<ComputeIcon {entity_id} skipEntityPicture={getDomain(entity_id) === 'person'} />
			{:else}
				<Icon icon="ooui:help-ltr" height="none" width="100%" />
			{/if}
		</div>
	</div>

	<!-- CONTENT -->
	<div class="content" on:keydown role="button" tabindex="0">
		<!-- NAME -->
		<div class="name" data-state={stateOn}>
			{@html (sel?.template?.name && template?.name?.output) ||
				getName(sel, entity, sectionName) ||
				$lang('unknown')}
		</div>

		<!-- STATE -->
		<div class="state" data-state={stateOn}>
			{#if getDomain(entity_id) === 'climate'}
				<!-- Use StateLogic for climate entities to show hvac_action -->
				<StateLogic {entity_id} selected={sel} />
			{:else if sel?.state || (sel?.template?.state && template?.state?.output)}
				{@html sel?.state || template?.state?.output}
			{:else if sel?.template?.set_state && template?.set_state?.output}
				{@html sel?.template?.set_state && $lang(template?.set_state?.output)}
			{:else}
				<!-- Use StateLogic component to handle all entity states properly -->
				<StateLogic {entity_id} selected={sel} />
			{/if}
		</div>
	</div>
</div>

<style>
	.container {
		background: var(--theme-button-background-color-off);
		font-family: inherit;
		width: 100%;
		height: 100%;
		display: grid;
		aspect-ratio: 1;
		border-radius: 0.7em;
		margin: 0;
		grid-template-rows: auto 1fr;
		grid-template-columns: 1fr;
		gap: 0.5em;
		padding: 0.85em;
		overflow: hidden;
		position: relative;
		transition: background-color 0.2s ease;
	}

	/* Rectangular layout */
	.container[data-layout='rectangular'] {
		aspect-ratio: 2 / 1;
		grid-template-rows: 1fr;
		grid-template-columns: auto 1fr;
		grid-template-areas: 'icon content';
	}

	.image {
		background-size: cover;
		background-repeat: no-repeat;
		background-position: center center;
	}

	.icon-container {
		justify-self: start;
		align-self: start;
	}

	.container[data-layout='rectangular'] .icon-container {
		grid-area: icon;
		align-self: center;
	}

	.content {
		display: flex;
		flex-direction: column;
		justify-content: flex-end;
		gap: 0.15em;
	}

	.container[data-layout='rectangular'] .content {
		grid-area: content;
		justify-content: center;
		padding-left: 0.5em;
	}

	.icon {
		height: 2.3rem;
		width: 2.3rem;
		color: var(--icon-color);
		background: rgba(0, 0, 0, 0.15);
		border-radius: 0.6em;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 0.5rem;
		background-position: center center;
		background-size: cover;
		background-repeat: no-repeat;
		transition:
			background-color 0.2s ease,
			transform 0.2s ease;
	}

	.icon[data-state='true'] {
		color: rgb(255, 255, 255);
		background: var(--icon-color);
	}

	/* Preserve entity_picture for person entities */
	.icon[data-state='true'].image {
		background: transparent;
	}

	.name {
		font-weight: 500;
		color: var(--theme-button-name-color-off);
		font-size: 0.95em;
		line-height: 1.2em;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		margin: 0;
	}

	.state {
		font-weight: 400;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		color: var(--theme-button-state-color-off);
		font-size: 0.75em;
		opacity: 0.7;
		margin: 0;
	}

	.container[data-state='true'] {
		background: var(--theme-button-background-color-on);
	}

	.name[data-state='true'] {
		color: var(--theme-button-name-color-on);
	}

	.state[data-state='true'] {
		color: var(--theme-button-state-color-on);
		opacity: 0.8;
	}

	/* Phone and Tablet (portrait) */
	@media all and (max-width: 768px) {
		.container {
			aspect-ratio: 1;
			padding: 0.65em;
			gap: 0.35em;
		}

		.icon {
			height: 2rem;
			width: 2rem;
			padding: 0.4rem;
		}

		.name {
			font-size: 0.85em;
		}

		.state {
			font-size: 0.7em;
		}
	}
</style>
