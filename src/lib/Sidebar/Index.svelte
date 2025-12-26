<script lang="ts">
	// store
	import { dashboard, motion, showDrawer, editMode, record, dragging } from '$lib/Stores';
	import { onMount, tick } from 'svelte';
	import { flip } from 'svelte/animate';
	import { dndzone, SHADOW_ITEM_MARKER_PROPERTY_NAME, TRIGGERS } from 'svelte-dnd-action';
	import { openModal } from 'svelte-modals';
	import { generateId, getSelected } from '$lib/Utils';
	import type { SidebarItem } from '$lib/Types';
	import '$lib/Sidebar/Sidebar.css';
	import type { ComponentType } from 'svelte';

	export let altKeyPressed: boolean;

	let skipTransformElement = false;
	let importedComponents: (string | undefined)[] = [];
	let mountedComponents = false;

	let Bar: ComponentType;
	let BinarySensor: ComponentType;
	let Camera: ComponentType;
	let Configure: ComponentType;
	let Date: ComponentType;
	let Divider: ComponentType;
	let Graph: ComponentType;
	let History: ComponentType;
	let Iframe: ComponentType;
	let Image: ComponentType;
	let Navigate: ComponentType;
	let Notifications: ComponentType;
	let Radial: ComponentType;
	let Sensor: ComponentType;
	let Template: ComponentType;
	let Time: ComponentType;
	let Timer: ComponentType;
	let Weather: ComponentType;
	let WeatherForecast: ComponentType;

	const imports = {
		bar: () => import('$lib/Sidebar/Bar.svelte').then((c) => (Bar = c.default)),
		binary_sensor: () =>
			import('$lib/Sidebar/BinarySensor.svelte').then((c) => (BinarySensor = c.default)),
		camera: () => import('$lib/Sidebar/Camera.svelte').then((c) => (Camera = c.default)),
		configure: () => import('$lib/Sidebar/Configure.svelte').then((c) => (Configure = c.default)),
		date: () => import('$lib/Sidebar/Date.svelte').then((c) => (Date = c.default)),
		divider: () => import('$lib/Sidebar/Divider.svelte').then((c) => (Divider = c.default)),
		graph: () => import('$lib/Sidebar/Graph.svelte').then((c) => (Graph = c.default)),
		history: () => import('$lib/Sidebar/History.svelte').then((c) => (History = c.default)),
		iframe: () => import('$lib/Sidebar/Iframe.svelte').then((c) => (Iframe = c.default)),
		image: () => import('$lib/Sidebar/Image.svelte').then((c) => (Image = c.default)),
		navigate: () => import('$lib/Sidebar/Navigate.svelte').then((c) => (Navigate = c.default)),
		notifications: () =>
			import('$lib/Sidebar/Notifications.svelte').then((c) => (Notifications = c.default)),
		radial: () => import('$lib/Sidebar/Radial.svelte').then((c) => (Radial = c.default)),
		sensor: () => import('$lib/Sidebar/Sensor.svelte').then((c) => (Sensor = c.default)),
		template: () => import('$lib/Sidebar/Template.svelte').then((c) => (Template = c.default)),
		time: () => import('$lib/Sidebar/Time.svelte').then((c) => (Time = c.default)),
		timer: () => import('$lib/Sidebar/Timer.svelte').then((c) => (Timer = c.default)),
		weather: () => import('$lib/Sidebar/Weather.svelte').then((c) => (Weather = c.default)),
		weather_forecast: () =>
			import('$lib/Sidebar/WeatherForecast.svelte').then((c) => (WeatherForecast = c.default))
	};

	$: if ($dashboard?.sidebar) importComponents();

	/**
	 * Dynamically imports sidebar components based on
	 * the types present in the `$dashboard.sidebar`.
	 */
	async function importComponents() {
		const types = [...new Set($dashboard.sidebar.map((item) => item.type))];
		const promises = [];

		// counter for supported and not yet imported imports
		let validImports = 0;

		for (let type of types) {
			const module = imports[type as keyof typeof imports];

			if (!importedComponents.includes(type) && module) {
				promises.push(module());
				importedComponents.push(type);
				validImports++;
			}
		}

		await Promise.all(promises);

		/**
		 * Wait for all imports to complete then set `loaded` flag
		 * to prevent flip animation before components has loaded.
		 */
		if (importedComponents.length >= validImports) {
			mountedComponents = true;
		}
	}

	/**
	 * Dynamically imports modals
	 */
	async function handleClick(selectedId: number | undefined) {
		const sel = getSelected(selectedId, $dashboard) as SidebarItem;

		if ($editMode && sel) {
			if (sel?.type === 'bar') {
				openModal(() => import('$lib/Modal/BarConfig.svelte'), { sel });
			} else if (sel?.type === 'camera') {
				openModal(() => import('$lib/Modal/CameraConfig.svelte'), { sel });
			} else if (sel?.type === 'date') {
				openModal(() => import('$lib/Modal/DateConfig.svelte'), { sel });
			} else if (sel?.type === 'divider') {
				openModal(() => import('$lib/Modal/DividerConfig.svelte'), { sel });
			} else if (sel?.type === 'graph') {
				openModal(() => import('$lib/Modal/GraphConfig.svelte'), { sel });
			} else if (sel?.type === 'history') {
				openModal(() => import('$lib/Modal/HistoryConfig.svelte'), { sel });
			} else if (sel?.type === 'iframe') {
				openModal(() => import('$lib/Modal/IframeConfig.svelte'), { sel });
			} else if (sel?.type === 'image') {
				openModal(() => import('$lib/Modal/ImageConfig.svelte'), { sel });
			} else if (sel?.type === 'navigate') {
				openModal(() => import('$lib/Modal/NavigateConfig.svelte'), { sel });
			} else if (sel?.type === 'notifications') {
				openModal(() => import('$lib/Modal/NotificationsConfig.svelte'), { sel });
			} else if (sel?.type === 'radial') {
				openModal(() => import('$lib/Modal/RadialConfig.svelte'), { sel });
			} else if (sel?.type === 'binary_sensor') {
				openModal(() => import('$lib/Modal/BinarySensorConfig.svelte'), { sel });
			} else if (sel?.type === 'sensor') {
				openModal(() => import('$lib/Modal/SensorConfig.svelte'), { sel });
			} else if (sel?.type === 'template') {
				openModal(() => import('$lib/Modal/TemplateConfig.svelte'), { sel });
			} else if (sel?.type === 'time') {
				openModal(() => import('$lib/Modal/TimeConfig.svelte'), { sel });
			} else if (sel?.type === 'timer') {
				openModal(() => import('$lib/Modal/TimerConfig.svelte'), { sel });
			} else if (sel?.type === 'weather') {
				openModal(() => import('$lib/Modal/WeatherConfig.svelte'), { sel });
			} else if (sel?.type === 'weather_forecast') {
				openModal(() => import('$lib/Modal/WeatherForecastConfig.svelte'), { sel });
			} else {
				openModal(() => import('$lib/Modal/SidebarItemConfig.svelte'), { sel });

				// force $editMode when clicking SidebarItemConfig
				await tick();
				setTimeout(() => {
					$editMode = true;
					$showDrawer = true;
				}, $motion);
			}
		} else {
			// !$editMode modals
			if (sel?.type === 'camera') {
				openModal(() => import('$lib/Modal/CameraModal.svelte'), { sel });
			} else if (sel?.type === 'timer') {
				openModal(() => import('$lib/Modal/TimerModal.svelte'), { sel });
			}
		}
	}

	function handleSort(event: CustomEvent<DndEvent>) {
		$dragging = true;

		$dashboard.sidebar = handleCopyOnDrag($dashboard.sidebar, event);

		if (event?.type === 'finalize') {
			$record();
			$dragging = false;
			skipTransformElement = false;
		}
	}

	function handleCopyOnDrag(items: any[], event: CustomEvent<DndEvent>) {
		const { trigger, id: itemId } = event.detail.info;

		if (trigger === TRIGGERS.DRAG_STARTED && altKeyPressed) {
			const idx = items.findIndex((item) => item.id === itemId);
			const newId = generateId($dashboard);

			event.detail.items = event.detail.items.filter(
				(item) => !item[SHADOW_ITEM_MARKER_PROPERTY_NAME]
			);
			event.detail.items.splice(idx, 0, { ...items[idx], id: newId });
		}

		return event.detail.items;
	}

	/**
	 * dnd transformDraggedElement
	 */
	function transformDraggedElement(element: HTMLElement | undefined) {
		if (element) {
			const container = element.firstElementChild as HTMLDivElement;

			if (!altKeyPressed) skipTransformElement = true;

			if (!skipTransformElement && container) {
				Object.assign(container.style, {
					outline: 'rgb(255, 192, 8) dashed 2px',
					outlineOffset: '-2px',
					borderRadius: '0.65rem'
				});
			}
		}
	}

	// media query js
	let matches = false;

	onMount(() => {
		const handleMediaQueryChange = (event: { matches: boolean }) => {
			matches = event.matches;
		};

		const mediaQuery = window.matchMedia('(max-width: 768px)');
		matches = mediaQuery.matches;

		mediaQuery.addEventListener('change', handleMediaQueryChange);
		// cleanup
		return () => {
			mediaQuery.removeEventListener('change', handleMediaQueryChange);
		};
	});
</script>

<aside
	style:padding={$dashboard.hide_sidebar || $dashboard.sidebar.length === 0
		? '0px'
		: 'var(--theme-sidebar-padding)'}
	style:transition="padding {$motion}ms ease"
>
	{#if $editMode}
		{#await import('$lib/Components/ResizeHandle.svelte') then ResizeHandle}
			<svelte:component this={ResizeHandle.default} />
		{/await}
	{/if}

	{#if !$dashboard?.hide_sidebar}
		<section
			use:dndzone={{
				type: 'sidebar',
				items: $dashboard?.sidebar,
				flipDurationMs: $motion,
				dragDisabled: !$editMode,
				dropTargetStyle: {},
				zoneTabIndex: -1,
				morphDisabled: true,
				transformDraggedElement
			}}
			on:consider={handleSort}
			on:finalize={handleSort}
		>
			{#each $dashboard.sidebar as item (item.id)}
				{@const hide_mobile = matches && item?.hide_mobile && !$editMode}

				<div
					id={String(item.id)}
					animate:flip={{ duration: mountedComponents ? $motion : 0 }}
					class="sidebar_edit_mode"
					style:display={item?.type === 'divider' ||
					item?.type === 'date' ||
					item?.type === 'camera' ||
					item?.type === 'time' ||
					item?.type === 'notifications' ||
					item?.type === 'configure'
						? 'flex'
						: 'initial'}
				>
					<!-- BAR -->
					{#if Bar && item?.type === 'bar' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component
								this={Bar}
								entity_id={item?.entity_id}
								name={item?.name}
								math={item?.math}
								id={item?.id}
							/>
						</button>

						<!-- CAMERA -->
					{:else if Camera && item?.type === 'camera' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={Camera} sel={item} />
						</button>

						<!-- CONFIGURE -->
					{:else if Configure && item?.type === 'configure'}
						<div on:click={() => handleClick(item?.id)} on:keydown role="button" tabindex="0">
							<svelte:component this={Configure} sel={item} />
						</div>

						<!-- DATE -->
					{:else if Date && item?.type === 'date' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component
								this={Date}
								short_day={item?.short_day}
								short_month={item?.short_month}
								hide={item?.hide}
								layout={item?.layout}
							/>
						</button>

						<!-- DIVIDER -->
					{:else if Divider && item?.type === 'divider' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)} aria-label={item?.type} tabindex="-1">
							<svelte:component this={Divider} mode={item?.mode} size={item?.size} />
						</button>

						<!-- GRAPH -->
					{:else if Graph && item?.type === 'graph' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component
								this={Graph}
								entity_id={item?.entity_id}
								name={item?.name}
								period={item?.period}
								stroke={item?.stroke}
							/>
						</button>

						<!-- HISTORY -->
					{:else if History && item?.type === 'history' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component
								this={History}
								entity_id={item?.entity_id || ''}
								period={item?.period}
							/>
						</button>

						<!-- IFRAME -->
					{:else if Iframe && item?.type === 'iframe' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={Iframe} url={item?.url} size={item?.size} />
						</button>

						<!-- NOTIFICATIONS -->
					{:else if Notifications && item?.type === 'notifications' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={Notifications} sel={item} />
						</button>

						<!-- IMAGE -->
					{:else if Image && item?.type === 'image' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={Image} entity_id={item?.entity_id} url={item?.url} />
						</button>

						<!-- NAVIGATE -->
					{:else if Navigate && item?.type === 'navigate' && !hide_mobile}
						{#key $editMode}
							<div
								on:click|preventDefault={() => {
									if ($editMode) handleClick(item?.id);
								}}
								on:keydown
								role="button"
								tabindex="0"
							>
								<svelte:component this={Navigate} />
							</div>
						{/key}

						<!-- RADIAL -->
					{:else if Radial && item?.type === 'radial' && !hide_mobile}
						<div on:click={() => handleClick(item?.id)} on:keydown role="button" tabindex="0">
							<svelte:component
								this={Radial}
								entity_id={item?.entity_id}
								name={item?.name}
								strokeWidth={item?.stroke}
							/>
						</div>

						<!-- BINARY SENSOR -->
					{:else if BinarySensor && item?.type === 'binary_sensor' && !hide_mobile}
						<div on:click={() => handleClick(item?.id)} on:keydown role="button" tabindex="0">
							<svelte:component
								this={BinarySensor}
								entity_id={item?.entity_id}
								prefix={item?.prefix}
								suffix={item?.suffix}
								icon_on={item?.icon_on}
								icon_off={item?.icon_off}
								on_value={item?.on_value}
								off_value={item?.off_value}
							/>
						</div>

						<!-- SENSOR -->
					{:else if Sensor && item?.type === 'sensor' && !hide_mobile}
						<div on:click={() => handleClick(item?.id)} on:keydown role="button" tabindex="0">
							<svelte:component
								this={Sensor}
								entity_id={item?.entity_id}
								prefix={item?.prefix}
								suffix={item?.suffix}
								date={item?.date || false}
							/>
						</div>

						<!-- TEMPLATE -->
					{:else if Template && item?.type === 'template' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={Template} sel={item} />
						</button>

						<!-- TIME -->
					{:else if Time && item?.type === 'time' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component
								this={Time}
								seconds={item?.seconds}
								hour12={item?.hour12 || false}
							/>
						</button>

						<!-- TIMER -->
					{:else if Timer && item?.type === 'timer' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={Timer} sel={item} />
						</button>

						<!-- WEATHER -->
					{:else if Weather && item?.type === 'weather' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={Weather} sel={item} />
						</button>

						<!-- WEATHER FORECAST -->
					{:else if WeatherForecast && item?.type === 'weather_forecast' && !hide_mobile}
						<button on:click={() => handleClick(item?.id)}>
							<svelte:component this={WeatherForecast} sel={item} />
						</button>
					{/if}
				</div>
			{/each}
		</section>

		{#await import('$lib/Sidebar/Toast.svelte') then Toast}
			<svelte:component this={Toast.default} />
		{/await}
	{/if}
</aside>

<style>
	aside {
		position: relative;
		grid-area: aside;
		padding: var(--theme-sidebar-padding);
		padding-bottom: 1.4rem !important;

		/* Enhanced background with glassmorphism */
		background: var(--theme-colors-sidebar-background, var(--color-surface-elevated));
		backdrop-filter: blur(var(--blur-md));
		-webkit-backdrop-filter: blur(var(--blur-md));

		/* Modern border with better opacity */
		border-right: var(--theme-colors-sidebar-border, 1px solid var(--color-border-subtle));

		/* Enhanced shadows for depth */
		box-shadow: var(--shadow-sm);

		/* Smooth transitions */
		transition:
			background-color var(--transition-medium),
			border-color var(--transition-medium),
			box-shadow var(--transition-medium);
	}

	div {
		width: 100%;
	}

	button {
		background: inherit;
		border: inherit;
		color: inherit;
		font-family: inherit;
		padding: inherit;
		text-align: inherit;
		cursor: inherit;
		font-size: inherit;
		width: 100%;

		/* Enhanced button styling */
		border-radius: var(--radius-lg);
		transition: var(--transition-colors);
		position: relative;
		overflow: hidden;
	}

	/* Modern hover effects for sidebar buttons */
	button:hover {
		background: var(--color-glass-light);
		backdrop-filter: blur(var(--blur-sm));
		-webkit-backdrop-filter: blur(var(--blur-sm));
	}

	/* Focus states for accessibility */
	button:focus-visible {
		outline: none;
		box-shadow: 0 0 0 2px var(--color-primary-hover);
	}

	section {
		margin-top: 1rem;
		height: calc(100% - 1rem);
		font-size: var(--theme-sidebar-font-size, var(--text-base));
		display: flex;
		flex-direction: column;
		gap: var(--space-2);
	}

	.sidebar_edit_mode {
		transition:
			height var(--transition-medium),
			opacity var(--transition-medium),
			transform var(--transition-medium);
		display: flex;
		border-radius: var(--radius-lg);
	}

	/* Enhanced edit mode styling */
	.sidebar_edit_mode:hover {
		transform: translateX(2px);
	}

	/* Modern scrollbar for sidebar content */
	section {
		scrollbar-width: thin;
		scrollbar-color: var(--color-border-strong) transparent;
	}

	section::-webkit-scrollbar {
		width: 6px;
	}

	section::-webkit-scrollbar-track {
		background: transparent;
	}

	section::-webkit-scrollbar-thumb {
		background-color: var(--color-border-strong);
		border-radius: var(--radius-full);
	}

	section::-webkit-scrollbar-thumb:hover {
		background-color: var(--color-border-interactive);
	}

	/* Mobile responsiveness enhancements */
	@media (max-width: 768px) {
		aside {
			padding: var(--space-4);
			box-shadow: var(--shadow-lg);
		}

		.sidebar_edit_mode:hover {
			transform: none; /* Disable transform on mobile for better performance */
		}
	}

	/* Reduced motion accessibility */
	@media (prefers-reduced-motion: reduce) {
		aside,
		button,
		.sidebar_edit_mode {
			transition: none;
		}

		.sidebar_edit_mode:hover {
			transform: none;
		}
	}
</style>
