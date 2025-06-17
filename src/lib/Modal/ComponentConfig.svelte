<script>
	import Graph from '$lib/Dashboard/Graph.svelte';
	
	const componentOptions = [
		{
			name: 'Graph',
			component: Graph,
			icon: 'mdi:chart-line',
			description: 'Display entity history as a line graph',
			preview: true,
			config: {
				sel: {
					entity_id: 'sensor.energy_usage',
					config: {
						hours: 24,
						stroke_color: '#4fc3f7',
						fill_color: '#4fc3f740'
					}
				}
			}
		}
	];
</script>

{#each componentOptions as { name, component, icon, description, preview, config }}
	<div class="component-option">
		<svelte:component this={component} sel={config.sel} />
		<div class="component-info">
			<i class={icon}></i>
			<h3>{name}</h3>
			<p>{description}</p>
		</div>
	</div>
{/each}