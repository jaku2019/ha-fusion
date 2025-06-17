<script>
    import { components } from './index';
    export let item;
    export let config;
    export let editMode;
</script>

{#if item.component === 'Graph' && components.Graph}
	<svelte:component 
		this={components.Graph}
		{config}
		entity_id={item.entity_id}
		{editMode}
	/>
{:else}
	<!-- ...existing component handling... -->
{/if}